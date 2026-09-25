import SwiftUI

struct SensorySettingsView: View {
    @EnvironmentObject var settings: SensorySettings

    var body: some View {
        ZStack {
            GeometryReader { bgGeometry in
                Image("backgroundMenu")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: bgGeometry.size.width, height: bgGeometry.size.height)
                    .clipped()
            }
            .edgesIgnoringSafeArea(.all)

            // Matches MenuView/CreditView/ProgressSummaryView's light tint
            // instead of a flat, strongly-colored Color.blue.opacity(0.45) -
            // that flattened the illustration into a solid block, same issue
            // already fixed on every other screen except this one.
            Color.white.opacity(0.2)
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
                    // A single icon before the title instead of one flanking
                    // each side - matches the same simplification already
                    // made on the Progress screen's title.
                    HStack(spacing: 12) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 30))

                        Text("Sensory Settings")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    Text("Adjust the sound, movement and vibration to whatever feels comfortable.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.black.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    VStack(spacing: 16) {
                        SensoryToggleRow(
                            title: "Music",
                            subtitle: "Music while playing",
                            icon: "music.note",
                            color: .purple,
                            isOn: $settings.musicEnabled
                        )

                        SensoryToggleRow(
                            title: "Sound Effects",
                            subtitle: "Taps and cheer sounds",
                            icon: "speaker.wave.2.fill",
                            color: .cyan,
                            isOn: $settings.soundEffectsEnabled
                        )

                        SensoryToggleRow(
                            title: "Vibration",
                            subtitle: "Buzz on each tap",
                            icon: "iphone.radiowaves.left.and.right",
                            color: .orange,
                            isOn: $settings.hapticsEnabled
                        )

                        SensoryToggleRow(
                            title: "Reduce Motion",
                            subtitle: settings.systemReduceMotion
                                ? "Already on in device settings"
                                : "Calmer, less movement",
                            icon: "wind",
                            color: .green,
                            // Shown as on-and-locked when the OS already forces reduced motion,
                            // so the switch never contradicts what the child actually sees.
                            isOn: settings.systemReduceMotion ? .constant(true) : $settings.reduceMotionEnabled,
                            isLocked: settings.systemReduceMotion
                        )
                    }
                    .padding(.horizontal, 24)

                    VStack(spacing: 14) {
                        SensoryActionRow(
                            title: "Quiet Mode",
                            subtitle: "Turn everything off at once",
                            icon: "moon.fill",
                            color: .indigo
                        ) {
                            Haptic.shared.tap()
                            settings.calmEverything()
                            AudioPlayerManager.shared.applyMusicSetting(enabled: false)
                        }
                        .accessibilityHint("Turns off music, sound, vibration and movement all at once")

                        SensoryActionRow(
                            title: "Reset to Default",
                            subtitle: "Turn everything back on",
                            icon: "arrow.counterclockwise",
                            color: .blue
                        ) {
                            Haptic.shared.tap()
                            settings.restoreDefaults()
                            AudioPlayerManager.shared.applyMusicSetting(enabled: true)
                        }
                        .accessibilityHint("Turns music, sound and vibration back on")
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .padding(.top, 90)
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: settings.musicEnabled) { _, enabled in
            AudioPlayerManager.shared.applyMusicSetting(enabled: enabled)
        }
        .onChange(of: settings.soundEffectsEnabled) { _, enabled in
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
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 42, height: 42)
                .background(
                    Circle()
                        .fill(color.opacity(isLocked ? 0.4 : 1))
                        .shadow(color: color.opacity(0.4), radius: 5, x: 0, y: 3)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.8))

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(Color.black.opacity(0.5))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 8)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .disabled(isLocked)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.95))
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 3)
        )
        .overlay(
            // .strokeBorder rather than .stroke - see MenuButton's identical
            // fix for why .stroke reads thin/uneven at a rounded corner.
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(color, lineWidth: 2.5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
    }
}

struct SensoryActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    @State private var scale: CGFloat = 1.0

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 0.96
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                scale = 1.0
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 19))
                    .foregroundColor(.white)
                    .frame(width: 42, height: 42)
                    .background(
                        Circle()
                            .fill(color)
                            .shadow(color: color.opacity(0.4), radius: 5, x: 0, y: 3)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color.black.opacity(0.8))

                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(Color.black.opacity(0.5))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer(minLength: 8)

                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 18))
                    .foregroundColor(color.opacity(0.7))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.95))
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 3)
            )
            .overlay(
                // .strokeBorder rather than .stroke - see MenuButton's identical
                // fix for why .stroke reads thin/uneven at a rounded corner.
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(color, lineWidth: 2.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(scale)
    }
}
