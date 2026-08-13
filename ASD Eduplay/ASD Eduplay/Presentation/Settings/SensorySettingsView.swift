import SwiftUI

struct SensorySettingsView: View {
    @EnvironmentObject var settings: SensorySettings
    @EnvironmentObject var router: NavigationRouter

    var body: some View {
        ZStack {
            Color.blue.opacity(0.8)
                .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    CustomBackButton()
                        .padding(.leading, 20)
                    Spacer()
                }
                .padding(.top, 20)

                Spacer()
            }
            .zIndex(1)

            ScrollView {
                VStack(spacing: 24) {
                    Text("Sensory Settings")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    Text("Adjust the sound, movement and vibration to whatever feels comfortable.")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    VStack(spacing: 16) {
                        SensoryToggleRow(
                            title: "Music",
                            subtitle: "Background music while playing",
                            icon: "music.note",
                            color: .purple,
                            isOn: $settings.musicEnabled
                        )

                        SensoryToggleRow(
                            title: "Sound Effects",
                            subtitle: "Taps, cheers and try-again sounds",
                            icon: "speaker.wave.2.fill",
                            color: .cyan,
                            isOn: $settings.soundEffectsEnabled
                        )

                        SensoryToggleRow(
                            title: "Vibration",
                            subtitle: "Buzz when you place a piece",
                            icon: "iphone.radiowaves.left.and.right",
                            color: .orange,
                            isOn: $settings.hapticsEnabled
                        )

                        SensoryToggleRow(
                            title: "Reduce Motion",
                            subtitle: settings.systemReduceMotion
                                ? "Already on in your iPad's accessibility settings"
                                : "Calmer screens with less movement",
                            icon: "wind",
                            color: .green,
                            // Shown as on-and-locked when iPadOS already forces reduced motion,
                            // so the switch never contradicts what the child actually sees.
                            isOn: settings.systemReduceMotion ? .constant(true) : $settings.reduceMotionEnabled,
                            isLocked: settings.systemReduceMotion
                        )
                    }
                    .padding(.horizontal, 40)

                    VStack(spacing: 14) {
                        Button {
                            Haptic.shared.tap()
                            settings.calmEverything()
                            AudioPlayerManager.shared.applyMusicSetting(enabled: false)
                        } label: {
                            Label("Quiet Mode", systemImage: "moon.fill")
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .foregroundColor(.blue)
                                .padding(.vertical, 20)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityHint("Turns off music, sound, vibration and movement all at once")

                        Button {
                            Haptic.shared.tap()
                            router.navigate(to: .progressSummary)
                        } label: {
                            Label("View Progress", systemImage: "chart.bar.fill")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.85))
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Button {
                            Haptic.shared.tap()
                            settings.restoreDefaults()
                            AudioPlayerManager.shared.applyMusicSetting(enabled: true)
                        } label: {
                            Text("Reset to default")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
            .padding(.top, 90)
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: settings.musicEnabled) { enabled in
            AudioPlayerManager.shared.applyMusicSetting(enabled: enabled)
        }
        .onChange(of: settings.soundEffectsEnabled) { enabled in
            if !enabled { AudioPlayerManager.shared.stopAudio() }
        }
    }
}

struct SensoryToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    @Binding var isOn: Bool
    var isLocked: Bool = false

    var body: some View {
        HStack(spacing: 18) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(color.opacity(isLocked ? 0.4 : 1))
                        .shadow(color: color.opacity(0.4), radius: 5, x: 0, y: 3)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.8))

                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(Color.black.opacity(0.5))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .disabled(isLocked)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
    }
}
