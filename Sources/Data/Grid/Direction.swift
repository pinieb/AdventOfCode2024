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
}
