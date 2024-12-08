import Foundation

struct SearchableGrid<Element: Equatable>: Grid {
  let data: [[Element]]

  let columns: Int
  let rows: Int

  init(elements: [[Element]]) {
    self.data = elements

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

    guard data[position.row][position.column] == current else { 
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
}

extension SearchableGrid: DisplayableData {
  var displayData: [AttributedString] {
    var output = [AttributedString]()
    
    for row in 0..<rows {
      var outputRow = AttributedString("")
      
      for col in 0..<columns {
        outputRow += AttributedString("\(data[row][col])")
      }

      output.append(outputRow)
    }

    return output
  }
}
