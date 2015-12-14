### create an object to store feedback data ###
feedback = { rotation: 0 }

### register feedback stream ###
feedbackBus.onValue (result) -> 
    feedback = osc2json result
    console.log feedback

### paper scene: ###
paper.install window
window.onload = () ->
    paper.setup 'didlCanvas'
    rect = new Path.Rectangle new Point(284 - 100, 160 - 100), new Size(200, 200)
    rect.style = {
        fillColor: 'blue'
        strokeColor: 'orange'
        strokeWidth: 10
    }

    view.onFrame = (event) ->
        rect.rotate feedback.rotation
        return
