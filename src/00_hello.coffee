### begin by instantiating paper ###
paper.install window
window.onload = () ->
    paper.setup 'didlCanvas'
    ### create a new object & describe its style ###   
    rect = new Path.Rectangle new Point(50, 50), new Size(40, 40)
    rect.style = {
        fillColor: 'grey'
        strokeColor: 'black'
    }

    tool = new Tool() # global window mouse events
    tool.onMouseMove = (event) ->
        rect.position = event.point # follow the mouse
        ### create an odot bundle ###
        bundle = osc.writePacket {
            timeTag: osc.timeTag(0)
            packets: [ address: '/position', args: [rect.position.x, rect.position.y] ]
        }
        ### send an odot bundle ###
        forwardBus.push bundle ## forwardBus from sockets.coffee
    return
