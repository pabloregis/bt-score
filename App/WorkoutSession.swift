import Foundation
@preconcurrency import HealthKit

/// Treino de tênis no HealthKit que acompanha a partida. Com ele ativo, levantar o pulso
/// mostra o placar em vez do mostrador, e a partida fica gravada como treino no app Saúde.
/// Sem HealthKit ou sem permissão, não faz nada: o app segue como marcador.
@MainActor
final class WorkoutSession {
    private let store = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    /// Início da partida do treino em andamento.
    private var currentMatchStart: Date?
    /// Início da partida cujo treino já foi gravado. Desfazer a partir do resultado não abre outro.
    private var finishedMatchStart: Date?
    /// Última operação na fila: começar e terminar rodam em ordem, um de cada vez.
    private var pending: Task<Void, Never>?

    private var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    /// Pede a permissão de gravar treinos. O sistema só mostra o pedido na primeira vez.
    func requestAuthorization() async {
        guard isAvailable else { return }
        try? await store.requestAuthorization(toShare: [HKObjectType.workoutType()], read: [])
    }

    /// Começa o treino da partida que começou em `matchStart`, ou retoma o que ficou ativo
    /// se o app fechou no meio dela. Com um treino já em andamento, não faz nada.
    func start(matchStart: Date) {
        enqueue { [self] in await begin(at: matchStart) }
    }

    /// Termina o treino e o grava no Saúde: no fim da partida, ao encerrá-la antes do fim
    /// e ao descartá-la na retomada.
    func end() {
        enqueue { [self] in await finish() }
    }

    private func enqueue(_ operation: @escaping @MainActor () async -> Void) {
        let previous = pending
        pending = Task {
            await previous?.value
            await operation()
        }
    }

    private func begin(at matchStart: Date) async {
        if let session, session.state == .ended || session.state == .stopped {
            // O sistema encerrou a sessão por fora (ex.: outro app de treino); começa outra.
            self.session = nil
            builder = nil
        }
        guard isAvailable, session == nil, finishedMatchStart != matchStart,
              store.authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized
        else { return }
        if let recovered = try? await store.recoverActiveWorkoutSession() {
            adopt(recovered, matchStart: matchStart)
            return
        }
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .tennis
        configuration.locationType = .outdoor
        guard let session = try? HKWorkoutSession(healthStore: store, configuration: configuration) else { return }
        let builder = adopt(session, matchStart: matchStart)
        builder.dataSource = HKLiveWorkoutDataSource(healthStore: store, workoutConfiguration: configuration)
        session.startActivity(with: matchStart)
        do {
            try await builder.beginCollection(at: matchStart)
        } catch {
            // Sem coleta não há treino para gravar; descarta a sessão para tentar de novo no próximo ponto.
            session.end()
            self.session = nil
            self.builder = nil
        }
    }

    private func finish() async {
        if session == nil, isAvailable, let recovered = try? await store.recoverActiveWorkoutSession() {
            adopt(recovered, matchStart: nil)
        }
        guard let session, let builder else { return }
        finishedMatchStart = currentMatchStart
        self.session = nil
        self.builder = nil
        session.end()
        try? await builder.endCollection(at: .now)
        _ = try? await builder.finishWorkout()
    }

    @discardableResult
    private func adopt(_ session: HKWorkoutSession, matchStart: Date?) -> HKLiveWorkoutBuilder {
        let builder = session.associatedWorkoutBuilder()
        self.session = session
        self.builder = builder
        currentMatchStart = matchStart
        return builder
    }
}
