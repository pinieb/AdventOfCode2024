import Foundation
import SwiftTUI

struct MarkableGrid<Element: Equatable>: Grid {
  var grid: [[Element]]

  private(set) var columns: Int
  private(set) var rows: Int

  private(set) var marks: [[Color?]]

  init(elements: [[Element]]) {
    self.grid = elements

    self.rows = elements.count
    self.columns = elements.first?.count ?? 0

    self.marks = [[Color?]](repeating: [Color?](repeating: nil, count: columns), count: rows)
  }

  mutating func markElements(at positions: [GridPosition], color: Color?) {
    for position in positions {
      markElement(at: position, color: color)
    }
  }

  mutating func markElement(at position: GridPosition, color: Color?) {
    guard isValid(position: position) else { return } 
      
    marks[position.row][position.column] = color
  }

  mutating func clearMarks() {
    marks = [[Color?]](repeating: [Color?](repeating: nil, count: columns), count: rows)
  }
}

extension MarkableGrid: DisplayableData {
  var displayData: [AttributedString] {
    var output = [AttributedString]()
    
    for row in 0..<rows {
      var outputRow = AttributedString("")
      
      for col in 0..<columns {
        var cell = AttributedString("\(grid[row][col])")

        if let color = marks[row][col] {
          cell.foregroundColor = color
        }

        outputRow += cell
      }

      output.append(outputRow)
    }

    return output
  }
}
