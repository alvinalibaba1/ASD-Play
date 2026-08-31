import XCTest
@testable import ASD_Eduplay

@MainActor
final class ProgressStoreTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "ProgressStoreTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func test_freshStore_hasEmptyProgressForEveryGame() {
        let store = ProgressStore(defaults: defaults)

        let progress = store.progress(for: .jigsaw)

        XCTAssertEqual(progress.sessionsPlayed, 0)
        XCTAssertEqual(progress.roundsCompleted, 0)
        XCTAssertEqual(progress.correctCount, 0)
        XCTAssertEqual(progress.incorrectCount, 0)
        XCTAssertNil(progress.lastPlayedAt)
    }

    func test_recordSessionStart_incrementsSessionsAndSetsLastPlayed() {
        let store = ProgressStore(defaults: defaults)

        store.recordSessionStart(.matching)
        store.recordSessionStart(.matching)

        let progress = store.progress(for: .matching)
        XCTAssertEqual(progress.sessionsPlayed, 2)
        XCTAssertNotNil(progress.lastPlayedAt)
    }

    func test_recordCorrectAndIncorrect_trackedIndependentlyPerGame() {
        let store = ProgressStore(defaults: defaults)

        store.recordCorrect(.sorting)
        store.recordCorrect(.sorting)
        store.recordIncorrect(.sorting)

        XCTAssertEqual(store.progress(for: .sorting).correctCount, 2)
        XCTAssertEqual(store.progress(for: .sorting).incorrectCount, 1)
        // A different game's counters must stay untouched.
        XCTAssertEqual(store.progress(for: .tracing).correctCount, 0)
    }

    func test_recordRoundCompleted_incrementsRoundsCompleted() {
        let store = ProgressStore(defaults: defaults)

        store.recordRoundCompleted(.causeEffect)

        XCTAssertEqual(store.progress(for: .causeEffect).roundsCompleted, 1)
    }

    func test_resetAll_clearsEveryGamesProgress() {
        let store = ProgressStore(defaults: defaults)
        store.recordCorrect(.jigsaw)
        store.recordSessionStart(.emotionMatching)

        store.resetAll()

        XCTAssertEqual(store.progress(for: .jigsaw).correctCount, 0)
        XCTAssertEqual(store.progress(for: .emotionMatching).sessionsPlayed, 0)
    }

    func test_progressPersistsAcrossStoreInstancesSharingTheSameDefaults() {
        let firstInstance = ProgressStore(defaults: defaults)
        firstInstance.recordCorrect(.routineSequencing)
        firstInstance.recordRoundCompleted(.routineSequencing)

        let secondInstance = ProgressStore(defaults: defaults)

        let progress = secondInstance.progress(for: .routineSequencing)
        XCTAssertEqual(progress.correctCount, 1)
        XCTAssertEqual(progress.roundsCompleted, 1)
    }
}
