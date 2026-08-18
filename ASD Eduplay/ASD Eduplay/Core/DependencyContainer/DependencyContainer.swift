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
    private let emotionMatchingUseCase: EmotionMatchingUseCase
    private let routineSequencingUseCase: RoutineSequencingUseCase
    private let causeEffectUseCase: CauseEffectUseCase

    private init() {
        self.sortingPuzzleRepository = SortingPuzzleRepositoryImpl()
        self.tracingPuzzleRepository = TracingPuzzleRepositoryImpl()
        self.jigsawPuzzleRepository = JigsawPuzzleRepositoryImpl()
        self.jigsawUseCase = JigsawPuzzleUseCaseImpl(repository: jigsawPuzzleRepository)
        self.matchingPuzzleUseCase = MatchingPuzzleUseCaseImpl()
        self.sortingPuzzleUseCase = SortingPuzzleUseCaseImpl(themeRepository: sortingPuzzleRepository)
        self.tracingPuzzleUseCase = TracingPuzzleUseCaseImpl(repository: tracingPuzzleRepository)
        self.emotionMatchingUseCase = EmotionMatchingUseCaseImpl()
        self.routineSequencingUseCase = RoutineSequencingUseCaseImpl()
        self.causeEffectUseCase = CauseEffectUseCaseImpl()
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

    func makeEmotionMatchingViewModel() -> EmotionMatchingViewModel {
        return EmotionMatchingViewModel(useCase: emotionMatchingUseCase)
    }

    func makeRoutineSequencingViewModel() -> RoutineSequencingViewModel {
        return RoutineSequencingViewModel(useCase: routineSequencingUseCase)
    }

    func makeCauseEffectViewModel() -> CauseEffectViewModel {
        return CauseEffectViewModel(useCase: causeEffectUseCase)
    }
}
