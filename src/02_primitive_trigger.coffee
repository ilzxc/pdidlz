### create an object to store feedback data & plug a stream into it ###
feedback = { intensity: 0 }
feedbackBus.onValue (result) -> feedback = osc2json result

### instantiate paper ###
paper.install window
window.onload = () ->
    paper.setup 'didlCanvas'
    button = new Path.Circle new Point(284, 160), 100
    button.style = {
        fillColor: 'red'
        strokeColor: 'green'
        strokeWidth: 10
    }
    button.prev_scale = 1 # hack because scaling sucks & no dynamic radii in Paper.js

    ### frame-by-frame callback (needs to be called by Bacon for synch) ###
    view.onFrame = (event) ->
        new_scale = 200 / (200 + (30 * feedback.intensity * Math.sin( event.time * 50 )))
        button.scale 1 / button.prev_scale # undo old scale
        button.scale new_scale # set new scale
        button.prev_scale = new_scale # store scale so we can undo it later
        return

    ### controller callbacks ###
    button.onMouseDown = (event) ->
        forwardBus.push json2osc { command: 'bang' }     
    button.onMouseUp = (event) ->
        forwardBus.push json2osc { command: 'next' }
