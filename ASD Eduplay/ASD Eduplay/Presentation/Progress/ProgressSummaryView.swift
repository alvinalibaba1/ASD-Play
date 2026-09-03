import SwiftUI

struct ProgressSummaryView: View {
    @ObservedObject private var store = ProgressStore.shared
    @State private var showResetConfirmation = false

    private let games: [(kind: GameKind, title: String, icon: String, color: Color)] = [
        (.jigsaw, "Jigsaw Puzzle", "jigsawIcon", .cyan),
        (.matching, "Matching", "matchingIcon", .brown),
        (.sorting, "Sorting", "sortingIcon", .green),
        (.tracing, "Tracing", "tracingIcon", .orange),
        (.emotionMatching, "Feelings", "feelingsIcon", .purple),
        (.routineSequencing, "My Routine", "routineIcon", .teal),
        (.causeEffect, "Tap & Play", "tapPlayIcon", .yellow)
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

            // Matches MenuView/CreditView's light Color.white.opacity(0.2)
            // tint instead of a flat, strongly-colored Color.purple.opacity
            // (0.45) - that flattened the illustration into a solid block
            // and, since ProgressButton (the button that leads here) is
            // orange, purple didn't even match its own entry point.
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
                    // A single icon before the title reads as a clean label;
                    // two flanking bar-chart icons was busier than it needed
                    // to be, and a generic dashboard icon doesn't carry the
                    // same playful "this is a title" cue that the stars do
                    // on MenuView's "Choose Puzzle".
                    HStack(spacing: 12) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 30))

                        Text("Progress")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 20)

                    Text("How things are going across each game.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.black.opacity(0.6))
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

    private var totalAttempts: Int { progress.correctCount + progress.incorrectCount }

    private var accuracyFraction: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(progress.correctCount) / Double(totalAttempts)
    }

    private var accuracyText: String {
        guard totalAttempts > 0 else { return "No attempts yet" }
        return "\(Int((accuracyFraction * 100).rounded()))% correct"
    }

    private var lastPlayedText: String {
        guard let date = progress.lastPlayedAt else { return "Not played yet" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                // Matches CompactMenuButton's treatment: these illustrated
                // icons already carry their own color, so a soft tinted
                // backdrop lets the artwork show through instead of another
                // solid fill competing with it.
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(width: 54, height: 54)
                    .background(
                        Circle()
                            .fill(color.opacity(0.15))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 21, weight: .bold, design: .rounded))
                        .foregroundColor(Color.black.opacity(0.85))
                    Text(lastPlayedText)
                        .font(.system(size: 14))
                        .foregroundColor(Color.black.opacity(0.5))
                }

                Spacer(minLength: 4)
            }

            // A filled bar rather than a bare "X%" - the number alone required
            // reading and interpreting it as good/bad, while a bar reads as
            // "progress" at a glance the same way the rest of the app already
            // uses fill/dim/checkmark cues during actual gameplay.
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Accuracy")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.black.opacity(0.6))
                    Spacer()
                    Text(accuracyText)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(color.opacity(0.15))

                        if totalAttempts > 0 {
                            Capsule()
                                .fill(color)
                                .frame(width: max(10, geometry.size.width * accuracyFraction))
                        }
                    }
                }
                .frame(height: 20)
            }

            // Two evenly-sized chips with their own soft background instead
            // of a plain inline icon-number-label row - separating the two
            // stats into their own boxes (matching the soft-background-chip
            // language used elsewhere in the app, e.g. RoutineSequencing's
            // slots) makes each one read as its own distinct fact at a
            // glance instead of one dense run-on line.
            HStack(spacing: 12) {
                statChip(icon: "play.circle.fill", value: "\(progress.sessionsPlayed)", label: "Sessions")
                statChip(icon: "checkmark.seal.fill", value: "\(progress.roundsCompleted)", label: "Rounds Done")
            }
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.95))
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 3)
        )
        .overlay(
            // .strokeBorder rather than .stroke - see MenuButton's identical
            // fix for why .stroke reads thin/uneven at a rounded corner.
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(color, lineWidth: 3)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(progress.sessionsPlayed) sessions, \(progress.roundsCompleted) rounds completed, \(accuracyText), \(lastPlayedText)")
    }

    private func statChip(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.85))
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.black.opacity(0.55))
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(color.opacity(0.1))
        )
    }
}
