window.ReactRoot = React.createClass
  getInitialState: ->
    millis: Date.now(),
    timezoneOffset: new Date().getTimezoneOffset(),
    request: 0

  componentDidMount: ->
    @setState request: setInterval @tick, 1

  componentWillUnmount: ->
    @stop()

  tick: ->
    @setState
      millis: Date.now()

  start: ->
    @frameCount = 0
    @startTimeMillis = new Date()
    @setState request: setInterval @tick, 1

  stop: ->
    clearInterval @state.request
    @setState request: 0

  gmt: ->
    @setState timezoneOffset: 0

  local: ->
    @setState timezoneOffset: new Date().getTimezoneOffset()

  frameCount: 0

  startTimeMillis: new Date()

  frameCounter: ->
    @frameCount = @frameCount + 1
    @elapsedMillis = new Date() - @startTimeMillis

  render: ->
    React.DOM.div({},
      React.DOM.div({},
        React.DOM.button
          onClick: @start
          disabled: @state.request isnt 0
          'start'
        React.DOM.button
          onClick: @stop
          disabled: @state.request is 0
          'stop'
        React.DOM.button
          onClick: @gmt
          disabled: @state.timezoneOffset is 0
          'gmt'
        React.DOM.button
          onClick: @local
          disabled: @state.timezoneOffset isnt 0
          'local'
        React.DOM.input
          onChange: => @setState svg: event.target.checked
          type: 'checkbox'
          'SVG'
        React.DOM.span
          className: 'fps'
          @frameCount / @elapsedMillis * 1e3
      )
      if @state.svg
        Clock
          millis: @state.millis
          timezoneOffset: @state.timezoneOffset
          frameCounter: @frameCounter
      else
        WebGl
          millis: @state.millis
          timezoneOffset: @state.timezoneOffset
          frameCounter: @frameCounter
    )