import Foundation

// Emoji instead of illustration assets - a face is legible at any size, needs
// no art, and can't go missing the way an image asset can (see the Tracing
// "car" incident: a deleted/renamed image silently breaks a level).
enum Emotion: String, CaseIterable {
    case happy
    case sad
    case angry
    case surprised
    case scared
    case calm

    var emoji: String {
        switch self {
        case .happy: return "😀"
        case .sad: return "😢"
        case .angry: return "😠"
        case .surprised: return "😲"
        case .scared: return "😨"
        case .calm: return "😌"
        }
    }

    var label: String {
        switch self {
        case .happy: return "Happy"
        case .sad: return "Sad"
        case .angry: return "Angry"
        case .surprised: return "Surprised"
        case .scared: return "Scared"
        case .calm: return "Calm"
        }
    }
}

struct EmotionMatchingRound {
    let target: Emotion
    let options: [Emotion]
}
