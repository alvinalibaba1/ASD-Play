import XCTest
@testable import ASD_Eduplay

final class JigsawDropMatcherTests: XCTestCase {
    private let boardFrame = CGRect(x: 100, y: 200, width: 300, height: 300)
    private let pieceSize: CGFloat = 150

    func test_dropAtCellCenter_matchesThatCell() {
        // Center of the top-left cell (row 0, col 0).
        let dropPoint = CGPoint(x: 175, y: 275)

        let result = JigsawDropMatcher.bestMatchingCell(
            dropPoint: dropPoint, boardFrame: boardFrame, pieceSize: pieceSize, rows: 2, cols: 2
        )

        XCTAssertEqual(result?.row, 0)
        XCTAssertEqual(result?.col, 0)
    }

    func test_dropAtBottomRightCellCenter_matchesThatCell() {
        let dropPoint = CGPoint(x: 325, y: 425)

        let result = JigsawDropMatcher.bestMatchingCell(
            dropPoint: dropPoint, boardFrame: boardFrame, pieceSize: pieceSize, rows: 2, cols: 2
        )

        XCTAssertEqual(result?.row, 1)
        XCTAssertEqual(result?.col, 1)
    }

    func test_dropMostlyOverACell_evenWithFingerOutsideThatCell_stillMatchesIt() {
        // Piece center sits just past the board's right edge, but most of the
        // piece square still overlaps the top-right cell - this is exactly
        // the "imprecise motor control" case this matcher exists for.
        let dropPoint = CGPoint(x: boardFrame.maxX + 20, y: 275)

        let result = JigsawDropMatcher.bestMatchingCell(
            dropPoint: dropPoint, boardFrame: boardFrame, pieceSize: pieceSize, rows: 2, cols: 2
        )

        XCTAssertEqual(result?.row, 0)
        XCTAssertEqual(result?.col, 1)
    }

    func test_dropFarOutsideBoard_matchesNoCell() {
        let dropPoint = CGPoint(x: boardFrame.maxX + 500, y: boardFrame.midY)

        let result = JigsawDropMatcher.bestMatchingCell(
            dropPoint: dropPoint, boardFrame: boardFrame, pieceSize: pieceSize, rows: 2, cols: 2
        )

        XCTAssertNil(result)
    }

    func test_dropGrazingBoardEdge_belowMinimumOverlap_matchesNoCell() {
        // Only a sliver of the piece overlaps the board - less than the 25%
        // minimum - so this should count as a miss, not a nearest-cell guess.
        let dropPoint = CGPoint(x: boardFrame.maxX + pieceSize / 2 - 5, y: 275)

        let result = JigsawDropMatcher.bestMatchingCell(
            dropPoint: dropPoint, boardFrame: boardFrame, pieceSize: pieceSize, rows: 2, cols: 2
        )

        XCTAssertNil(result)
    }

    func test_dropExactlyOnSharedCorner_matchesFirstIteratedCell() {
        // Dead center of the board - all 4 cells overlap the piece equally.
        // The tie-break is "first cell to reach that area wins," i.e. the
        // lowest (row, col) in iteration order.
        let dropPoint = CGPoint(x: boardFrame.midX, y: boardFrame.midY)

        let result = JigsawDropMatcher.bestMatchingCell(
            dropPoint: dropPoint, boardFrame: boardFrame, pieceSize: pieceSize, rows: 2, cols: 2
        )

        XCTAssertEqual(result?.row, 0)
        XCTAssertEqual(result?.col, 0)
    }

    func test_zeroPieceSize_matchesNoCell() {
        let result = JigsawDropMatcher.bestMatchingCell(
            dropPoint: boardFrame.origin, boardFrame: boardFrame, pieceSize: 0, rows: 2, cols: 2
        )

        XCTAssertNil(result)
    }
}
