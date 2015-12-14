### begin by instantiating paper ###
paper.install window
window.onload = () ->
    paper.setup 'didlCanvas'
    ### create a new object & describe its style ###   
    rect = new Path.Circle new Point(0, 0), 40
    rect.style = {
        fillColor: 'grey'
        strokeColor: 'black'
        strokeWidth: 10
    }

    tool = new Tool() # global window mouse events
    tool.onMouseMove = (event) ->
        rect.position = event.point # follow the mouse
        ### send an odot bundle ###
        forwardBus.push json2osc { position: [rect.position.x, rect.position.y] }
    return
