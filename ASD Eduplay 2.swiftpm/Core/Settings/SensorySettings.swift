import SwiftUI

@MainActor
final class SensorySettings: ObservableObject {
    static let shared = SensorySettings()

    private enum Key {
        static let soundEffects = "sensory.soundEffectsEnabled"
        static let music = "sensory.musicEnabled"
        static let haptics = "sensory.hapticsEnabled"
        static let reduceMotion = "sensory.reduceMotionEnabled"
    }

    private let defaults: UserDefaults

    @Published var soundEffectsEnabled: Bool {
        didSet { defaults.set(soundEffectsEnabled, forKey: Key.soundEffects) }
    }

    @Published var musicEnabled: Bool {
        didSet { defaults.set(musicEnabled, forKey: Key.music) }
    }

    @Published var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: Key.haptics) }
    }

    @Published var reduceMotionEnabled: Bool {
        didSet { defaults.set(reduceMotionEnabled, forKey: Key.reduceMotion) }
    }

    @Published private(set) var systemReduceMotion: Bool

    /// True when either the in-app switch or the system-wide Reduce Motion setting asks for
    /// less movement, so an iPad already configured for a child never shows the ambient loops.
    var motionReduced: Bool { reduceMotionEnabled || systemReduceMotion }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Key.soundEffects: true,
            Key.music: true,
            Key.haptics: true,
            Key.reduceMotion: false
        ])
        self.soundEffectsEnabled = defaults.bool(forKey: Key.soundEffects)
        self.musicEnabled = defaults.bool(forKey: Key.music)
        self.hapticsEnabled = defaults.bool(forKey: Key.haptics)
        self.reduceMotionEnabled = defaults.bool(forKey: Key.reduceMotion)
        self.systemReduceMotion = UIAccessibility.isReduceMotionEnabled

        NotificationCenter.default.addObserver(
            forName: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.systemReduceMotion = UIAccessibility.isReduceMotionEnabled
            }
        }
    }

    /// Returns nil when motion is reduced, which makes SwiftUI apply the change instantly.
    func animation(_ animation: Animation?) -> Animation? {
        motionReduced ? nil : animation
    }

    func calmEverything() {
        soundEffectsEnabled = false
        musicEnabled = false
        hapticsEnabled = false
        reduceMotionEnabled = true
    }

    func restoreDefaults() {
        soundEffectsEnabled = true
        musicEnabled = true
        hapticsEnabled = true
        reduceMotionEnabled = false
    }
}
