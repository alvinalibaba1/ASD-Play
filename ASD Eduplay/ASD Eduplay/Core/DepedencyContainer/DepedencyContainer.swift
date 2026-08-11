import SwiftUI

@MainActor
@available(iOS 17.0, *)
final class DepedencyContainer {
    static let shared = DepedencyContainer()
    
    private let correctPuzzleRepository: CorrectPuzzleRepository
    private let tracingPuzzleRepository: TracingPuzzleRepository
    private let jigsawPuzzleRepository: JigsawPuzzleRepository
    private let jigsawUseCase: JigsawPuzzleUseCase
    private let matchingPuzzleUseCase: MatchingPuzzleUseCase
    private let correctPuzzleUseCase: CorrectPuzzleUseCase
    private let tracingPuzzleUseCase: TracingPuzzleUseCase
    
    private init() {
        self.correctPuzzleRepository = CorrectPuzzleRepositoryImpl()
        self.tracingPuzzleRepository = TracingPuzzleRepositoryImpl()
        self.jigsawPuzzleRepository = JigsawPuzzleRepositoryImpl()
        self.jigsawUseCase = JigsawPuzzleUseCaseImpl(repository: jigsawPuzzleRepository)
        self.matchingPuzzleUseCase = MatchingPuzzleUseCaseImpl()
        self.correctPuzzleUseCase = CorrectPuzzleUseCaseImpl(themeRepository: correctPuzzleRepository)
        self.tracingPuzzleUseCase = TracingPuzzleUseCaseImpl(repository: tracingPuzzleRepository)
    }
    
    
    func makeJigsawPuzzleViewModel() -> JigsawPuzzleViewModel {
        return JigsawPuzzleViewModel(jigsawUseCase: jigsawUseCase)
    }
    
    func makeMatchingPuzzleViewModel() -> MatchingPuzzleViewModel {
        return MatchingPuzzleViewModel(matchingUseCase: matchingPuzzleUseCase)
    }
    
    func makeCorrectPuzzleViewModel() -> SortingPuzzleViewModel {
        return SortingPuzzleViewModel(sortingUseCase: correctPuzzleUseCase)
    }
    
    func makeTracingPuzzleViewModel() -> TracingPuzzleViewModel {
        return TracingPuzzleViewModel(tracingUseCase: tracingPuzzleUseCase)
    }
}

