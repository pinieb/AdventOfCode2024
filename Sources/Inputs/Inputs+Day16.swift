extension Inputs {
  enum Day16 {
    static let exampleOne = """
    ###############
    #.......#....E#
    #.#.###.#.###.#
    #.....#.#...#.#
    #.###.#####.#.#
    #.#.#.......#.#
    #.#.#####.###.#
    #...........#.#
    ###.#.#####.#.#
    #...#.....#.#.#
    #.#.#.###.#.#.#
    #.....#...#.#.#
    #.###.#.#.#.#.#
    #S..#.....#...#
    ###############
    """

    static let exampleTwo = """
    #################
    #...#...#...#..E#
    #.#.#.#.#.#.#.#.#
    #.#.#.#...#...#.#
    #.#.#.#.###.#.#.#
    #...#.#.#.....#.#
    #.#.#.#.#.#####.#
    #.#...#.#.#.....#
    #.#.#####.#.###.#
    #.#.#.......#...#
    #.#.###.#####.###
    #.#.#...#.....#.#
    #.#.#.#####.###.#
    #.#.#.........#.#
    #.#.#.#########.#
    #S#.............#
    #################
    """

    static let puzzle = """
    #############################################################################################################################################
    #...#.....#.......#...........#...#.............#.......#.........#.....................#.............#.........#.....#.......#.........#..E#
    #.#.#.#.###.#.###.#####.#.#.#.#.#.#.###.#######.#######.#.#####.###.#.#######.###.#.#.#.#.#.###.#####.###.#####.#.###.#.###.#.#######.#.#.#.#
    #.#...................#.....#...#.#.#.#.......#.........#.....#.....#.........#...#.#.#.#.#.........#.....#...#...#...#.#...#...#.....#...#.#
    ###.#.#.#.#####.#####.#.#.#######.#.#.#######.#######.#######.###########.#####.#.###.#.#.#########.#######.#.#.###.#####.#####.#.###.#####.#
    #...#.#...#...#.#.#...#...#...#...#...#.....#.....#.#.#...#.............#...#...#.#...#...#.......#.....................#.#.....#...#.....#.#
    #.###.#####.#.#.#.#.###.#.###.#.#####.#.###.#####.#.#.#.#.#.#####.#.###.#####.#####.#########.#.#.#####.#.#####.#.###.#.#.#.#######.#.###.#.#
    #.....#...#.#.#.#...#...#...#.......#.#...#...#...#...#.#...#...#.#...#.......#.....#.........#...#.....#.....#.#.#...#...#.#.......#...#.#.#
    #.#####.###.#.#.#.###.#.###.#.#######.###.#.#.#.#.#####.#####.#.#.###.###.#####.#####.#############.#####.###.#.#.###.#####.###.#####.#.#.#.#
    #.......#...#...#...#...#...#.#.....#.....#...#.#.#.....#.....#...#...#...#...#.....#...#...........#.#...#.#...#...#...#.....#...#.....#...#
    #####.###.#####.###.###.#.#.###.###.#######.###.#.#.#########.#.###.#######.#.#####.###.#.###########.#.###.###.###.#.#.#####.###.#.#.#.###.#
    #...#.#...#.......#.......#.#...#...#.....#.#.#.#.#...#...#...#.#...#.....#.#.........#.#.....#.........#.....#.....#.#.....#.....#.#.#.#...#
    #.###.#.###.###.###########.#.###.#.#.#.#.#.#.#.#####.#.#.#.###.#.#.#.###.#.#########.#.#####.#.#####.###.###.#######.#####.#######.#.#.#.###
    #.....#.#.......#.......................#.#.....................#.#.#...#...#.......#.......#.#.#...#.#...#.#.#.#.........#.#.....#.#.#.#...#
    #.#####.#.#####.#.#.#.#######.#.#.#.#.#.#.#.#.###.#######.#####.#.#####.#####.###.#.#######.#.###.#.#.###.#.#.#.#.#########.#.###.###.#.###.#
    #.....#.#.....#...#.#.#.........#.#.#.#.....#...#.........#...#.#.........#...#.....#...#...#.#...#.#...#.#.#.#...#.....#...#...#...#.......#
    #######.#####.#####.#.#####.###.#.###.###.#.#.#####.#######.#.###########.#.###.#####.###.###.#.###.###.#.#.#.#####.###.#.###.#.###.#.###.###
    #.......#...#.#...#...#...#...#.#.....#...#...#...#.......#.#.#.......#...#.#.#.#...#.....#.#...#.#.#.#...#...#.....#...#.#...#.#.#...#...#.#
    #.#######.#.#.###.#####.#.#.#.#.#######.#######.#.#.#######.#.#.#####.###.#.#.#.#.#.#.#####.#.#.#.#.#.#####.###.#.###.###.#.###.#.###.#.###.#
    #...#...#.#.............#.#...#...#.....#...#...#...#.........#...#.#...#.#.#.....#.#.......#.....#.#.....#.....#...#.#...#...#.#.....#.....#
    ###.#.#.#.#########.#.###.###.###.###.###.#.#.#.###.#.#######.###.#.###.###.#.###.#.#######.#######.#.###.#######.#.#.#.#######.#.#########.#
    #...#.#...#...#.......#.........#...#.#...#.#.....#...#.....#...#.#.........#.....#.............#...#...#.#.....#.#.....#.......#.........#.#
    #.#####.###.#.###############.#####.#.#.###.#####.#######.#####.#.#####################.#########.#####.#.#.#####.#####.#.#.###.#######.###.#
    #.#...#.#...#.......#.....#.......#...#...#.......#.......#.....#.#...#.....#.........#...........#.....#.#.#.....#.....#.#...#.........#...#
    #.#.#.###.#########.#.###.#.###.###.#.###.#.#######.#.#####.###.#.#.#.###.#.#.#####.#.#.#########.#.#.#.#.#.#.#####.#.#####.#.#.#####.###.###
    #...#...#.#.....#.#.#...#...#.#.......#.....#.....#.#.....#...#.....#...#.#.#.#...#.#.#.............#...#...#.#...#.#.#...#.#.......#.#...#.#
    #.#####.#.#.###.#.#.###.#####.#########.#####.###.###.#.#.###.#.#######.#.###.#.#.#.###.#############.#.#.#.#.#.###.#.#.#.#######.#.###.###.#
    #.#...#.....#.....#.....#.....#.......#.....#...#...#...#...#.#.....#...#.......#.#.#...#...#.......#.#.#.#...#.#...#...#.#.....#.#.#...#...#
    #.#.#.#.#########.###########.#.###.#######.###.###.#######.#.###.###.#############.#.#####.#.#####.###.#.#.###.#.#######.#.###.#.#.#.###.#.#
    #.#.#.#...#...#.#.....#.....#...#.#.#.....#...#.#.#.#.......#...#.#...#.........#...#.......#.#...#...#.#.#.#...#.#.....#.#.#...#.#...#...#.#
    #.#.#.#.###.#.#.#####.###.#.#.###.#.#.###.#.#.#.#.#.#.#####.###.#.#.###.#######.#.#######.###.#.#.###.#.#.#.#.#.#.#.###.#.#.#.###.#####.###.#
    #.#.#.#.#...#.#.#...#.#...#.#.#...#.....#...#.....#.#.....#.#.#.#.#.#.......#...#.......#.#...#.#...#.#.#.#.#.#...#.#...#...#...#.#.....#...#
    ###.#.###.###.#.#.#.#.#.###.#.#.#.#########.#######.#.###.#.#.#.###.#######.#.#######.###.#.#####.###.#.###.#.###.#.###.#######.#.#.#######.#
    #...#.....#.#.#.#.#...#.#...#.#.#...#.......#.......#...#.....#.....#...#.....#.......#...#.#.....#...#.#...#.....#...#.........#.#...#...#.#
    #.#########.#.#.#.#####.###.#.###.#.#.#####.#.#########.#.#########.#.#.#.###.#.#######.###.#.#.###.#.#.#.#########.#.#########.#.###.#.#.#.#
    #...#.......#.#.#.#.......#.#...#.#...#.....#...........#.#...#.............#.#.#.......#.#.#.#...#...#.#.#.......#.#...#.......#.....#.#.#.#
    ###.#.#####.#.#.#.#######.#.###.#.#.#####.###########.#.###.#.#.#####.#####.#.#.#.#######.#.###.#.###.#.#.###.###.#.###.#.#####.#.#####.#.#.#
    #...#.....#...#.......#...#...#...#.#...#...#...#.....#.....#.#.#...#.#...#.....#.........#...#.#...#...#.....#.#.#.#.#.#.#.#...#.#.....#.#.#
    #.#######.###########.#.#.###.###.#.#.#.###.#.#.#.#.#######.#.#.#.#.#.###.#.#######.#####.###.#.###.###.#####.#.#.#.#.#.#.#.#.#.###.#####.#.#
    #.#.......#.........#...#...#...#.#...#...#.#.#...#.#.....#.#.......#...#.#...#.....#...#.#.#.#...#...#.#.......#.#...#...#.#.#.......#...#.#
    #.#.#########.###.#.#######.###.#########.#.#.#####.#.#.#.#####.#.###.#.#.#.###.###.#.#.#.#.#.#####.#.#.#.#####.#.#######.#.#.#.#######.###.#
    #.#.#.........#...#...#.....#...#.........#.#.#.....#.#.#.....#.#...........#...#.....#.#...#.....#.#.#.#.#...#.#.#.....#...#.#.....#...#.#.#
    #.#.###.#########.###.#.#.###.###.###.#####.#.###.###.#.#####.###.#####.#.###.###.#####.#.#######.#.###.#.#.#.#.#.#.###.#####.#.###.#.###.#.#
    #.#.....#.#.........#.#.........#.#...#.....#.....#...#.....#...#.#...#.#...#.#...#.....#.#.......#...#.#...#.#.#...#...#...#.......#.#...#.#
    #.#######.#.#.#.#.###.#.#######.#.#.###.#####.#.#.#.#######.###.#.#.###.#.#.#.#.###.#######.#######.#.#.#####.#.#####.###.#.###.#####.#.###.#
    #.............#.#.#...#.#.....#...#.....#...#.#.#.#.#...#.........#.....#.#...#...#.......#...#.....#.......#.#.#...#.......#.........#.....#
    #.#.#.#.#####.#.#.#.###.#.###.#####.#####.#.#.#.#.#.#.###.#.#######.###.#.#.#####.#######.#.#.###########.#.#.#.#.#.###.###.#.#.#.#####.#####
    #.#.#.#.#...#.#.#.#.#...#.#...#.....#...#.#.#.#.#.#.#...#.......#.#.....#...#...#...#...#.#.#...........#.....#...#...#...#.#.#.#.....#.#...#
    #.#.#.#.#.#.#.#.#.#.#.###.#.###.#####.#.#.#.#.#.#.#.###.#######.#.#####.###.#.#####.###.#.#####.#######.###.#######.#.###.#.#.#.#####.#.#.#.#
    #.....#...#...#...#.#...#.#...#...#...#...#...#.#.#...#.......#.....#.....#.#.....#...#.......#.#.....#...#...#.....#.....#.#.#.#.....#...#.#
    #.#.#.#.#####.###.#.###.#.###.###.###.###.###.#.#####.#.#.###.#.###.#.###.#.###.#####.#######.#.#.###.###.#.#.#.###.#.#.#.#.#.#.#.#########.#
    #.#.#.#.#...#.....#...#.#.#.#.#.......#...#...#.#.....#.#...#.#...#.....#.......#...#.......#.#.#...#.....#.#...#...#...#.#...#...#.........#
    #.#.#.###.#.#.###.###.###.#.#.#.#######.###.###.#.#####.#.#.#.###.###.###.#######.#.#######.#.###.#.#.#####.#.#.#.#######.#####.###.#########
    #.#.#.#...#...#...#...#...#...#.#...#...#...#.....#.....#...#...#...#.#...#.......#.........#...#.#.#.#...#.#...#.......#...#.....#.#.....#.#
    #.###.#.#.###.#.###.###.###.#####.#.###.#.#######.#####.#.###.#####.###.###.###################.###.###.#.#.###########.###.#.#.#.#.#.#.#.#.#
    #...#...#...#.#.#...#.....#.......#...#.#.......#.....#.#.#...#...#.....#...#...#...........#.....#.#...#.#...........#.....#.#.#...#.#.#.#.#
    ###.#####.#.#.#.#.#.#.###.###########.#.#######.#####.###.#####.#.#######.###.#.#.#####.#.#.#.###.#.#.###.###.#######.#######.#.#######.#.#.#
    #...#...#.#.#.#...#.#...#.#.......#...#...#.....#...#.....#...#.#.....#...#...#...#...#.#.#...#...#.#...#.#...#.....#.#.....#.#.........#.#.#
    #.###.#.#.#.#.###.#.###.#.#.#####.#.#####.#.#######.###.#.#.#.#.#####.#.###.#########.#.#.#####.###.#.###.#####.###.###.###.#.#.#########.#.#
    #.#...#.#.#...#.....#.#.#.#.#...#.#.......#.......#.#...#...#.....#...#.#.....#.......#.#.#...#.#.....#...#.....#.#.....#.#...#.............#
    #.#.#.#.#.###.#.#####.#.#.#.###.#.#######.#.#####.#.#.#####.#######.###.#####.#.#####.#.#.#.#.#.#######.###.#####.#######.#######.###.#.###.#
    #...#.#...#...#.#.......#.#...#.....#...#.#.....#.#.#.#...#.......#...#.....#.#.#...#.#...#.#...#.....#...#.#.#.......#.........#.#...#.....#
    #.###.###.#.#.#.#########.###.#.#####.#.#.#######.#.#.#.#.#.#####.#.#.#####.#.#.#.#.#.#.###.#####.###.###.#.#.#.###.###.#.#.###.#.#.###.#####
    #.#...#...#.#.............#...#.#.....#...#.......#.#...#...#...#.#.#.#.....#.#.#.#.#.#.....#.#...#.#.....#.#.#.#.#.....#...#.#.#.#.#.#...#.#
    #.#.###.#.#.#.###.#.#.#####.#####.#######.#.#######.#########.###.#.#.#.#####.#.#.#.###.#.###.#.#.#.#####.#.#.#.#.###.###.###.#.#.#.#.###.#.#
    #.#...#.#...#...#...#.#...#.........#...#...#.#.............#...#...#.#.#.....#...#.....#...#...#.#.....#.#.#.....#...#...#.#...#.#.#.....#.#
    #.###.#######.#.#.#.###.#.###########.#.#####.#.#########.###.#.###.#.#.###.###.#####.#####.###.#.#.###.#.#.#######.#.#.###.#.###.#.#.#####.#
    #.....#.......#...#.....#.#...........#.#...#...#.....#.#...#.#.....#.#...#...#.#...#.#...#...#.#.#...#...#.#.....#.#.#.#...#.......#.#.....#
    #.#.###.#######.#########.#.#####.#####.#.#.#.###.###.#.###.#.#######.###.###.#.#.#.#.###.###.###.###.#####.#.###.#.#.#.#.###.#.#####.#.#####
    #.#.....#.....#.#.#.....#...#...#...#...#.#.#.#...#.#...#.#.#.........#...#...#.#.#.#.#.....#.#...#.#.#.....#...#...#.#.#.....#...#...#.....#
    #.#.#######.#.#.#.#.###.###.#.#.#####.###.#.#.###.#.###.#.#.#########.#.###.###.#.#.#.#.#####.#.###.#.#.#####.#.#####.#.#####.#.#.#.#######.#
    #.#.......#.#...#.#.#.#...#.#.#...#.......#.....#.#.....#.#.....#.....#.#.....#.#.#.#...#.....#.#.....#.#...#.#...#.#.......#.#.#.#.........#
    #.#######.#.#####.#.#.###.#.#.###.#.#######.###.#.###.###.#####.#.#######.###.###.#.###.#.#####.#.#####.#.###.###.#.#.#####.###.#.#########.#
    #...#.#...#...#...#.#...#.#.#.#...#.#.....#...#.#...#.....#.....#.......#.#...#.......#.#...#...#.#.....#.......#.#.#.......#...#.#...#...#.#
    #.#.#.#.#####.#.#.#.#.###.###.#.#.#.#.###.###.#.#.#.#####.#.#.#########.#.#.###.#####.#.###.#.#####.#########.###.#.#.#.###.#.#.#.#.#.#.#.#.#
    #.#.#.#...#.....#.#.#...#.....#.#...#...#.....#.#.#...#...#.#.#.........#.....#.#.#...#.#.#.#.......#.......#.#...#.#.#.#...#.#.#.#.#.#.#...#
    ###.#.###.#######.#.#.#.#######.###.###.#######.#.###.#####.###.#.###.#.#.###.#.#.#.###.#.#.#####.###.#####.###.###.#.#.###.#.#.#.#.###.#####
    #...#...#.......#...#.#.......#...#...#.........#...#.....#.....#...#.#.#...#.#...#.#.#...#.....#.#.....#.......#.....#...#.#.#...#...#...#.#
    #.#####.#######.#.###.#####.#####.###.#.#####.###.#######.#########.#.#.#####.#.###.#.#.#######.#.###.#.#########.#######.#.#.#.#.###.###.#.#
    #.#...#.......#.#...#.#...#.#...#.....#.#.........#.......#...#...#.#.#.....#...#...#...#.....#.#...#.#...#.............#.#.........#.....#.#
    #.#.#.#.###.#.#.#.#.#.#.#.#.#.#.###.###.###########.#####.#.#.#.###.#.#####.#####.###.###.###.#.###.#.###.#############.#.###.#.#.#.#.#####.#
    #.#.#.#.#...#.#.#.#.#.#.#...#.#.......#.#...........#.....#.#...#...#.#...#.....#.#.#...#.#.#...#.#.#.#...#.......#.......#...#...#.#.#...#.#
    #.#.#.#.#.#####.#.#.###.###.#.#######.#.#.#.#########.#####.#####.###.###.#####.#.#.###.#.#.#####.#.###.###.#####.#########.#####.#.#.#.#.#.#
    #...#.#.#.......#.#...#...#.#.#.....#.....#.#...#...........#.....#.#.........#...#...#.#.#...#...#.#...#...#.#...#.......#.#.#...#.#...#...#
    #.#.#.#.#.#########.#.###.###.#####.#########.#.#.#########.#.#####.#####.###########.#.#.#.#.#.#.#.#.#.#.###.#.###.#####.#.#.#.#.#.#####.#.#
    #...#...#.#.......#.#...#.#...#...#.....#.............#.....#...#.#.......#...........#.#.#.#.#.#.#...#...#...#.#...#...#.#.#.......#.......#
    #.#.###.#.###.###.#####.#.#.###.#.#.#####.###########.###.#.###.#.#.#######.###.#######.#.#.#.#.#.#####.#.#.###.#.###.#.#.#.###.#.#.#######.#
    #.#...#.#...#...#.......#...#...#.#.....#...#...#.....#...#.#.#.......#.....#.#.....#.....#.#.#.#...#.....#.....#.#...#...#...#.#.#.#.....#.#
    #.###.#.###.###.#########.###.###.#####.###.#.#.#.#.#.#.###.#.#.#.#####.#####.#####.#.###.#.#.#.###.#.#.#.#.#####.#####.#####.###.#.#.###.###
    #...............#.#.....#.#...#...#.......#...#.#.#.#.#.......#.#.#.....#.........#...#.#.#.#.#.........#.#.....#.....#.......#...#.#.#.#...#
    #.#####.#.#######.#.###.#.#.#.###.#.#.#.#.#####.#.#.#.#####.#.#.###.#####.###.#.#.#####.#.#.#####.#######.#####.#.###.#########.#.#.#.#.###.#
    #.#...#...#.....#...#.#...#.#...#.#.#.#.......#.#.#.#.#...#...#.....#...#...#.#.#.#.......#.........#...#.#.....#...#.......#...#.#.#.#.#...#
    #.#.#.#.###.#.###.###.#########.#.#.#.#.#.#####.#.###.#.#.###.#######.#####.#.#.#.#####.#.#.#########.#.#.###.#########.###.#.#.###.#.#.#.#.#
    #.#.#.#...#.#.#...#.....#.......#...#...#.#.....#...#.#.#.#.#.#.....#.#.....#.#.......#.#.#.#...#.....#.#...#...#.....#...#.#.#...#...#.#...#
    #.#.#.#.#.###.#.#####.#.###.#############.#.#####.#.#.#.#.#.#.#.###.#.#.#.###.#.#####.#.#.###.#.#.#####.###.#.#.#.###.#####.#.###.#####.###.#
    #.#.#...#...#.........#.....#.....#.....#.#.#.....#.#...#.#.#...#.....#.#.#...#.......#.#.....#...#...#.....#.#...#.#.....#.#...#.........#.#
    #.###.#.###.#.###.#.#########.###.#.#####.#.#.#####.#####.#.#.#.#######.#.#.###.#######.###########.#.#######.#####.#####.#.###.#########.#.#
    #...#.#.#...#.#...#...#.........#.#.......#.#.#...#.......#.#.#.#.....#.#.#.#.#.......#...........#.#.#.#.......#.......#.#.#...#.......#.#.#
    #.#.#.#.#.###.#####.#.#.#########.#.###.###.###.#.###.###.#.#.#.#.###.#.#.#.#.#######.#.#########.#.#.#.#.#.#####.#.###.#.#.#.###.#####.#.#.#
    #.#.#.#.#.#.......#.#.....#.......#.......#.....#.#...#...#.#.#...#...#...#.#...........#.......#.#.#...#.#.......#.#...#.#.#...#.....#.#...#
    #.#.###.#.#######.#########.#.#####.#######.#####.#.#.#.###.#.#.###.###.###.#.###########.#.#.#.#.#.#.###.###.#.###.#.###.#.###.#####.#.#####
    #.#.#...#.....#.......#.....#...#...#.......#...#...#.#.#.#...#.#.#.....#.....#.#...........#.......#.........#.#...#...#.#.#...#.....#.#...#
    #.#.#.#.#####.#######.#.#####.#.#####.#.#.###.#.#####.#.#.#.###.#.#######.###.#.#.###########.#######.#####.#.#.#.#.#.#.#.#.#.###.#######.#.#
    #.#.#.......#.....#.....#.....#.....#.#.....#.#...#...#.#...#.#.....#.#...#.....#...#.....#...#.....#.#.....#.#...#.....#...#...#.#.......#.#
    #.#.#.###.#.###.#.#######.#########.#.#######.###.#####.#.###.#####.#.#.###########.#####.#.###.###.#.#.###.#.###.#.###.#######.#.#.#######.#
    #...#.#.#.#.#...#.#...#...#.#.....#...#...#...#.#...#...#.#...#.....#.#.#...........#.....#...#.#.#...#.#...#.....#...#...#...#.#.#.#.....#.#
    #.###.#.#.###.#.#.#.#.#.###.#.###.#####.###.###.###.#.###.#.###.#####.#.#.#########.#.#####.#.#.#.#####.#.#####.#####.###.#.###.#.#.#.###.#.#
    #...#.#.#...#.#.#...#...#.....#.#.....#...#.#.....#.#.#.#.#.........#.#.......#...#...#...#.#.#.#...#...#...#...#...#.#.....#...#...#.#...#.#
    ###.#.#.###.#.#.###########.###.#####.#.#.#.#.#.###.#.#.#.#########.#.#########.#.#.###.#.###.#.#.#.###.###.#.#####.#.#######.###.#####.#.#.#
    #...#.#...#...#.....#.....#.........#...#.#.#.#.......#...#.......#...#.........#.#.#...#...#.#.#.#.....#.#...#.....#.......#.#.#.#...#.#.#.#
    #.#.#.###.#####.###.###.#.#####.#########.#.###########.###.#####.###.#.#########.###.#####.#.#.#.#####.#.#####.###.#####.#.#.#.#.#.#.#.###.#
    #...#.....#...#.#.#.#...#.#.#...#.........#.#.......#.....#.#.....#...#...#...........#.......#...#...#.........#.#.....#...#.#.....#...#...#
    #.#.#####.#.#.#.#.#.#.###.#.#.###.#######.#.#.#####.#####.#.#.#####.#####.#.###.#######.#######.#.###.###########.#.###.#.###.###########.#.#
    #...#.....#.#.#.#.#...#...#.#.#...#...#.#.#.#.#...#.....#...#.#...#.#.....#.....#...#...#.......#...#.......#.......#...#.....#...#.....#.#.#
    ###.###.###.#.#.#.#####.###.#.#.###.#.#.#.#.#.#.###.#.#.#####.#.#.#.#.#.#####.#.#.#.#####.#########.#.#####.#.#####.#.#########.#.#.###.#.#.#
    #.#...#.#.#.#...#.....#.#.....#.....#...#.#.....#...#.#...#.......#.#.#.#.....#.#.#.......#.#.......#.....#.#.#...#.#.#...#.....#...#.#.#.#.#
    #.#.#.#.#.#.#####.#.###.#######.#.#.#.#.#.#####.#.#.#.###.#######.#.#.###.#####.#.#########.#.###.#######.#.#.###.#.#.#.#.###.#######.#.#.#.#
    #.....#...#.....#.#.#...#.....#.#.#.#...#.......#.#.#...#...#...#.#.#.#.....#...#.......#...#.#.#.....#...#.#.....#...#.#...#.....#.......#.#
    #.#.#####.#####.#.###.###.###.#.#.#.#########.###.#.#######.#.#.#.###.#.#####.#########.#.###.#.#####.#.###.#.#.#######.###.#.###.#########.#
    #.....#...#...#.#...#.#.....#.....#.......#...#...#.........#.#.#...#.#.#.#...#.......#.#...#.......#.#...#.#.#.........#.#.#.#.#.....#.....#
    #####.###.###.#.###.#.#.###.#####.#####.###.###.#############.#####.#.#.#.#.###.#.#####.#.#.###.#####.#####.#.#####.#.###.#.#.#.#####.###.###
    #...#...#.....#.....#.#.#...#...#.....#...#.#...#.....#...........#.#.#...........#...#.#.#.....#.....#.....#.....#.#.#.....#...#...#...#...#
    #.#.###.#########.#.#.###.###.###.###.###.#.#.#####.#.#.#########.#.#.###.#######.#.#.#.#.#######.###.#.#.#.###.#.###.#.#####.###.#.#.#.###.#
    #.#...#...........#.#.#...#.......#.....#.#.#.....#.#.#...#...#.#.#.#.#...#.....#.#.#...#.......#.#...#.#.#.....#.....#.#...#.#...#.#.#.#.#.#
    #.#.###############.#.#.###.#######.###.#.#.#####.#.#####.#.#.#.#.#.#.#.#.#.###.#.#.#####.###.###.#.###.#.#.###.#######.#.#.#.#.###.###.#.#.#
    #.#.#.......#.....#...#...#.......#...#...#.......#.....#...#...#.....#.#...#...#.#.......#.#.#...#.#...#.#...#.#.....#.....#.#.............#
    #.###.###.###.###.#.#####.#######.#.#.#########.#.#.#.###.###.#.#######.#.#.#.###.#######.#.#.#.#####.###.###.###.#.#######.#.#.#########.#.#
    #...#.#.#.......#.#.#...#...#...#...#.......#...#.#.#.......#.#.#.......#.#.#.#...#...#...#...#...#.....#.#...#...#.......#.#.#.....#...#...#
    #.#.#.#.#########.#.#.#.###.#.#####.#######.#.###.#.#.#.#.#.#.#.#.#######.#.#.#.###.#.#.#########.#.#####.#.#.#.#####.#####.#.#####.#.#.#.###
    #.#.#.....#...#...................#.....#.#.#.#.#.#...#.#.#...#.#...#.....#.#.#.....#...#.......#.....#...#.#.#.#...................#.#.#...#
    #.#.#####.#.###.#.###.#######.#.#.#####.#.#.#.#.#.#.#.#.#.#.###.###.#######.#.#############.###.#######.###.#.#.###.#.#.#.#.#####.#####.###.#
    #.#.........#...#.#...#.......#.#.....#...#.#...#.#.#...#...#...#...#.......#.........#...#.#...........#...#.#.....#.#.#...#...#.#.....#...#
    #.###########.###.#.#.#.###.###.#.#.#####.#.###.#.###.###.###.###.###.#######.#######.#.#.#.#############.#####.#####.#.#####.#.#.#.#.###.###
    #...#...#.#...#...#.#.#...#.#...#.#.#.....#.#...#...#...........#.....#.......#...#...#.#.#...#...........#.....#.....#.#.....#...#.#...#.#.#
    ###.#.#.#.#.###.###.#.###.#.#.###.#.#.#####.#.#####.#.###.#############.#.#.###.#.#.###.#.###.#######.#####.#####.###.#.#.###.#####.###.#.#.#
    #.#...#...#.#.#.#...#.#...#...#...#.#.....#.#...#.#.#...#...#.....#.....#.#.#...#.#.....#...#.......#.#.....#...#.#...#.#...#.#...#.#.#.#...#
    #.#####.###.#.#.#.###.#.#######.#.###.#####.###.#.#.#####.#.#.#.###.#####.#.#.###.#########.#.#####.#.#.#####.###.#.###.###.#.#.#.#.#.#.###.#
    #.....#.#...#...#.#.#...#.....#...#...#.................#.#...........................#...#.#.#.....#.#.#.....#...#.#...#...#.#.#.#.#.#.....#
    #.###.#.#.#######.#.#######.#.###.#.###.#########.#.#.#.#.#######.###.#.###.###.#####.#.#.#.#.#.#####.#.#####.#.#####.#######.#.#.#.#.#######
    #S..#...#...................#...#.....#...........#...#.........#.....#.............#...#.......#.............#...............#.#...........#
    #############################################################################################################################################
    """
  }
}