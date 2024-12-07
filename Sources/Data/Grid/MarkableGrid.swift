import Foundation

struct MarkableGrid<Element: Equatable> {
  private let grid: [[Element]]

  let columns: Int
  let rows: Int

  private(set) var marks: [[Bool]]

  init(elements: [[Element]]) {
    self.grid = elements

    self.rows = elements.count
    self.columns = elements.first?.count ?? 0

    self.marks = [[Bool]](repeating: [Bool](repeating: false, count: columns), count: rows)
  }

  mutating func markElements(at positions: [GridPosition]) {
    for position in positions where isValid(position: position) {
      marks[position.row][position.column] = true
    }
  }

  private func isValid(position: GridPosition) -> Bool {
    guard position.row >= 0, position.row < rows else { return false }
    guard position.column >= 0, position.column < columns else { return false }

    return true
  }
}

extension MarkableGrid: DisplayableData {
  var displayData: [AttributedString] {
    var output = [AttributedString]()
    
    for row in 0..<rows {
      var outputRow = AttributedString("")
      
      for col in 0..<columns {
        var cell = AttributedString("\(grid[row][col])")

        if marks[row][col] {
          cell.foregroundColor = .green
        }

        outputRow += cell
      }

      output.append(outputRow)
    }

    return output
  }
}
