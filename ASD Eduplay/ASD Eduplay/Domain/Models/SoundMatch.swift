import Foundation

struct SoundMatchItem: Identifiable, Hashable {
    let id: String
    let imageName: String
    let soundName: String
    let label: String
}

struct SoundMatchRound {
    let target: SoundMatchItem
    let options: [SoundMatchItem]
}
