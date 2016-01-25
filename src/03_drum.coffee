s = require './sockets.js'
feedbackBus = s.feedbackBus
forwardBus = s.forwardBus



### paper stuff & global controls ###
paper.install window
window.onload = () ->
    paper.setup 'didlCanvas'

    ### variables for our drum ###
    num_fiducials = 5
    width = 284 * 2
    height = 160 * 2

    ### feedback defaults to 0 for each drum circle: ###
    feedback = { intensities: [0...num_fiducials].map () -> 0 } 
    feedbackBus.onValue (b) -> feedback = b 

    ### constructor for one drum fiducial ###
    drum = (index, total) ->
        radius = (height * .5) - (160 * (index / total))
        result = new Path.Circle new Point(width / 2, height / 2), radius
        result.style = {
            fillColor: 'white'
            strokeColor: 'black'
            strokeWidth: 10 * (total - index) / total
        }
        result.radius = radius
        result.prevScale = 1
        phase = 2 * Math.PI * (index / total)
        result.onFrame = (event) ->
            if feedback.intensities[index] != 0
                newScale = radius / (radius + (30 * feedback.intensities[index] * Math.sin(event.time * 50 + phase)))
            else
                newScale = 1
            result.scale 1 / result.prevScale
            result.scale newScale
            result.prevScale = newScale
            return
        result.onMouseDown = (event) ->
            console.log "mouse down in " + index
            forwardBus.push { index: index, command: 'bang' }
        result.onMouseUp = (event) ->
            console.log "mouse up in " + index
            forwardBus.push { index: index, command: 'next' }
        return result

    circles = [1..num_fiducials].map (i) -> new drum(i, num_fiducials)

    ### touch signal stuff ###
    touch_signal = new Bacon.Bus()
    touch_signal.onEvent = (event) ->
        # ignore events outside of the circles:
        in_drum = circles[circles.length - 1].contains event.point


    tool = new Tool()
    tool.onMouseDown = (event) ->
        touch_signal.push event
    tool.onMouseDrag = (event) ->
        touch_signal.push event
    tool.onMouseUp = (event) ->
        touch_signal.push event
