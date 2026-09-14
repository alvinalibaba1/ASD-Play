import XCTest
@testable import ASD_Eduplay

final class SoundMatchUseCaseImplTests: XCTestCase {
    private var useCase: SoundMatchUseCaseImpl!

    override func setUp() {
        super.setUp()
        useCase = SoundMatchUseCaseImpl()
    }

    func test_checkAnswer_trueOnlyWhenSelectedMatchesTarget() {
        let bell = SoundMatchItem(id: "bell", imageName: "bell", soundName: "bell", label: "Bell")
        let dog = SoundMatchItem(id: "dog", imageName: "dog 2", soundName: "dog", label: "Dog")

        XCTAssertTrue(useCase.checkAnswer(selected: bell, target: bell))
        XCTAssertFalse(useCase.checkAnswer(selected: bell, target: dog))
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

        // With 6 possible items and 50 draws, seeing only one target would
        // indicate the "random" selection is broken, not just unlucky.
        XCTAssertGreaterThan(targets.count, 1)
    }
}
