import SwiftUI

@available(iOS 17.0, *)
final class NavigationHandler {
    
    private let container: DepedencyContainer
    
    init(container: DepedencyContainer) {
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
            SortingPuzzleView(viewModel: self.container.makeCorrectPuzzleViewModel())
        case .tracingPuzzle:
            TracingPuzzleView(viewModel: self.container.makeTracingPuzzleViewModel())
        }
    }
}
