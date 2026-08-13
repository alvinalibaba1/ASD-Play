import SwiftUI

struct ProgressSummaryView: View {
    @ObservedObject private var store = ProgressStore.shared
    @State private var showResetConfirmation = false

    private let games: [(kind: GameKind, title: String, icon: String, color: Color)] = [
        (.jigsaw, "Jigsaw Puzzle", "puzzlepiece.fill", .cyan),
        (.matching, "Matching", "equal.circle.fill", .brown),
        (.sorting, "Sorting", "arrow.up.and.down.circle.fill", .green),
        (.tracing, "Tracing", "hand.draw.fill", .orange)
    ]

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

            Color.purple.opacity(0.45)
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
                    HStack(spacing: 10) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 28))

                        Text("Progress")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 28))
                    }
                    .padding(.top, 20)
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 2)

                    Text("How things are going across each game.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 1)

                    VStack(spacing: 16) {
                        ForEach(games, id: \.kind) { game in
                            GameProgressCard(
                                title: game.title,
                                icon: game.icon,
                                color: game.color,
                                progress: store.progress(for: game.kind)
                            )
                        }
                    }
                    .padding(.horizontal, 24)

                    Button {
                        Haptic.shared.tap()
                        showResetConfirmation = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 15))
                            Text("Reset Progress")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 22)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.25))
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 40)
                }
            }
            .padding(.top, 90)
        }
        .navigationBarBackButtonHidden(true)
        .alert("Reset all progress?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                store.resetAll()
            }
        } message: {
            Text("This clears sessions, rounds and accuracy for every game. This can't be undone.")
        }
    }
}

private struct GameProgressCard: View {
    let title: String
    let icon: String
    let color: Color
    let progress: GameProgress

    private var accuracyText: String {
        let total = progress.correctCount + progress.incorrectCount
        guard total > 0 else { return "—" }
        let percent = Int((Double(progress.correctCount) / Double(total) * 100).rounded())
        return "\(percent)%"
    }

    private var lastPlayedText: String {
        guard let date = progress.lastPlayedAt else { return "Not played yet" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(color)
                            .shadow(color: color.opacity(0.4), radius: 5, x: 0, y: 3)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color.black.opacity(0.8))
                    Text(lastPlayedText)
                        .font(.system(size: 13))
                        .foregroundColor(Color.black.opacity(0.5))
                }

                Spacer(minLength: 4)
            }

            HStack(spacing: 8) {
                StatPill(value: "\(progress.sessionsPlayed)", label: "Sessions", color: color)
                StatPill(value: "\(progress.roundsCompleted)", label: "Rounds", color: color)
                StatPill(value: accuracyText, label: "Accuracy", color: color)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.95))
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color, lineWidth: 2.5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(progress.sessionsPlayed) sessions, \(progress.roundsCompleted) rounds completed, \(accuracyText) accuracy, \(lastPlayedText)")
    }
}

private struct StatPill: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color.black.opacity(0.8))
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.black.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.12))
        )
    }
}
