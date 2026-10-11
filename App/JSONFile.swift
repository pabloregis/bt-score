import Foundation

/// Um valor gravado em JSON num arquivo em Application Support.
/// Falhas de leitura ou gravação não interrompem o app: o valor só não persiste.
struct JSONFile<Value: Codable> {
    private let url: URL

    init(name: String, directory: URL = .applicationSupportDirectory) {
        url = directory.appending(path: name)
    }

    /// O valor gravado, ou `nil` se não houver arquivo ou ele não puder ser lido.
    func load() -> Value? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(Value.self, from: data)
    }

    func save(_ value: Value) {
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? JSONEncoder().encode(value).write(to: url, options: .atomic)
    }

    func clear() {
        try? FileManager.default.removeItem(at: url)
    }
}
