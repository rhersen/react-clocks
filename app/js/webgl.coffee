window.WebGl = React.createClass
    render: ->
        if @program
            @gl.useProgram @program

            @gl.bindBuffer @gl.ARRAY_BUFFER, @vertex
            loc = @gl.getAttribLocation @program, 'vertex'
            @gl.vertexAttribPointer loc, 2, @gl.FLOAT, false, 0, 0
            @gl.enableVertexAttribArray loc

            loc = @gl.getUniformLocation @program, 'angle'

            @gl.uniform1f loc, Math.PI * (Date.now() % 60000) / 30000
            @gl.drawArrays @gl.TRIANGLES, 0, 6

            @gl.uniform1f loc, Math.PI * (Date.now() % 3600000) / 1800000
            @gl.drawArrays @gl.TRIANGLES, 0, 6

        React.DOM.canvas({})

    componentDidMount: ->
        vertex_shader = "

attribute vec2 vertex;
uniform float angle;

void main() {
    gl_Position = vec4(
        vertex.x * cos(angle) + vertex.y * sin(angle),
       -vertex.x * sin(angle) + vertex.y * cos(angle),
        0,
        1
    );
}
"

        fragment_shader = "

void main() {
    gl_FragColor = vec4(0, 1, 0, 1);
}
"

        canvas = document.querySelector 'canvas'
        @gl = canvas.getContext 'webgl'

        alert "cannot create webgl context" unless @gl

        @setupBuffers()

        @program = @createProgram vertex_shader, fragment_shader

        console.log canvas.clientWidth, canvas.clientHeight
        console.log window.devicePixelRatio

        canvas.width = canvas.clientWidth * window.devicePixelRatio
        canvas.height = canvas.clientHeight * window.devicePixelRatio
        @gl.viewport 0, 0, canvas.width, canvas.height

    setupBuffers: ->
        w = 1/32
        vertices = [
            -w, 1
            -w, -w
            w, -w
            -w, 1
            w, 1
            w, -w
        ]

        @vertex = @gl.createBuffer()
        @gl.bindBuffer @gl.ARRAY_BUFFER, @vertex
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

        unless @gl.getProgramParameter p, @gl.LINK_STATUS
            alert "ERROR:\nVALIDATE_STATUS:
                                            #{ @gl.getProgramParameter p, @gl.VALIDATE_STATUS }\nERROR:
                                            #{ @gl.getError() }\n\n- Vertex Shader -\n#{ @vertex }\n\n- Fragment Shader -\n#{ fragment}"
            return null

        return p

    createShader: (src, type) ->
        shader = @gl.createShader type

        @gl.shaderSource shader, src
        @gl.compileShader shader

        unless @gl.getShaderParameter shader, @gl.COMPILE_STATUS
            alert((if type is @gl.VERTEX_SHADER then "VERTEX" else "FRAGMENT" ) + " SHADER:\n" + @gl.getShaderInfoLog shader)
            return null

        return shader