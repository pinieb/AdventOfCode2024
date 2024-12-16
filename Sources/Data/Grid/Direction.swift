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

  func rotate(direction: RotationDirection, mode: CompassMode) -> Self {
    switch (self, direction, mode) {
    case (.south, .clockwise, .cardinal): .west
    case (.south, .clockwise, .intercardinal): .southwest
    case (.south, .counterClockwise, .cardinal): .east
    case (.south, .counterClockwise, .intercardinal): .southeast
    case (.north, .clockwise, .cardinal): .east
    case (.north, .clockwise, .intercardinal): .northeast
    case (.north, .counterClockwise, .cardinal): .west
    case (.north, .counterClockwise, .intercardinal): .northwest
    case (.east, .clockwise, .cardinal): .south
    case (.east, .clockwise, .intercardinal): .southeast
    case (.east, .counterClockwise, .cardinal): .north
    case (.east, .counterClockwise, .intercardinal): .northeast
    case (.west, .clockwise, .cardinal): .north
    case (.west, .clockwise, .intercardinal): .northwest
    case (.west, .counterClockwise, .cardinal): .south
    case (.west, .counterClockwise, .intercardinal): .southwest
    case (.southeast, .clockwise, .intercardinal): .south
    case (.southeast, .counterClockwise, .intercardinal): .east
    case (.southwest, .clockwise, .intercardinal): .west
    case (.southwest, .counterClockwise, .intercardinal): .south
    case (.northwest, .clockwise, .intercardinal): .north
    case (.northwest, .counterClockwise, .intercardinal): .west
    case (.northeast, .clockwise, .intercardinal): .east
    case (.northeast, .counterClockwise, .intercardinal): .north
    default: self
    }
  }
}

enum RotationDirection {
  case clockwise
  case counterClockwise
}

enum CompassMode {
  case cardinal
  case intercardinal
}
