import XCTest
@testable import ASD_Eduplay

private final class FakeSortingPuzzleRepository: SortingPuzzleRepository {
    private let themes: [SortingPuzzleTheme]
    private var currentThemeIndex = 0

    init(themes: [SortingPuzzleTheme]) {
        self.themes = themes
    }

    func getThemes() -> [SortingPuzzleTheme] { themes }
    func getCurrentThemeIndex() -> Int { currentThemeIndex }
    func updateThemeIndex(_ index: Int) { currentThemeIndex = index % themes.count }
}

final class SortingPuzzleUseCaseImplTests: XCTestCase {
    private let workspaceA = Workspace(id: "workspaceA", position: .zero, color: .red, label: "Red")
    private let workspaceB = Workspace(id: "workspaceB", position: .zero, color: .blue, label: "Blue")

    private func makePiece(id: String, targetWorkspaceId: String, isPlaced: Bool = false) -> SortingPuzzlePiece {
        var piece = SortingPuzzlePiece(id: id, targetWorkspaceId: targetWorkspaceId, initialPosition: .zero, color: .red)
        piece.isPlaced = isPlaced
        return piece
    }

    func test_checkPiecePlacement_trueOnlyWhenTargetMatchesWorkspace() {
        let useCase = SortingPuzzleUseCaseImpl(themeRepository: FakeSortingPuzzleRepository(themes: []))
        let piece = makePiece(id: "A", targetWorkspaceId: "workspaceA")

        XCTAssertTrue(useCase.checkPiecePlacement(piece: piece, workspace: workspaceA))
        XCTAssertFalse(useCase.checkPiecePlacement(piece: piece, workspace: workspaceB))
    }

    func test_isPuzzleComplete_trueOnlyWhenEveryPieceIsPlaced() {
        let useCase = SortingPuzzleUseCaseImpl(themeRepository: FakeSortingPuzzleRepository(themes: []))
        let allPlaced = [makePiece(id: "A", targetWorkspaceId: "workspaceA", isPlaced: true),
                          makePiece(id: "B", targetWorkspaceId: "workspaceB", isPlaced: true)]
        let onePending = [makePiece(id: "A", targetWorkspaceId: "workspaceA", isPlaced: true),
                           makePiece(id: "B", targetWorkspaceId: "workspaceB", isPlaced: false)]

        XCTAssertTrue(useCase.isPuzzleComplete(pieces: allPlaced))
        XCTAssertFalse(useCase.isPuzzleComplete(pieces: onePending))
    }

    func test_updatePiecePosition_movesPositionWithoutChangingOtherFields() {
        let useCase = SortingPuzzleUseCaseImpl(themeRepository: FakeSortingPuzzleRepository(themes: []))
        let piece = makePiece(id: "A", targetWorkspaceId: "workspaceA")
        let newPosition = CGPoint(x: 42, y: 99)

        let updated = useCase.updatePiecePosition(piece: piece, to: newPosition)

        XCTAssertEqual(updated.currentPosition, newPosition)
        XCTAssertEqual(updated.id, piece.id)
        XCTAssertEqual(updated.targetWorkspaceId, piece.targetWorkspaceId)
    }

    func test_getNextTheme_cyclesThroughThemesAndWrapsAround() {
        let theme1 = SortingPuzzleTheme(id: 1, colorA: .red, labelA: "Red", colorB: .blue, labelB: "Blue")
        let theme2 = SortingPuzzleTheme(id: 2, colorA: .green, labelA: "Green", colorB: .yellow, labelB: "Yellow")
        let repository = FakeSortingPuzzleRepository(themes: [theme1, theme2])
        let useCase = SortingPuzzleUseCaseImpl(themeRepository: repository)

        XCTAssertEqual(useCase.getNextTheme().id, 1)
        XCTAssertEqual(useCase.getNextTheme().id, 2)
        // Wraps back to the first theme instead of crashing or returning stale data.
        XCTAssertEqual(useCase.getNextTheme().id, 1)
    }
}
