import SwiftUI

final class NavigationHandler {

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }
    
    @MainActor 
    @ViewBuilder
    func view(for destination: Destination) -> some View {
        switch destination {
        case .intro:
            IntroView()
        case .credit:
            CreditView()
        case .menu:
            MenuView()
        case .sensorySettings:
            SensorySettingsView()
        case .progressSummary:
            ProgressSummaryView()
        case .jigsawPuzzle:
            JigsawPuzzleView(viewModel: self.container.makeJigsawPuzzleViewModel())
        case .matchingPuzzle:
            MatchingPuzzleView(viewModel: self.container.makeMatchingPuzzleViewModel())
        case .sortingPuzzle:
            SortingPuzzleView(viewModel: self.container.makeSortingPuzzleViewModel())
        case .tracingPuzzle:
            TracingPuzzleView(viewModel: self.container.makeTracingPuzzleViewModel())
        case .emotionMatching:
            EmotionMatchingView(viewModel: self.container.makeEmotionMatchingViewModel())
        case .routineSequencing:
            RoutineSequencingView(viewModel: self.container.makeRoutineSequencingViewModel())
        case .causeEffect:
            CauseEffectView(viewModel: self.container.makeCauseEffectViewModel())
        }
    }
}
