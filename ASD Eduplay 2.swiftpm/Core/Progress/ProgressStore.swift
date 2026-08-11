import Foundation

@MainActor
final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    private static let storageKey = "progress.v1"

    private let defaults: UserDefaults
    @Published private(set) var progress: [GameKind: GameProgress]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.progress = Self.load(from: defaults)
    }

    func progress(for game: GameKind) -> GameProgress {
        progress[game] ?? GameProgress()
    }

    func recordSessionStart(_ game: GameKind) {
        mutate(game) {
            $0.sessionsPlayed += 1
            $0.lastPlayedAt = Date()
        }
    }

    func recordCorrect(_ game: GameKind) {
        mutate(game) { $0.correctCount += 1 }
    }

    func recordIncorrect(_ game: GameKind) {
        mutate(game) { $0.incorrectCount += 1 }
    }

    func recordRoundCompleted(_ game: GameKind) {
        mutate(game) { $0.roundsCompleted += 1 }
    }

    func resetAll() {
        progress = [:]
        persist()
    }

    private func mutate(_ game: GameKind, _ change: (inout GameProgress) -> Void) {
        var entry = progress[game] ?? GameProgress()
        change(&entry)
        progress[game] = entry
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }

    private static func load(from defaults: UserDefaults) -> [GameKind: GameProgress] {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([GameKind: GameProgress].self, from: data) else {
            return [:]
        }
        return decoded
    }
}
