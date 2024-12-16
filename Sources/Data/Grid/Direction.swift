enum Direction: CaseIterable, Hashable {
  case south
  case southeast
  case east
  case northeast
  case north
  case northwest
  case west
  case southwest

  static var cardinal: [Direction] {
    [.north, .east, .south, .west]
  }

  var opposite: Direction {
    switch self {
    case .south: .north
    case .southeast: .northwest
    case .east: .west
    case .northeast: .southwest
    case .north: .south
    case .northwest: .southeast
    case .west: .east
    case .southwest: .northeast
    }
  }
}
