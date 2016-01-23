# string maker sketch
###
s = require './sockets.js'
# todo: fb = require './feedback.js'
feedbackBus = s.feedbackBus
feedback = { intensity: 1 } 
feedbackBus.onValue (b) -> feedback = b 
###

makesine = (width, height, pts) ->
    result = []
    h = height / 2
    ystep = Math.PI * 2 / (pts - 1)
    xstep = width / (pts - 1)
    for i in [0...pts]
        x = xstep * i
        y = h - (h * Math.sin(ystep * i)) # subtract so looks right
        result.push [[x, y], null, null]
    console.log result
    result


sineView = (position) ->
    background = new Path.Rectangle new Point(0, 0), new Size(50, 25)
    background.style = { fillColor: '#dedede' }

    icon = new Path makesine 50, 25, 16
    icon.style = {
        strokeColor: 'blue'
        strokeWidth: 2
    }    

    @handle = new Group()
    @handle.addChildren [background, icon]
    @handle.translate position
    @handle.onMouseDrag = (event) -> @translate event.delta
    return this


paper.install window
window.onload = () ->
    paper.setup 'didlCanvas'

    sv = new sineView(0, 0)
    console.log sv

    tool = new Tool()
    tool.onMouseDown = (event) ->
        return
    tool.onMouseDrag = (event) ->
        return
    tool.onMouseUp = (event) ->
        return
    tool.onMouseMove = (event) ->
        return

    tool.onKeyDown = (event) ->
        return
    tool.onKeyUp = (event) ->
        return