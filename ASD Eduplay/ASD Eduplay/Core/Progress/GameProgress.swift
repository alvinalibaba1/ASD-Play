import Foundation

enum GameKind: String, Codable, CaseIterable {
    case jigsaw
    case matching
    case sorting
    case tracing
}

struct GameProgress: Codable, Equatable {
    var sessionsPlayed: Int = 0
    var roundsCompleted: Int = 0
    var correctCount: Int = 0
    var incorrectCount: Int = 0
    var lastPlayedAt: Date?
}
