struct GridPosition: Hashable, Equatable, CustomStringConvertible {
  let row: Int
  let column: Int

  var description: String { "(\(row), \(column))"}
}

extension GridPosition: AdditiveArithmetic {
  static var zero: GridPosition {
    GridPosition(row: 0, column: 0)
  }
  
  static func + (lhs: GridPosition, rhs: GridPosition) -> GridPosition {
    GridPosition(row: lhs.row + rhs.row, column: lhs.column + rhs.column)
  }

  static func - (lhs: GridPosition, rhs: GridPosition) -> GridPosition {
    GridPosition(row: lhs.row - rhs.row, column: lhs.column - rhs.column)
  }

  var unitVector: GridPosition {
    let basis = gcd(row, column)
    guard basis != 0 else { return self }

    return GridPosition(row: row / basis, column: column / basis)
  }
}

extension GridPosition {
  static func * (lhs: Int, rhs: GridPosition) -> GridPosition {
    GridPosition(row: lhs * rhs.row, column: lhs * rhs.column)
  }

  static func * (lhs: GridPosition, rhs: Int) -> GridPosition {
    rhs * lhs
  }
}
