import SwiftUI

@MainActor
final class DependencyContainer {
    static let shared = DependencyContainer()

    private let sortingPuzzleRepository: SortingPuzzleRepository
    private let tracingPuzzleRepository: TracingPuzzleRepository
    private let jigsawPuzzleRepository: JigsawPuzzleRepository
    private let jigsawUseCase: JigsawPuzzleUseCase
    private let matchingPuzzleUseCase: MatchingPuzzleUseCase
    private let sortingPuzzleUseCase: SortingPuzzleUseCase
    private let tracingPuzzleUseCase: TracingPuzzleUseCase

    private init() {
        self.sortingPuzzleRepository = SortingPuzzleRepositoryImpl()
        self.tracingPuzzleRepository = TracingPuzzleRepositoryImpl()
        self.jigsawPuzzleRepository = JigsawPuzzleRepositoryImpl()
        self.jigsawUseCase = JigsawPuzzleUseCaseImpl(repository: jigsawPuzzleRepository)
        self.matchingPuzzleUseCase = MatchingPuzzleUseCaseImpl()
        self.sortingPuzzleUseCase = SortingPuzzleUseCaseImpl(themeRepository: sortingPuzzleRepository)
        self.tracingPuzzleUseCase = TracingPuzzleUseCaseImpl(repository: tracingPuzzleRepository)
    }

    func makeJigsawPuzzleViewModel() -> JigsawPuzzleViewModel {
        return JigsawPuzzleViewModel(jigsawUseCase: jigsawUseCase)
    }

    func makeMatchingPuzzleViewModel() -> MatchingPuzzleViewModel {
        return MatchingPuzzleViewModel(matchingUseCase: matchingPuzzleUseCase)
    }

    func makeSortingPuzzleViewModel() -> SortingPuzzleViewModel {
        return SortingPuzzleViewModel(sortingUseCase: sortingPuzzleUseCase)
    }

    func makeTracingPuzzleViewModel() -> TracingPuzzleViewModel {
        return TracingPuzzleViewModel(tracingUseCase: tracingPuzzleUseCase)
    }
}
