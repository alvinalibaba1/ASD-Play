import CoreGraphics

/// Pure geometry helper for judging which board cell a dropped Jigsaw piece
/// belongs to - extracted out of JigsawPuzzleViewModel.handlePieceDrop so
/// this logic (the source of two separate drop-related bugs earlier: exact-
/// point matching being too strict, then a coordinate-space mismatch) can be
/// unit tested directly, without needing a full ViewModel/UseCase/Haptic/
/// Audio stack.
enum JigsawDropMatcher {
    /// Judges a drop by how much of the piece (a pieceSize x pieceSize square
    /// centered on the release point) overlaps each board cell, rather than
    /// the single point where the finger lifted - a piece that's clearly
    /// hovering mostly over the right quadrant lands there even if the
    /// fingertip itself ends up a bit outside the board or over a
    /// neighboring cell. Returns nil if no cell has at least a quarter of the
    /// piece's area overlapping it.
    static func bestMatchingCell(
        dropPoint: CGPoint,
        boardFrame: CGRect,
        pieceSize: CGFloat,
        rows: Int,
        cols: Int
    ) -> (row: Int, col: Int)? {
        guard pieceSize > 0, rows > 0, cols > 0 else { return nil }

        let pieceRect = CGRect(
            x: dropPoint.x - pieceSize / 2,
            y: dropPoint.y - pieceSize / 2,
            width: pieceSize,
            height: pieceSize
        )

        var bestCell: (row: Int, col: Int)?
        var bestOverlapArea: CGFloat = 0

        for row in 0..<rows {
            for col in 0..<cols {
                let cellRect = CGRect(
                    x: boardFrame.minX + CGFloat(col) * pieceSize,
                    y: boardFrame.minY + CGFloat(row) * pieceSize,
                    width: pieceSize,
                    height: pieceSize
                )
                let overlap = cellRect.intersection(pieceRect)
                let overlapArea = overlap.isNull ? 0 : overlap.width * overlap.height
                if overlapArea > bestOverlapArea {
                    bestOverlapArea = overlapArea
                    bestCell = (row, col)
                }
            }
        }

        let minimumOverlapArea = (pieceSize * pieceSize) * 0.25
        guard let cell = bestCell, bestOverlapArea >= minimumOverlapArea else { return nil }
        return cell
    }
}
