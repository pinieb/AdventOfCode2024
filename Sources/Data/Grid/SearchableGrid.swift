import Foundation

struct SearchableGrid<Element: Equatable> {
  private let grid: [[Element]]

  private let columns: Int
  private let rows: Int

  private(set) var wasFound: [[Bool]]

  init(elements: [[Element]]) {
    self.grid = elements

    self.rows = elements.count
    self.columns = elements.first?.count ?? 0

    self.wasFound = [[Bool]](repeating: [Bool](repeating: false, count: columns), count: rows)
  }

  func findSequence(
    _ sequence: any Collection<Element>, 
    directions: [Direction]
  ) -> [[(element: Element, position: GridPosition)]] {
    var matches = [[(Element, GridPosition)]]()

    for row in 0..<rows {
      for column in 0..<columns {
        for direction in directions {
          guard let match = findSequence(
            sequence, 
            position: GridPosition(row: row, column: column), 
            direction: direction
          ) else {
            continue
          }

          matches.append(match)
        }
      }
    }

    return matches
  }

  private func findSequence(
    _ sequence: any Collection<Element>, 
    position: GridPosition, 
    direction: Direction
  ) -> [(Element, GridPosition)]? {
    guard let current = sequence.first else {
      return []
    }

    guard isValid(position: position) else { 
      return nil
    }

    guard grid[position.row][position.column] == current else { 
      return nil 
    }

    let nextPosition = makeNextPosition(from: position, direction: direction)

    guard let match = findSequence(
      sequence.dropFirst(), 
      position: nextPosition, 
      direction: direction
    ) else {
      return nil
    }

    return [(current, position)] + match
  }

  mutating func markSequence(
    _ sequence: any Collection<Element>, 
    directions: [Direction] = Direction.allCases
  ) -> Int {
    guard !sequence.isEmpty else { return 0 }

    var markedCount = 0

    for row in 0..<rows {
      for column in 0..<columns {
        for direction in directions {
          if markSequence(
            sequence, 
            position: GridPosition(row: row, column: column), 
            direction: direction
          ) {
            markedCount += 1
          }
        }
      }
    }

    return markedCount
  }

  private mutating func markSequence(
    _ sequence: any Collection<Element>, 
    position: GridPosition, 
    direction: Direction
  ) -> Bool {
    guard let current = sequence.first else {
      return true
    }

    guard isValid(position: position) else { 
      return false
    }

    guard grid[position.row][position.column] == current else { 
      return false 
    }

    let nextPosition = makeNextPosition(from: position, direction: direction)

    let shouldMark = markSequence(sequence.dropFirst(), position: nextPosition, direction: direction)

    guard shouldMark else {
      return false
    }

    wasFound[position.row][position.column] = true
    return true
  }

  private func makeNextPosition(
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

  private func isValid(position: GridPosition) -> Bool {
    guard position.row >= 0, position.row < rows else { return false }
    guard position.column >= 0, position.column < columns else { return false }

    return true
  }
}

extension SearchableGrid: DisplayableData {
  var displayData: [AttributedString] {
    var output = [AttributedString]()
    
    for row in 0..<rows {
      var outputRow = AttributedString("")
      
      for col in 0..<columns {
        var cell = AttributedString("\(grid[row][col])")

        if wasFound[row][col] {
          cell.foregroundColor = .green
        }

        outputRow += cell
      }

      output.append(outputRow)
    }

    return output
  }
}
