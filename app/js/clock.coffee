window.Clock = React.createClass({
   getAngle: (cycleTime) ->
      360 * (this.getMillis() % cycleTime) / cycleTime

   getMillis: ->
      this.props.millis - this.props.timezoneOffset * 60000

   render: ->
      @props.frameCounter()

      React.DOM.svg({
            viewBox: '-1 -1 2 2'
            width: '480'
            height: '480'
         },
         React.DOM.circle(
            r: 1
            fill: 'ivory'),
         Hand(
            length: 0.7
            width: 0.1
            angle: this.getAngle(12 * 60 * 60000)
         ),
         Hand(
            length: 0.9
            width: 0.05
            angle: this.getAngle(60 * 60000)
         ),
         Hand(
            length: 0.9
            width: 0.01
            angle: this.getAngle(60000)
         )
      )
})
