import Foundation

struct SearchableGrid<Element: Equatable> {
  private let grid: [[Element]]

  private let columns: Int
  private let rows: Int

  init(elements: [[Element]]) {
    self.grid = elements

    self.rows = elements.count
    self.columns = elements.first?.count ?? 0
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
        outputRow += AttributedString("\(grid[row][col])")
      }

      output.append(outputRow)
    }

    return output
  }
}
