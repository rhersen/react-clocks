n = 120

window.WebGl = React.createClass
  render: ->
    useProgramWithArray = (program, pos) =>
      @gl.useProgram program
      @gl.bindBuffer @gl.ARRAY_BUFFER, pos
      pos = @gl.getAttribLocation program, 'pos'
      @gl.vertexAttribPointer pos, 2, @gl.FLOAT, false, 0, 0
      @gl.enableVertexAttribArray pos

    getMillis = =>
      @props.millis - @props.timezoneOffset * 60000

    drawHand = (t, width, length = 0.9) =>
      @gl.uniform1f loc('angle'), 2 * Math.PI * (getMillis() % t) / t
      @gl.uniform2f loc('size'), width, length
      @gl.drawArrays @gl.TRIANGLE_STRIP, 0, 4

    loc = (name) =>
      @gl.getUniformLocation(@hand, name)

    if @face
      useProgramWithArray @face, @facepos
      @gl.drawArrays @gl.TRIANGLE_FAN, 0, n + 2

    if @hand
      useProgramWithArray @hand, @handpos
      drawHand 60000, 0.01
      drawHand 60 * 60000, 0.05
      drawHand 12 * 60 * 60000, 0.1, 0.7

    React.DOM.canvas({})

  componentDidMount: ->
    canvas = document.querySelector 'canvas'
    @gl = canvas.getContext 'webgl'

    if @gl
      @setupBuffers()
      @setupPrograms()
      @setup(canvas)
    else
      alert "cannot create webgl context"

  setupBuffers: ->
    hand = [
      -1, 1
      -1, 0
      1, 1
      1, 0
    ]

    @handpos = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @handpos
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(hand), @gl.STATIC_DRAW

    face = [-1..n].map((x) ->
      if x < 0 then [0, 0] else [2 * Math.PI * x / n, 1])

    @facepos = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @facepos
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array([].concat.apply [], face), @gl.STATIC_DRAW

  setupPrograms: ->
    @hand = @createProgram(
      "
      attribute vec2 pos;
      uniform float angle;
      uniform vec2 size;

      void main() {
          float w = size.x / 2.;

          gl_Position = vec4(
              pos.x * w * cos(angle) + (pos.y - w) * size.y * sin(angle),
             -pos.x * w * sin(angle) + (pos.y - w) * size.y * cos(angle),
              0,
              1
          );
      }",
      "
      void main() {
          gl_FragColor = vec4(0.18, 0.31, 0.31, 1);
      }"
    )

    @face = @createProgram(
      "
      attribute vec2 pos;

      void main() {
          gl_Position = vec4(
              pos.y * sin(pos.x),
              pos.y * cos(pos.x),
              0,
              1
          );
      }",
      "
      void main() {
        gl_FragColor = vec4(1, 1, 0.94, 1);
      }"
    )

  setup: (canvas) ->
    canvas.width = canvas.clientWidth * window.devicePixelRatio
    canvas.height = canvas.clientHeight * window.devicePixelRatio
    @gl.viewport 0, 0, canvas.width, canvas.height

  createProgram: (vertex, fragment) ->
    p = @gl.createProgram()

    vs = @createShader vertex, @gl.VERTEX_SHADER
    fs = @createShader fragment, @gl.FRAGMENT_SHADER

    if vs is null or fs is null
      return null

    @gl.attachShader p, vs
    @gl.attachShader p, fs

    @gl.deleteShader vs
    @gl.deleteShader fs

    @gl.linkProgram p

    if @gl.getProgramParameter p, @gl.LINK_STATUS
      p
    else
      alert "ERROR:\nVALIDATE_STATUS:
        #{ @gl.getProgramParameter p, @gl.VALIDATE_STATUS }\nERROR:
        #{ @gl.getError() }\n\n- Vertex Shader -\n#{ @vertex }
        \n\n- Fragment Shader -\n#{ fragment}"
      null

  createShader: (src, type) ->
    shader = @gl.createShader type

    @gl.shaderSource shader, src
    @gl.compileShader shader

    if @gl.getShaderParameter shader, @gl.COMPILE_STATUS
      shader
    else
      alert((if type is @gl.VERTEX_SHADER then "VERTEX" else "FRAGMENT" ) +
        " SHADER:\n" + @gl.getShaderInfoLog shader)
      null