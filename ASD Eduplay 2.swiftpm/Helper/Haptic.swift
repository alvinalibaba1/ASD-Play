import SwiftUI

@MainActor
class Haptic {
    static let shared = Haptic()
    
    private init() {}
    
    func success() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}
