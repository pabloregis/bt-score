import Foundation

/// Um valor gravado em JSON num arquivo em Application Support.
/// Falhas de leitura ou gravação não interrompem o app: o valor só não persiste.
struct JSONFile<Value: Codable> {
    private let url: URL

    init(name: String, directory: URL = .applicationSupportDirectory) {
        url = directory.appending(path: name)
    }

    /// O valor gravado, ou `nil` se não houver arquivo ou ele não puder ser lido.
    /// Um arquivo que existe mas não decodifica é guardado ao lado, com o sufixo ".ilegivel",
    /// para que a próxima gravação não apague o que havia nele.
    func load() -> Value? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        if let value = try? JSONDecoder().decode(Value.self, from: data) { return value }
        let backup = url.appendingPathExtension("ilegivel")
        try? FileManager.default.removeItem(at: backup)
        try? FileManager.default.moveItem(at: url, to: backup)
        return nil
    }

    func save(_ value: Value) {
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? JSONEncoder().encode(value).write(to: url, options: .atomic)
    }

    func clear() {
        try? FileManager.default.removeItem(at: url)
    }
}
