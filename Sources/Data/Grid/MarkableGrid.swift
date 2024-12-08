import Foundation
import SwiftTUI

struct MarkableGrid<Element: Equatable>: Grid {
  var data: [[Element]]

  private(set) var columns: Int
  private(set) var rows: Int

  private(set) var marks: [[Color?]]

  init(elements: [[Element]]) {
    self.data = elements

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

  func countCells(marked: Color?) -> Int {
    var count = 0

    for row in 0..<rows {
      for column in 0..<columns where marks[row][column] == marked {
        count += 1
      }
    }

    return count
  }
}

extension MarkableGrid: DisplayableData {
  var displayData: [AttributedString] {
    var output = [AttributedString]()
    
    for row in 0..<rows {
      var outputRow = AttributedString("")
      
      for col in 0..<columns {
        var cell = AttributedString("\(data[row][col])")

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

extension MarkableGrid where Element == Character {
  init(grid: String) {
    self = MarkableGrid(elements: grid.lines.map { Array($0) })
  }
}
