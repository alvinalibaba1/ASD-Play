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
                    Text("Progress")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    Text("How things are going across each game.")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

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
                    .padding(.horizontal, 40)

                    Button {
                        Haptic.shared.tap()
                        showResetConfirmation = true
                    } label: {
                        Label("Reset Progress", systemImage: "trash")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                            .padding(.vertical, 12)
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
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(color)
                            .shadow(color: color.opacity(0.4), radius: 5, x: 0, y: 3)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color.black.opacity(0.8))
                    Text(lastPlayedText)
                        .font(.system(size: 14))
                        .foregroundColor(Color.black.opacity(0.5))
                }

                Spacer()
            }

            HStack(spacing: 0) {
                StatColumn(value: "\(progress.sessionsPlayed)", label: "Sessions")
                StatColumn(value: "\(progress.roundsCompleted)", label: "Rounds")
                StatColumn(value: accuracyText, label: "Accuracy")
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(progress.sessionsPlayed) sessions, \(progress.roundsCompleted) rounds completed, \(accuracyText) accuracy, \(lastPlayedText)")
    }
}

private struct StatColumn: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color.black.opacity(0.8))
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Color.black.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}
