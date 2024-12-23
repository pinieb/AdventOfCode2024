extension Inputs {
  enum Day18 {
    static let example = """
    7
    12
    5,4
    4,2
    4,5
    3,0
    2,1
    6,3
    2,4
    1,5
    0,6
    3,3
    2,6
    5,1
    1,2
    5,5
    2,5
    6,5
    1,4
    0,4
    6,4
    1,1
    6,1
    1,0
    0,5
    1,6
    2,0
    """

    static let puzzle = """
    71
    1024
    42,19
    35,11
    51,47
    67,61
    68,67
    7,9
    23,11
    69,70
    55,61
    49,9
    17,15
    51,36
    57,58
    51,6
    52,31
    69,49
    11,15
    30,9
    65,29
    39,13
    17,16
    49,3
    56,63
    64,41
    41,15
    53,49
    5,13
    57,31
    36,9
    47,55
    43,19
    9,14
    58,49
    59,7
    68,55
    13,19
    53,51
    31,19
    64,69
    31,4
    65,23
    48,57
    27,15
    57,63
    66,49
    44,13
    35,17
    23,7
    53,16
    15,7
    63,3
    65,38
    59,68
    60,45
    7,17
    41,13
    6,35
    49,4
    25,11
    29,3
    50,65
    65,64
    48,17
    43,43
    5,8
    37,12
    67,68
    43,13
    23,9
    61,55
    27,19
    32,3
    57,47
    69,61
    69,64
    1,6
    51,9
    58,59
    9,11
    4,11
    65,39
    38,9
    43,5
    52,55
    29,13
    53,52
    13,1
    59,48
    56,45
    33,0
    68,59
    35,13
    1,4
    30,13
    60,35
    54,7
    41,3
    51,4
    46,55
    57,49
    19,24
    50,1
    43,42
    67,37
    28,25
    69,65
    22,3
    6,15
    53,37
    59,53
    39,6
    49,12
    37,15
    63,38
    55,33
    23,13
    61,33
    63,39
    65,60
    55,31
    31,2
    63,54
    55,6
    17,5
    53,17
    14,13
    58,43
    61,69
    25,31
    57,53
    13,6
    47,47
    54,3
    53,7
    67,51
    49,7
    13,15
    55,9
    37,11
    1,5
    42,55
    66,45
    21,31
    15,6
    69,40
    58,35
    7,21
    66,35
    63,55
    36,7
    30,25
    3,23
    55,45
    69,42
    7,15
    31,8
    13,5
    47,13
    27,24
    69,63
    37,1
    8,33
    44,17
    70,35
    8,27
    37,17
    59,5
    51,7
    65,66
    40,17
    58,45
    57,67
    44,45
    69,53
    36,13
    51,53
    50,33
    39,14
    21,14
    16,21
    53,50
    7,24
    59,59
    43,45
    2,7
    11,3
    3,3
    63,27
    28,11
    52,1
    27,5
    17,18
    4,19
    45,7
    63,1
    31,15
    55,3
    45,51
    56,47
    15,13
    25,21
    67,49
    59,31
    55,60
    66,69
    35,1
    31,24
    61,4
    29,22
    55,30
    69,54
    6,3
    28,3
    41,17
    27,17
    21,4
    61,1
    45,5
    39,2
    1,9
    34,17
    15,8
    9,7
    63,7
    61,59
    3,4
    48,45
    47,43
    55,39
    1,1
    15,19
    41,2
    47,15
    43,41
    65,57
    31,3
    41,0
    27,6
    61,43
    61,53
    46,45
    16,27
    1,21
    61,68
    14,15
    42,47
    45,11
    29,9
    39,1
    15,17
    66,39
    33,20
    43,38
    66,25
    29,19
    17,21
    10,3
    17,2
    3,16
    26,13
    9,17
    19,5
    19,13
    49,38
    33,5
    60,55
    29,21
    56,39
    49,55
    67,50
    55,16
    57,16
    61,51
    58,69
    60,1
    55,34
    16,31
    62,57
    51,29
    67,62
    37,27
    52,47
    51,19
    3,26
    51,40
    30,21
    16,13
    65,61
    69,45
    54,31
    8,7
    47,53
    12,7
    1,17
    45,48
    7,6
    69,35
    23,21
    61,38
    53,18
    44,9
    51,17
    37,10
    40,43
    44,43
    6,13
    32,21
    41,14
    28,27
    65,28
    21,16
    29,8
    26,29
    66,33
    27,13
    52,3
    63,50
    50,43
    18,9
    67,63
    61,9
    3,19
    33,10
    49,53
    17,11
    19,21
    47,16
    62,37
    57,45
    22,9
    63,32
    47,19
    59,61
    67,44
    39,3
    70,65
    22,21
    59,55
    3,9
    61,67
    17,4
    15,3
    59,67
    61,35
    39,15
    28,15
    56,41
    66,53
    43,11
    61,3
    42,41
    27,11
    57,42
    9,12
    41,44
    42,45
    58,51
    15,0
    67,56
    50,57
    67,65
    50,53
    19,7
    61,63
    69,47
    49,35
    46,19
    60,41
    61,70
    20,9
    47,45
    33,29
    31,11
    56,5
    43,15
    49,47
    63,33
    57,51
    65,45
    45,47
    50,49
    70,37
    20,3
    49,51
    49,45
    14,5
    45,4
    57,36
    59,42
    39,18
    9,10
    24,5
    56,1
    3,29
    33,19
    51,67
    61,45
    23,8
    53,5
    28,9
    49,15
    27,21
    63,31
    63,34
    11,1
    25,9
    48,35
    49,2
    49,1
    51,56
    11,17
    69,67
    55,1
    0,19
    16,15
    52,45
    17,3
    65,59
    18,3
    30,11
    60,31
    58,39
    53,46
    58,7
    27,20
    36,19
    34,7
    63,68
    64,61
    8,17
    65,58
    7,11
    27,9
    28,21
    45,39
    51,38
    41,42
    69,58
    15,15
    53,9
    63,51
    34,3
    43,52
    43,55
    39,7
    50,7
    58,37
    27,23
    41,20
    2,1
    42,17
    29,23
    31,7
    26,21
    63,61
    54,35
    31,25
    57,1
    51,45
    10,17
    49,11
    61,57
    42,3
    54,69
    23,5
    55,35
    31,16
    43,23
    69,39
    47,54
    15,5
    26,3
    51,51
    8,21
    17,25
    19,10
    70,47
    51,1
    45,13
    8,3
    62,41
    2,23
    59,34
    54,53
    67,43
    33,15
    55,57
    54,33
    49,59
    23,19
    53,42
    41,45
    40,11
    61,37
    15,9
    54,39
    5,7
    61,47
    59,46
    69,41
    46,59
    6,5
    55,56
    11,12
    63,53
    20,1
    41,8
    67,29
    27,4
    50,47
    13,9
    47,33
    57,60
    47,52
    7,7
    29,29
    65,55
    51,42
    63,49
    22,1
    69,59
    53,59
    55,53
    59,51
    51,20
    68,49
    49,56
    33,7
    13,22
    47,49
    66,57
    32,7
    63,37
    11,16
    25,7
    43,28
    21,7
    9,3
    39,9
    47,46
    56,25
    18,7
    48,13
    49,41
    56,53
    47,11
    59,41
    63,40
    19,12
    60,51
    51,49
    41,10
    37,19
    65,36
    53,58
    41,9
    3,10
    27,0
    68,61
    9,9
    63,67
    45,50
    69,33
    5,17
    34,23
    43,3
    29,11
    7,18
    55,5
    55,37
    23,18
    48,51
    63,2
    20,17
    1,8
    25,15
    29,7
    57,57
    55,43
    21,9
    54,5
    61,65
    51,3
    59,65
    46,15
    17,13
    36,1
    58,5
    65,51
    49,43
    66,41
    59,56
    29,1
    17,9
    19,22
    55,55
    69,43
    33,3
    35,16
    49,49
    65,42
    49,54
    59,49
    12,15
    55,27
    7,5
    28,13
    28,17
    46,9
    39,22
    7,16
    65,41
    3,12
    38,17
    63,29
    35,9
    55,51
    37,3
    37,23
    61,60
    53,36
    16,19
    69,55
    59,43
    61,54
    0,13
    21,11
    35,29
    25,1
    49,14
    5,3
    67,57
    57,54
    33,22
    60,49
    41,54
    25,12
    11,7
    35,7
    53,33
    15,1
    14,17
    55,44
    65,33
    38,21
    57,37
    21,6
    16,23
    57,5
    63,63
    35,3
    5,33
    53,55
    55,49
    10,19
    70,61
    37,24
    25,2
    45,49
    11,4
    47,41
    11,11
    53,45
    67,45
    48,43
    63,58
    29,2
    60,59
    29,15
    16,7
    54,49
    17,17
    68,35
    29,6
    63,43
    47,8
    17,10
    15,2
    65,30
    42,13
    4,5
    13,3
    17,1
    59,4
    57,2
    53,43
    10,9
    9,1
    51,52
    23,14
    67,59
    35,14
    57,55
    25,8
    7,1
    33,6
    57,66
    48,49
    53,1
    62,33
    43,40
    61,41
    19,11
    59,30
    57,41
    33,12
    65,65
    35,5
    32,15
    21,17
    40,5
    13,13
    54,59
    17,7
    51,39
    31,21
    41,27
    51,44
    37,25
    8,13
    31,13
    27,3
    32,25
    3,30
    51,50
    63,64
    51,11
    69,57
    19,6
    38,19
    68,39
    55,41
    5,21
    29,27
    47,9
    65,50
    65,67
    5,22
    38,15
    11,9
    13,18
    63,62
    65,43
    65,49
    33,27
    60,39
    33,1
    63,56
    41,43
    55,7
    59,1
    67,69
    67,55
    65,48
    68,43
    65,54
    5,9
    63,47
    24,21
    13,30
    35,8
    67,33
    47,48
    21,15
    45,43
    65,47
    61,52
    61,7
    37,5
    49,37
    30,15
    65,69
    12,13
    47,7
    37,2
    67,53
    33,9
    69,69
    67,41
    29,5
    11,13
    43,6
    57,61
    45,15
    44,1
    37,21
    65,31
    19,1
    39,4
    63,4
    18,15
    54,29
    67,35
    62,49
    35,4
    7,19
    61,30
    26,7
    61,44
    63,69
    23,10
    51,5
    51,57
    53,41
    19,14
    3,27
    43,9
    59,57
    7,2
    2,19
    9,15
    69,51
    5,5
    56,57
    44,3
    61,64
    25,16
    3,15
    62,43
    11,2
    63,52
    21,12
    25,10
    45,54
    1,10
    23,0
    31,17
    6,11
    67,47
    65,27
    56,49
    62,1
    48,5
    54,1
    1,7
    51,34
    31,9
    13,2
    19,9
    59,47
    63,57
    11,19
    23,3
    53,39
    66,63
    58,57
    56,33
    63,45
    64,45
    7,10
    62,61
    42,5
    3,17
    61,49
    43,51
    47,21
    34,11
    33,14
    47,35
    1,11
    47,5
    37,13
    4,3
    39,19
    9,27
    53,3
    14,9
    4,7
    5,19
    3,13
    54,55
    45,45
    35,15
    24,3
    41,1
    43,22
    46,41
    9,20
    63,35
    49,10
    19,3
    63,44
    53,38
    47,6
    26,15
    38,7
    31,18
    31,1
    68,37
    3,14
    44,11
    43,16
    41,55
    15,4
    49,5
    39,5
    45,55
    46,43
    24,11
    24,23
    59,35
    51,31
    6,9
    41,5
    51,35
    30,19
    37,7
    38,23
    40,21
    4,17
    67,66
    49,8
    13,17
    61,46
    59,39
    3,1
    10,27
    59,66
    53,53
    61,66
    44,7
    57,3
    3,7
    3,5
    61,39
    39,17
    69,52
    66,27
    46,5
    43,14
    50,17
    34,1
    67,52
    41,21
    39,12
    27,1
    67,39
    65,63
    42,11
    25,29
    52,33
    64,47
    46,11
    6,19
    31,23
    49,17
    22,5
    19,17
    12,9
    33,21
    69,37
    14,11
    63,5
    1,3
    65,37
    21,1
    64,31
    23,15
    51,37
    41,49
    3,11
    37,4
    53,35
    68,47
    9,0
    41,52
    12,19
    64,67
    25,13
    56,37
    68,33
    42,7
    25,14
    57,65
    25,5
    15,37
    63,36
    33,18
    1,13
    55,47
    9,8
    61,31
    12,1
    5,0
    54,47
    21,13
    53,15
    63,59
    27,25
    4,23
    23,24
    53,57
    59,3
    46,13
    58,53
    55,52
    69,46
    27,7
    51,41
    30,5
    11,5
    59,45
    52,17
    63,41
    55,64
    7,13
    45,9
    57,43
    69,56
    63,65
    54,43
    61,62
    33,17
    32,11
    23,1
    5,1
    59,2
    1,19
    52,7
    33,13
    57,39
    3,2
    51,55
    59,37
    35,21
    43,64
    61,61
    53,65
    10,23
    28,31
    37,28
    33,23
    64,19
    25,50
    23,46
    45,29
    47,23
    41,31
    63,15
    1,53
    51,64
    35,63
    45,31
    1,16
    23,39
    24,33
    13,69
    53,10
    21,34
    47,57
    61,27
    55,67
    41,25
    7,49
    39,67
    37,31
    47,61
    54,27
    29,45
    46,27
    37,33
    2,53
    55,17
    43,26
    5,63
    16,39
    23,41
    21,62
    59,15
    7,43
    6,21
    3,69
    45,66
    41,36
    19,31
    15,61
    47,34
    31,43
    48,67
    51,21
    37,36
    57,68
    5,28
    3,57
    31,68
    3,66
    51,26
    19,15
    15,65
    21,38
    9,38
    39,23
    59,13
    25,51
    19,67
    27,69
    61,14
    28,57
    8,49
    30,31
    24,55
    32,65
    15,20
    37,45
    37,50
    17,70
    15,55
    35,39
    40,67
    15,32
    17,41
    25,26
    29,56
    3,42
    21,57
    9,55
    3,49
    57,69
    40,31
    57,35
    32,45
    61,24
    52,61
    21,63
    21,5
    42,67
    55,23
    41,39
    9,40
    43,62
    12,11
    15,43
    50,27
    35,56
    34,51
    25,55
    33,11
    1,64
    18,63
    21,3
    7,25
    33,30
    51,59
    33,48
    35,20
    49,69
    3,67
    37,30
    63,23
    65,18
    36,25
    35,35
    18,55
    45,3
    33,55
    9,33
    12,59
    49,29
    10,53
    13,68
    43,27
    15,11
    25,42
    35,59
    69,6
    53,69
    21,49
    10,31
    29,37
    17,38
    4,69
    29,31
    11,41
    3,21
    47,31
    59,11
    27,31
    7,65
    65,5
    13,23
    70,3
    15,23
    70,23
    63,19
    8,23
    2,67
    37,53
    51,22
    45,35
    4,67
    49,36
    3,63
    28,43
    43,47
    23,62
    21,39
    1,49
    52,13
    62,11
    23,45
    7,53
    7,36
    19,46
    33,38
    43,36
    43,67
    23,49
    17,55
    15,25
    19,55
    1,61
    46,35
    21,28
    29,57
    57,9
    11,29
    35,27
    58,21
    39,41
    48,31
    51,13
    50,67
    19,27
    5,24
    35,26
    46,23
    13,37
    67,23
    67,21
    35,65
    7,60
    19,47
    18,65
    15,64
    30,29
    43,31
    17,51
    17,53
    9,45
    37,61
    5,51
    51,69
    7,39
    5,50
    19,51
    13,44
    39,33
    7,27
    4,35
    44,33
    43,68
    47,29
    27,55
    55,69
    21,19
    44,61
    9,35
    38,69
    19,32
    9,31
    31,58
    45,30
    59,21
    10,67
    65,4
    42,33
    31,55
    7,59
    39,69
    16,51
    69,23
    19,40
    36,63
    25,37
    11,62
    12,25
    35,25
    2,39
    1,27
    16,67
    36,33
    28,37
    5,55
    23,65
    10,59
    45,57
    17,40
    29,46
    35,54
    56,9
    33,37
    43,29
    39,34
    41,47
    8,29
    14,61
    11,21
    45,27
    47,69
    9,62
    65,2
    9,26
    19,65
    47,37
    49,39
    44,47
    57,12
    3,50
    61,15
    18,31
    8,35
    34,43
    29,17
    3,36
    9,13
    29,66
    53,11
    29,39
    10,35
    39,63
    7,29
    12,43
    13,25
    61,26
    67,15
    8,47
    32,51
    68,9
    39,60
    13,26
    17,56
    2,69
    5,23
    59,9
    31,47
    53,67
    13,20
    62,29
    69,7
    26,69
    69,25
    27,61
    70,17
    55,22
    43,25
    39,61
    37,44
    40,51
    15,59
    20,57
    5,56
    39,54
    58,25
    5,29
    13,63
    43,69
    41,67
    8,69
    14,55
    31,70
    3,61
    69,17
    10,47
    33,51
    33,67
    26,55
    37,39
    19,61
    11,33
    21,25
    41,35
    26,23
    57,29
    31,27
    16,61
    59,64
    42,69
    12,49
    9,39
    21,29
    11,65
    1,23
    55,11
    13,50
    11,47
    61,6
    21,43
    62,7
    51,23
    39,53
    19,49
    5,32
    69,19
    30,53
    46,63
    53,13
    23,44
    27,18
    22,59
    41,63
    41,65
    31,35
    41,23
    5,35
    23,30
    49,67
    35,41
    18,47
    7,61
    54,19
    22,45
    17,52
    19,26
    53,24
    33,62
    55,26
    39,66
    21,65
    5,53
    39,39
    69,29
    26,35
    20,43
    53,47
    27,42
    9,56
    49,24
    10,51
    44,57
    67,13
    53,21
    44,53
    33,34
    68,21
    19,28
    9,63
    38,35
    39,45
    31,53
    68,27
    15,28
    49,60
    7,56
    17,62
    25,67
    1,45
    11,51
    1,39
    41,33
    51,30
    7,3
    7,23
    11,45
    57,27
    31,37
    31,52
    65,19
    57,14
    62,21
    55,25
    44,69
    6,63
    22,67
    5,37
    31,31
    61,23
    49,19
    66,13
    63,16
    19,43
    26,61
    65,25
    26,53
    67,11
    19,25
    66,9
    39,46
    21,50
    25,69
    14,65
    28,59
    61,25
    65,17
    57,7
    30,47
    2,29
    34,57
    13,47
    47,39
    35,45
    23,63
    7,33
    3,65
    31,49
    2,47
    13,49
    27,33
    34,65
    17,36
    29,41
    22,53
    65,22
    13,48
    7,63
    31,61
    43,30
    27,48
    4,15
    29,55
    9,42
    61,21
    18,69
    57,13
    41,53
    65,3
    57,23
    69,10
    15,51
    1,37
    52,21
    13,55
    51,63
    1,29
    20,47
    5,69
    25,68
    21,26
    21,35
    39,29
    11,49
    23,17
    16,63
    35,43
    59,18
    27,53
    69,9
    41,7
    29,64
    47,17
    31,45
    1,31
    67,22
    13,34
    37,67
    65,10
    35,55
    49,31
    33,60
    65,7
    5,47
    25,47
    2,63
    1,63
    57,22
    26,45
    39,59
    55,19
    48,69
    63,26
    13,59
    59,25
    53,19
    32,37
    11,66
    15,30
    23,67
    47,59
    34,47
    9,41
    25,41
    23,23
    57,25
    17,59
    27,47
    57,11
    37,52
    23,48
    13,7
    21,69
    25,61
    61,11
    11,63
    21,54
    33,69
    47,66
    2,25
    21,48
    41,62
    67,12
    30,35
    51,33
    45,17
    43,1
    15,57
    38,27
    49,28
    36,69
    2,59
    27,39
    5,41
    67,19
    17,57
    12,33
    43,35
    23,51
    51,61
    16,49
    49,21
    20,35
    45,24
    3,33
    8,51
    64,11
    40,47
    38,41
    33,39
    29,44
    25,43
    7,47
    11,69
    10,57
    32,55
    29,63
    58,63
    30,55
    31,5
    1,60
    55,59
    3,58
    25,33
    32,27
    33,65
    9,69
    12,39
    3,44
    36,59
    46,67
    1,14
    17,65
    27,37
    42,59
    19,18
    11,43
    41,61
    59,23
    59,29
    13,11
    11,23
    33,40
    23,27
    7,69
    70,13
    23,69
    14,59
    24,35
    63,25
    11,31
    38,45
    44,37
    47,38
    49,27
    43,65
    39,49
    49,40
    23,61
    67,1
    11,53
    55,15
    41,69
    29,30
    36,51
    41,41
    9,5
    1,47
    7,30
    0,27
    50,21
    44,19
    19,19
    25,32
    7,68
    4,61
    27,41
    11,54
    27,34
    39,48
    18,49
    21,42
    57,32
    4,47
    44,21
    33,61
    19,59
    27,56
    23,66
    45,56
    60,7
    57,59
    14,41
    9,37
    60,15
    34,25
    44,59
    31,65
    6,45
    22,13
    30,65
    54,23
    31,51
    28,53
    63,9
    3,47
    5,15
    38,55
    65,13
    13,36
    25,49
    59,69
    64,5
    30,43
    14,53
    1,32
    26,37
    24,43
    3,20
    1,56
    9,47
    4,39
    21,45
    47,62
    19,41
    13,41
    48,21
    36,61
    19,36
    5,27
    69,11
    41,51
    43,53
    47,65
    67,9
    17,37
    41,28
    11,24
    18,23
    11,57
    43,59
    33,46
    31,62
    12,55
    31,42
    9,67
    5,67
    19,29
    35,67
    29,38
    14,25
    67,4
    55,20
    33,33
    11,52
    34,63
    11,55
    43,50
    15,27
    35,32
    43,21
    15,66
    49,64
    33,45
    11,37
    15,46
    21,64
    10,49
    65,11
    33,31
    25,46
    25,39
    61,13
    19,60
    21,68
    23,33
    11,25
    50,59
    53,66
    44,29
    57,17
    55,29
    45,67
    53,29
    37,47
    52,25
    37,32
    39,43
    0,45
    49,32
    48,19
    39,30
    13,46
    15,53
    13,51
    33,56
    3,45
    45,23
    69,1
    9,57
    45,65
    7,51
    5,39
    31,60
    55,14
    69,3
    55,68
    15,54
    3,31
    12,69
    5,42
    23,32
    40,27
    36,37
    5,11
    39,31
    24,17
    3,54
    53,23
    55,63
    5,60
    39,64
    37,69
    25,64
    57,19
    30,69
    29,40
    27,49
    15,67
    27,65
    35,42
    15,49
    39,37
    21,51
    37,41
    45,25
    51,14
    17,34
    51,12
    57,24
    1,15
    65,53
    41,19
    3,35
    18,43
    64,13
    52,59
    23,35
    28,49
    35,31
    13,43
    33,49
    67,18
    44,65
    23,47
    33,35
    43,63
    33,59
    5,57
    65,0
    29,69
    5,38
    7,54
    40,69
    26,31
    63,13
    3,59
    54,15
    27,63
    40,63
    3,37
    25,48
    16,11
    32,35
    27,29
    48,41
    30,33
    66,7
    1,51
    31,63
    19,45
    48,63
    5,48
    9,65
    31,69
    9,61
    19,44
    11,46
    57,28
    9,43
    21,23
    6,69
    9,21
    35,51
    39,55
    17,39
    60,13
    23,59
    41,57
    21,59
    0,65
    1,30
    19,57
    35,46
    61,20
    29,60
    39,40
    58,13
    35,47
    51,25
    3,43
    43,33
    24,65
    29,53
    5,43
    9,51
    1,57
    15,21
    53,31
    65,35
    13,61
    7,31
    29,62
    13,29
    52,9
    7,67
    36,39
    5,25
    49,65
    33,68
    25,52
    59,62
    13,27
    34,69
    40,57
    30,59
    11,64
    10,29
    29,47
    21,41
    11,67
    52,69
    3,56
    25,45
    20,53
    17,44
    67,24
    15,47
    49,18
    0,37
    13,57
    20,37
    9,59
    32,49
    38,49
    57,21
    0,55
    40,39
    68,25
    20,67
    17,63
    29,33
    27,35
    53,27
    55,66
    21,47
    22,57
    18,29
    45,41
    37,48
    27,45
    7,44
    1,67
    52,63
    1,35
    5,66
    47,63
    40,61
    67,6
    41,11
    29,49
    64,55
    49,33
    30,49
    19,37
    3,53
    25,57
    25,35
    1,22
    37,55
    15,39
    31,40
    5,52
    9,23
    1,41
    45,59
    39,51
    29,67
    43,7
    7,37
    51,15
    15,38
    45,0
    13,35
    67,17
    27,28
    67,27
    50,29
    37,35
    17,33
    32,31
    43,61
    18,33
    7,35
    1,62
    35,37
    10,43
    37,57
    24,27
    16,59
    67,30
    47,67
    31,38
    67,16
    27,67
    31,39
    59,10
    8,53
    1,25
    18,41
    49,23
    61,22
    33,66
    35,33
    69,20
    68,1
    26,65
    13,66
    3,55
    49,25
    68,19
    17,67
    23,37
    23,50
    23,68
    42,35
    41,58
    59,26
    69,8
    43,37
    35,40
    33,32
    42,65
    59,19
    20,61
    23,36
    33,47
    37,65
    45,21
    19,35
    23,70
    14,35
    63,11
    58,17
    55,13
    22,31
    41,50
    48,61
    67,5
    33,58
    5,40
    29,59
    15,69
    22,25
    53,61
    47,28
    41,26
    51,43
    49,13
    39,25
    67,3
    63,10
    37,49
    15,41
    41,37
    41,59
    59,33
    33,63
    35,61
    27,51
    33,44
    63,21
    10,69
    9,25
    11,38
    24,19
    16,47
    45,69
    16,57
    46,69
    39,26
    13,67
    41,56
    5,45
    27,43
    25,62
    42,31
    1,33
    8,39
    2,41
    38,53
    54,63
    35,23
    67,7
    3,25
    20,23
    17,69
    28,67
    12,57
    19,63
    37,56
    27,57
    46,39
    35,22
    45,1
    47,51
    21,67
    54,11
    39,65
    65,20
    23,42
    54,61
    69,27
    13,39
    23,43
    23,25
    55,21
    14,39
    23,57
    23,55
    20,65
    29,35
    65,16
    23,53
    5,61
    19,23
    65,15
    17,47
    63,28
    67,32
    26,59
    33,53
    3,39
    25,59
    35,19
    14,51
    12,63
    15,29
    47,1
    17,19
    23,52
    15,63
    19,20
    65,1
    47,58
    37,37
    7,55
    41,29
    7,41
    21,21
    61,8
    37,42
    69,13
    15,33
    67,2
    17,54
    17,45
    69,28
    45,40
    57,20
    46,33
    61,5
    19,58
    45,61
    4,33
    2,35
    68,13
    7,58
    33,43
    38,59
    3,51
    27,59
    14,57
    26,51
    11,27
    2,33
    36,65
    19,33
    64,23
    35,28
    5,59
    39,57
    25,23
    2,37
    44,25
    17,61
    61,12
    1,65
    67,25
    69,31
    67,31
    25,3
    59,63
    11,59
    37,9
    15,42
    37,58
    1,43
    68,5
    17,49
    35,53
    12,29
    25,27
    18,67
    68,15
    56,19
    19,69
    69,15
    62,25
    69,32
    22,27
    0,43
    4,45
    27,68
    9,53
    49,63
    39,32
    35,38
    25,17
    27,27
    41,24
    48,25
    47,30
    63,17
    43,17
    25,58
    20,31
    31,33
    2,49
    29,51
    23,31
    37,29
    23,29
    34,29
    37,59
    53,63
    15,35
    39,47
    39,11
    39,38
    9,29
    12,41
    9,32
    5,58
    17,35
    7,42
    43,60
    23,40
    56,29
    8,59
    59,17
    19,39
    29,36
    45,19
    1,55
    18,59
    22,35
    11,39
    69,30
    7,46
    16,43
    6,27
    29,61
    69,21
    35,69
    19,52
    24,39
    11,61
    35,36
    31,41
    14,33
    45,37
    21,40
    19,53
    59,32
    11,36
    46,51
    31,67
    21,33
    47,2
    17,43
    39,35
    1,69
    55,65
    1,59
    37,43
    9,19
    35,34
    5,49
    2,27
    13,28
    53,25
    59,27
    17,29
    29,25
    25,19
    65,21
    27,44
    45,63
    29,65
    13,31
    45,33
    47,3
    13,21
    3,41
    25,38
    15,24
    5,31
    37,51
    61,19
    37,62
    65,9
    27,40
    29,43
    61,18
    47,26
    23,60
    58,29
    7,57
    5,62
    33,57
    25,28
    51,27
    25,53
    35,49
    21,22
    39,36
    57,33
    0,51
    35,57
    37,66
    13,45
    17,26
    47,25
    7,45
    6,49
    19,50
    6,31
    51,65
    15,45
    62,15
    21,61
    28,63
    39,21
    51,10
    35,68
    11,35
    11,22
    9,44
    39,27
    15,31
    57,15
    17,31
    21,53
    61,17
    13,65
    10,41
    13,33
    5,65
    42,23
    43,57
    45,32
    37,63
    55,8
    35,50
    49,22
    8,65
    64,7
    64,25
    4,29
    21,55
    17,27
    50,69
    49,61
    34,53
    67,67
    65,14
    31,59
    69,5
    17,23
    25,65
    6,65
    60,23
    5,54
    49,57
    52,67
    56,11
    28,33
    2,45
    48,1
    46,21
    31,29
    58,9
    9,6
    21,18
    24,57
    24,61
    61,29
    25,63
    9,66
    45,53
    8,63
    5,26
    3,52
    33,41
    14,69
    33,25
    25,25
    13,53
    43,39
    11,32
    22,55
    28,51
    9,49
    21,37
    47,27
    43,49
    31,57
    5,64
    11,60
    21,27
    62,17
    31,28
    6,39
    60,61
    68,46
    55,62
    60,28
    41,16
    24,41
    48,7
    50,70
    4,53
    16,41
    22,49
    42,15
    6,41
    5,36
    38,22
    8,46
    21,30
    2,50
    44,5
    65,68
    14,70
    34,6
    2,46
    62,30
    54,62
    56,35
    42,32
    38,38
    46,31
    40,7
    37,8
    36,2
    50,2
    0,18
    60,16
    16,34
    4,59
    34,40
    24,37
    44,22
    23,64
    16,70
    5,18
    29,42
    8,66
    49,66
    48,4
    22,41
    1,0
    56,23
    45,62
    33,28
    40,62
    62,45
    50,42
    15,40
    70,38
    27,38
    42,16
    24,52
    2,57
    64,29
    18,58
    60,20
    50,30
    42,60
    60,48
    42,51
    50,40
    45,8
    18,66
    64,8
    42,24
    24,66
    29,52
    58,0
    46,38
    9,36
    16,36
    50,18
    45,34
    60,18
    23,56
    45,28
    4,42
    56,32
    4,44
    21,70
    34,50
    0,62
    43,24
    7,38
    16,33
    30,41
    1,68
    30,61
    18,52
    0,15
    32,28
    20,62
    22,7
    66,29
    56,70
    55,32
    14,52
    58,14
    19,34
    38,26
    24,8
    7,70
    44,30
    22,4
    13,62
    16,68
    6,62
    25,44
    13,14
    7,50
    62,62
    6,29
    27,14
    55,4
    28,36
    16,64
    39,50
    26,40
    16,20
    68,56
    34,2
    15,14
    50,6
    62,47
    16,40
    0,58
    41,40
    38,8
    12,50
    22,44
    36,6
    42,29
    7,0
    0,38
    38,14
    28,48
    0,44
    40,8
    49,26
    12,14
    16,35
    11,44
    46,1
    68,30
    68,7
    65,46
    16,48
    42,70
    28,29
    58,38
    48,56
    4,30
    0,35
    4,57
    6,26
    4,36
    37,68
    47,56
    36,49
    29,50
    11,28
    62,46
    32,29
    6,64
    56,61
    54,4
    48,70
    42,68
    26,39
    30,14
    64,48
    5,46
    20,58
    36,45
    30,60
    25,6
    18,14
    43,32
    0,25
    51,70
    13,12
    56,26
    41,22
    14,40
    51,0
    70,62
    56,12
    10,39
    1,50
    52,35
    6,42
    4,18
    48,34
    68,32
    31,56
    32,44
    49,48
    22,68
    12,61
    1,18
    35,60
    11,6
    54,38
    52,15
    34,27
    40,52
    52,20
    46,4
    40,13
    36,56
    44,64
    20,34
    40,56
    32,57
    42,20
    16,56
    2,16
    18,12
    18,57
    47,18
    41,68
    40,15
    8,38
    10,8
    27,32
    14,14
    66,31
    6,28
    44,4
    37,16
    62,40
    27,70
    48,58
    37,0
    0,46
    53,70
    15,34
    67,48
    27,54
    0,4
    38,62
    4,31
    43,2
    59,70
    26,14
    68,8
    16,50
    36,17
    21,20
    60,22
    26,46
    34,38
    44,39
    34,31
    0,59
    34,37
    42,57
    60,40
    48,24
    36,50
    20,38
    32,59
    40,14
    34,60
    0,68
    50,60
    46,32
    2,44
    26,52
    47,60
    40,24
    45,38
    12,26
    26,26
    14,36
    1,44
    30,32
    68,57
    12,66
    38,30
    42,1
    52,38
    0,26
    36,32
    44,8
    58,2
    2,70
    40,30
    56,28
    19,70
    5,10
    59,58
    44,28
    22,0
    7,22
    36,48
    14,50
    59,0
    42,39
    35,58
    16,66
    12,58
    10,62
    36,15
    45,70
    34,62
    8,61
    6,30
    42,6
    9,58
    68,66
    53,60
    0,67
    45,68
    50,20
    9,34
    44,63
    5,2
    21,56
    34,35
    38,33
    34,42
    50,3
    2,32
    38,67
    64,4
    45,36
    29,32
    29,70
    0,69
    31,66
    20,42
    27,58
    67,26
    49,62
    7,34
    49,68
    48,6
    0,56
    8,6
    8,56
    10,21
    46,12
    32,50
    38,57
    23,6
    56,59
    50,4
    1,42
    40,55
    55,36
    60,17
    32,56
    24,64
    21,46
    36,29
    17,50
    33,54
    52,39
    40,32
    50,35
    8,24
    22,63
    30,46
    2,36
    27,66
    41,48
    42,25
    61,28
    26,47
    37,40
    20,51
    46,56
    44,27
    18,10
    58,58
    14,42
    48,62
    42,48
    14,54
    41,70
    12,24
    20,54
    20,41
    24,50
    4,37
    51,60
    60,14
    44,6
    38,40
    11,56
    65,52
    54,16
    44,34
    16,44
    66,50
    31,14
    10,25
    4,4
    33,70
    48,42
    20,52
    14,67
    38,66
    61,0
    45,10
    12,38
    46,26
    23,34
    13,42
    32,46
    37,6
    44,68
    14,47
    26,57
    2,58
    31,34
    70,44
    5,16
    58,40
    38,24
    3,48
    24,53
    15,44
    2,40
    10,1
    36,0
    55,2
    58,36
    36,47
    5,44
    54,22
    40,16
    60,63
    46,20
    64,51
    9,60
    30,42
    68,31
    42,42
    20,32
    14,24
    56,68
    16,12
    7,26
    42,14
    67,58
    22,30
    8,67
    18,44
    5,30
    57,18
    68,45
    32,43
    26,34
    4,65
    6,50
    36,70
    38,1
    66,68
    18,70
    44,48
    42,54
    26,43
    66,64
    56,66
    50,55
    24,30
    48,36
    67,8
    46,61
    48,65
    37,18
    48,53
    12,46
    18,13
    40,41
    50,39
    29,14
    2,17
    62,38
    42,27
    47,40
    13,70
    8,22
    28,55
    52,46
    56,30
    68,62
    49,20
    29,68
    32,13
    50,28
    28,14
    17,48
    22,56
    10,26
    40,70
    26,4
    13,0
    45,26
    10,46
    13,60
    8,25
    49,34
    48,60
    41,12
    15,12
    16,65
    46,37
    27,12
    28,66
    46,44
    28,45
    58,64
    70,64
    62,31
    60,64
    22,69
    44,40
    2,9
    6,59
    45,60
    56,36
    54,20
    10,34
    60,70
    12,34
    12,37
    40,10
    50,34
    32,62
    6,18
    23,4
    0,61
    24,62
    9,50
    24,29
    42,34
    2,0
    2,11
    54,14
    13,24
    23,38
    10,50
    32,53
    24,9
    38,48
    47,12
    15,70
    25,18
    6,46
    30,26
    0,40
    6,66
    17,60
    22,46
    22,40
    69,48
    2,14
    35,0
    46,3
    51,58
    4,10
    45,6
    6,53
    68,48
    70,66
    19,66
    60,24
    38,34
    56,20
    28,42
    23,58
    65,6
    19,2
    58,48
    30,27
    24,54
    12,20
    17,14
    2,68
    40,37
    41,32
    52,11
    24,32
    19,64
    2,66
    22,16
    6,47
    42,10
    64,17
    0,53
    6,44
    11,30
    34,36
    60,0
    4,16
    68,12
    63,8
    12,23
    58,19
    6,43
    68,53
    20,24
    66,8
    4,66
    2,15
    37,22
    30,56
    68,42
    2,3
    62,6
    57,4
    20,46
    50,64
    10,30
    24,42
    57,48
    49,30
    24,69
    30,70
    24,10
    66,24
    40,35
    18,21
    46,36
    44,35
    50,11
    58,23
    16,16
    15,68
    66,61
    38,6
    47,50
    60,33
    20,66
    6,20
    68,36
    20,59
    8,30
    52,66
    12,17
    10,70
    64,37
    60,12
    38,5
    56,46
    64,1
    62,69
    66,28
    42,4
    21,66
    7,66
    30,0
    16,3
    40,36
    68,3
    61,58
    57,56
    8,0
    61,50
    56,65
    36,23
    51,66
    52,2
    25,0
    3,60
    38,42
    22,70
    41,4
    34,5
    21,0
    58,30
    28,32
    48,28
    2,51
    16,58
    69,34
    26,70
    62,28
    0,6
    45,52
    54,2
    52,16
    34,10
    68,28
    61,56
    56,8
    53,62
    6,0
    22,52
    38,13
    50,37
    54,57
    22,18
    53,64
    21,58
    65,40
    32,41
    69,62
    52,8
    16,6
    29,48
    19,56
    10,28
    58,60
    4,41
    6,25
    58,12
    18,28
    44,52
    0,5
    66,3
    4,20
    63,46
    60,69
    62,34
    64,14
    24,26
    8,32
    28,41
    20,63
    46,10
    26,50
    4,28
    20,20
    20,44
    58,31
    12,51
    28,22
    40,42
    33,64
    60,25
    48,14
    56,64
    34,8
    36,46
    4,14
    21,32
    39,58
    63,48
    54,41
    56,40
    48,48
    22,43
    56,43
    27,16
    0,50
    49,44
    20,70
    66,59
    53,48
    4,2
    35,18
    70,53
    64,38
    55,70
    42,44
    4,21
    30,38
    26,25
    1,20
    68,51
    44,26
    3,64
    20,15
    15,60
    70,15
    20,12
    42,22
    13,58
    33,50
    49,0
    8,19
    32,6
    17,30
    43,10
    48,50
    52,26
    9,52
    36,41
    50,61
    1,66
    55,46
    68,22
    66,11
    38,3
    20,30
    14,7
    0,1
    40,45
    34,16
    2,34
    60,38
    35,24
    11,20
    53,0
    40,2
    64,0
    56,2
    12,68
    26,44
    34,30
    11,34
    14,29
    9,22
    60,56
    50,19
    54,10
    50,51
    13,10
    2,52
    6,55
    1,40
    8,55
    34,20
    68,4
    60,44
    58,70
    26,62
    24,31
    42,46
    58,32
    62,26
    40,20
    51,28
    66,2
    6,56
    16,54
    28,26
    14,68
    14,63
    46,64
    56,7
    44,44
    0,29
    56,60
    12,53
    10,33
    16,10
    36,24
    26,8
    66,70
    28,12
    63,14
    48,26
    8,57
    57,70
    42,49
    50,44
    59,16
    51,18
    35,2
    46,0
    64,63
    60,43
    46,49
    31,54
    67,40
    38,32
    66,52
    43,70
    6,14
    68,54
    66,18
    56,34
    70,57
    44,2
    62,52
    18,35
    39,44
    26,54
    26,42
    24,38
    10,37
    16,38
    38,16
    15,22
    50,15
    26,48
    27,62
    50,26
    56,62
    26,60
    54,40
    28,2
    12,47
    70,9
    58,50
    13,54
    50,32
    32,47
    44,56
    36,66
    53,14
    52,0
    7,28
    62,67
    32,38
    16,5
    32,23
    32,10
    12,35
    8,60
    18,48
    28,28
    34,68
    12,64
    44,60
    36,40
    14,58
    5,14
    3,40
    10,32
    40,33
    43,4
    2,30
    16,24
    50,58
    34,70
    70,56
    33,52
    69,44
    39,56
    60,3
    65,44
    39,68
    34,58
    6,51
    70,45
    18,54
    10,66
    2,64
    56,44
    25,36
    6,32
    38,20
    60,32
    38,10
    70,8
    6,17
    64,52
    16,25
    62,8
    2,56
    38,46
    36,5
    48,23
    27,36
    8,54
    54,18
    59,38
    65,56
    8,14
    0,28
    24,47
    68,17
    16,17
    22,19
    32,58
    57,50
    20,39
    30,10
    14,27
    16,8
    6,24
    52,30
    65,70
    16,37
    24,22
    70,6
    14,8
    12,45
    0,33
    3,8
    8,12
    55,24
    11,14
    50,23
    28,8
    33,2
    52,44
    6,36
    46,6
    27,26
    52,22
    22,64
    48,33
    58,52
    32,26
    67,28
    """
  }
}