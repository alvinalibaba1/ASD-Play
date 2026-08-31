import XCTest
@testable import ASD_Eduplay

private struct FakeRoutineSequencingUseCase: RoutineSequencingUseCase {
    let sets: [RoutineSet]
    func getRoutineSets() -> [RoutineSet] { sets }
}

@MainActor
final class RoutineSequencingViewModelTests: XCTestCase {
    private let steps = [
        RoutineStep(id: "s1", order: 1, imageName: "wake_up", title: "Wake Up"),
        RoutineStep(id: "s2", order: 2, imageName: "clothes", title: "Get Dressed"),
        RoutineStep(id: "s3", order: 3, imageName: "breakfast", title: "Eat Breakfast")
    ]

    private func makeViewModel() -> RoutineSequencingViewModel {
        let routineSet = RoutineSet(id: 1, name: "Morning Routine", steps: steps)
        return RoutineSequencingViewModel(useCase: FakeRoutineSequencingUseCase(sets: [routineSet]))
    }

    func test_selectingStepsInOrder_placesThemInSequence() {
        let viewModel = makeViewModel()

        viewModel.selectStep(steps[0])
        viewModel.selectStep(steps[1])

        XCTAssertEqual(viewModel.placedSteps.map(\.id), ["s1", "s2"])
        // scrambledSteps starts shuffled, so only membership/count is stable,
        // not order.
        XCTAssertEqual(Set(viewModel.scrambledSteps.map(\.id)), ["s3"])
    }

    func test_selectingStepOutOfOrder_doesNotPlaceItAndFlagsItAsWrong() {
        let viewModel = makeViewModel()

        // Skip ahead to step 2 without placing step 1 first.
        viewModel.selectStep(steps[1])

        XCTAssertTrue(viewModel.placedSteps.isEmpty)
        XCTAssertEqual(Set(viewModel.scrambledSteps.map(\.id)), ["s1", "s2", "s3"])
        XCTAssertEqual(viewModel.lastWrongStepId, "s2")
    }

    func test_selectingCorrectStepAfterAWrongOne_stillWorks() {
        let viewModel = makeViewModel()

        viewModel.selectStep(steps[2]) // wrong: expects order 1 first
        viewModel.selectStep(steps[0]) // correct

        XCTAssertEqual(viewModel.placedSteps.map(\.id), ["s1"])
        XCTAssertEqual(Set(viewModel.scrambledSteps.map(\.id)), ["s2", "s3"])
    }

    func test_placingEveryStep_fillsTheWholeSequence() {
        let viewModel = makeViewModel()

        viewModel.selectStep(steps[0])
        viewModel.selectStep(steps[1])
        viewModel.selectStep(steps[2])

        XCTAssertEqual(viewModel.placedSteps.map(\.id), ["s1", "s2", "s3"])
        XCTAssertTrue(viewModel.scrambledSteps.isEmpty)
    }
}
