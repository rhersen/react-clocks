tag = React.DOM

window.ReactRoot = React.createClass
  getInitialState: ->
    millis: Date.now(),
    timezoneOffset: new Date().getTimezoneOffset(),
    request: 0

  componentDidMount: ->
    @setState request: requestAnimationFrame @tick

  componentWillUnmount: ->
    @stop()

  tick: ->
    @setState
      millis: Date.now()
      request: requestAnimationFrame @tick

  start: ->
    @frameCount = 0
    @startTimeMillis = new Date()
    @tick()

  stop: ->
    cancelAnimationFrame @state.request
    @setState request: 0

  gmt: ->
    @setState timezoneOffset: 0

  local: ->
    @setState timezoneOffset: new Date().getTimezoneOffset()

  render: ->
    tag.div {},
      tag.div {},
        tag.button
          onClick: @start
          disabled: @state.request isnt 0
          'start'
        tag.button
          onClick: @stop
          disabled: @state.request is 0
          'stop'
        tag.button
          onClick: @gmt
          disabled: @state.timezoneOffset is 0
          'gmt'
        tag.button
          onClick: @local
          disabled: @state.timezoneOffset isnt 0
          'local'
        tag.label {},
          tag.input
            onChange: (event) => @setState svg: event.target.checked
            type: 'checkbox'
          tag.span {},
            'SVG'
        tag.label {},
          tag.input
            onChange: (event) => @setState gl: event.target.checked
            type: 'checkbox'
          tag.span {},
            'WebGL'
      if @state.svg
        Clock
          millis: @state.millis
          timezoneOffset: @state.timezoneOffset
      if @state.gl
        tag.div {className: 'drawing-area'},
          WebGl
            millis: @state.millis
            timezoneOffset: @state.timezoneOffset