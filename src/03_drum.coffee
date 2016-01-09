### variables for our drum ###
num_fiducials = 5
width = 284 * 2
height = 160 * 2
### feedback defaults to 0 for each drum circle: ###
feedback = { intensities: [0...num_fiducials].map () -> 0 } 
feedbackBus.onValue (b) -> feedback = osc2json b # todo: eliminate osc2json call, it's always necessary

### constructor for one drum fiducial ###
drum = (index, total) ->
    radius = (height * .5) - (160 * (index / total))
    console.log radius
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
        forwardBus.push json2osc { index: index, command: 'bang' }
    result.onMouseUp = (event) ->
        console.log "mouse up in " + index
        forwardBus.push json2osc { index: index, command: 'next' }
    return result

### paper stuff & global controls ###
paper.install window
window.onload = () ->
    paper.setup 'didlCanvas'
    circles = [0...num_fiducials].map (i) -> drum(i, num_fiducials)

    tool = new Tool()
    tool.onMouseDown = (event) ->
        console.log "mouse down in global " + event.point
