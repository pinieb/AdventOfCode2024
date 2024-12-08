func gcd(_ x: Int, _ y: Int) -> Int {
  var a = 0
  var b = max(x, y)
  var r = min(x, y)
  
  while r != 0 {
      a = b
      b = r
      r = a % b
  }

  return b
}

func lcm(_ x: Int, _ y: Int) -> Int {
  x / gcd(x, y) * y
}
