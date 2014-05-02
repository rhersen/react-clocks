window.getVertices = (n) ->
  [0...(n * n * 9)].map((i) ->
      if i % 3 is 2
        2 * Math.PI * (i - 2) / 3 / 3
      else if i % 3 is 1
        j = (i - 1) / 3
        (j - j % (n * 3)) / (n * 3)
      else
        j = i / 3
        k = j % (n * 3)
        (k - k % 3) / 3
  )

window.getVertexIndices = ->
    faces = [ 0, 1, 2, 0, 2, 3 ]

    flatMap [0...6], (i) -> faces.map (face) -> 4 * i + face

window.getNormals = ->
    front = [0, 0, 1]
    back = [0, 0, -1]
    top = [0, 1, 0]
    bottom = [0, -1, 0]
    right = [1, 0, 0]
    left = [-1, 0, 0]

    flatMap [front, back, top, bottom, right, left], repeat4times

repeat4times = (face) -> flatMap [0...4], -> face

flatMap = (a, f) ->
    [].concat.apply [], a.map f