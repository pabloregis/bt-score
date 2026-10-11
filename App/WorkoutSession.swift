import Foundation
import HealthKit

/// Treino de tênis no HealthKit que acompanha a partida. Com ele ativo, levantar o pulso
/// mostra o placar em vez do mostrador, e a partida fica gravada como treino no app Saúde.
/// Sem HealthKit ou sem permissão, não faz nada: o app segue como marcador.
@MainActor
final class WorkoutSession {
    private let store = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    /// Última operação na fila: começar e terminar rodam em ordem, um de cada vez.
    private var pending: Task<Void, Never>?

    private var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    /// Pede a permissão de gravar treinos. O sistema só mostra o pedido na primeira vez.
    func requestAuthorization() async {
        guard isAvailable else { return }
        try? await store.requestAuthorization(toShare: [HKObjectType.workoutType()], read: [])
    }

    /// Acompanha a partida: começa o treino quando ela está em andamento e o termina quando ela
    /// acaba ou some (encerrada, concluída ou desfeita até o início).
    func follow(isPlaying: Bool, startedAt: Date?) {
        enqueue { [self] in
            if isPlaying {
                await start(at: startedAt ?? .now)
            } else {
                await end()
            }
        }
    }

    /// Termina um treino que tenha ficado ativo de uma partida descartada na retomada.
    func discard() {
        enqueue { [self] in await end() }
    }

    private func enqueue(_ operation: @escaping @MainActor () async -> Void) {
        let previous = pending
        pending = Task {
            await previous?.value
            await operation()
        }
    }

    /// Começa o treino, ou retoma o que ficou ativo se o app fechou no meio da partida.
    private func start(at date: Date) async {
        guard isAvailable, session == nil,
              store.authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized
        else { return }
        if let recovered = try? await store.recoverActiveWorkoutSession() {
            adopt(recovered)
            return
        }
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .tennis
        configuration.locationType = .outdoor
        guard let session = try? HKWorkoutSession(healthStore: store, configuration: configuration) else { return }
        adopt(session)
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: store, workoutConfiguration: configuration)
        session.startActivity(with: date)
        try? await builder?.beginCollection(at: date)
    }

    /// Termina o treino e o grava no Saúde, inclusive quando a partida é encerrada antes do fim.
    /// Sem treino nesta execução, encerra um que tenha ficado ativo de antes do app fechar.
    private func end(at date: Date = .now) async {
        if session == nil, isAvailable, let recovered = try? await store.recoverActiveWorkoutSession() {
            adopt(recovered)
        }
        guard let session, let builder else { return }
        self.session = nil
        self.builder = nil
        session.end()
        try? await builder.endCollection(at: date)
        _ = try? await builder.finishWorkout()
    }

    private func adopt(_ session: HKWorkoutSession) {
        self.session = session
        builder = session.associatedWorkoutBuilder()
    }
}
