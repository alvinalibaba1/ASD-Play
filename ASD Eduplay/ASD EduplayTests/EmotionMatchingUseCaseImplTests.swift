import XCTest
@testable import ASD_Eduplay

final class EmotionMatchingUseCaseImplTests: XCTestCase {
    private var useCase: EmotionMatchingUseCaseImpl!

    override func setUp() {
        super.setUp()
        useCase = EmotionMatchingUseCaseImpl()
    }

    func test_checkAnswer_trueOnlyWhenSelectedMatchesTarget() {
        XCTAssertTrue(useCase.checkAnswer(selected: .happy, target: .happy))
        XCTAssertFalse(useCase.checkAnswer(selected: .happy, target: .sad))
    }

    /// Runs createRound() many times to catch a flaky option-generation bug
    /// (e.g. the target missing from its own options, or duplicate options)
    /// that a single call could easily miss.
    func test_createRound_alwaysIncludesTargetExactlyOnceAmongThreeUniqueOptions() {
        for _ in 0..<200 {
            let round = useCase.createRound()

            XCTAssertEqual(round.options.count, 3)
            XCTAssertEqual(Set(round.options).count, 3, "options must not contain duplicates")
            XCTAssertEqual(round.options.filter { $0 == round.target }.count, 1, "target must appear exactly once")
        }
    }

    func test_createRound_targetVariesAcrossManyRounds() {
        let targets = Set((0..<50).map { _ in useCase.createRound().target })

        // With 6 possible emotions and 50 draws, seeing only one target would
        // indicate the "random" selection is broken, not just unlucky.
        XCTAssertGreaterThan(targets.count, 1)
    }
}
