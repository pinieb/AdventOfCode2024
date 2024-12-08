protocol Grid {
  var rows: Int { get }
  var columns: Int { get }
}

extension Grid {
  func isValid(position: GridPosition) -> Bool {
    guard position.row >= 0, position.row < rows else { return false }
    guard position.column >= 0, position.column < columns else { return false }

    return true
  }

  func makeNextPosition(
    from position: GridPosition, 
    direction: Direction
  ) -> GridPosition {
    let offset: GridPosition
    switch direction {
      case .south:
        offset = GridPosition(row: 1, column: 0)
      case .southeast:
        offset = GridPosition(row: 1, column: 1)
      case .east:
        offset = GridPosition(row: 0, column: 1)
      case .northeast:
        offset = GridPosition(row: -1, column: 1)
      case .north:
        offset = GridPosition(row: -1, column: 0)
      case .northwest:
        offset = GridPosition(row: -1, column: -1)
      case .west:
        offset = GridPosition(row: 0, column: -1)
      case .southwest:
        offset = GridPosition(row: 1, column: -1)
    }

    return GridPosition(
      row: position.row + offset.row, 
      column: position.column + offset.column
    )
  }
}
