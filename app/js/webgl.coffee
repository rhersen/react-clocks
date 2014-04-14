window.WebGl = React.createClass
  render: ->
    if @hand
      @gl.useProgram @hand

      @gl.bindBuffer @gl.ARRAY_BUFFER, @pos
      loc = @gl.getAttribLocation @hand, 'pos'
      @gl.vertexAttribPointer loc, 2, @gl.FLOAT, false, 0, 0
      @gl.enableVertexAttribArray loc

      loc = @gl.getUniformLocation @hand, 'angle'

      @gl.uniform1f loc, Math.PI * (Date.now() % 60000) / 30000
      @gl.drawArrays @gl.TRIANGLE_STRIP, 0, 4

      @gl.uniform1f loc, Math.PI * (Date.now() % 3600000) / 1800000
      @gl.drawArrays @gl.TRIANGLE_STRIP, 0, 4

    React.DOM.canvas({})

  componentDidMount: ->
    canvas = document.querySelector 'canvas'
    @gl = canvas.getContext 'webgl'

    alert "cannot create webgl context" unless @gl

    @setupBuffers()

    @hand = @createProgram(
      "
      attribute vec2 pos;
      uniform float angle;

      void main() {
          gl_Position = vec4(
              pos.x * cos(angle) + pos.y * sin(angle),
             -pos.x * sin(angle) + pos.y * cos(angle),
              0,
              1
          );
      }",
      "
      void main() {
          gl_FragColor = vec4(0, 1, 0, 1);
      }"
    )

    canvas.width = canvas.clientWidth * window.devicePixelRatio
    canvas.height = canvas.clientHeight * window.devicePixelRatio
    @gl.viewport 0, 0, canvas.width, canvas.height

  setupBuffers: ->
    w = 1 / 32
    vertices = [
      -w, 1
      -w, -w
      w, 1
      w, -w
    ]

    @pos = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @pos
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(vertices), @gl.STATIC_DRAW

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