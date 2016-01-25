tb = require('./sockets.js')

Crcl = () ->
    return new Path.Circle {
        center: [0, 0]
        radius: 20
        strokeColor: 'black'
        strokeWidth: 5
        visible: false
    }

paper.install window
window.onload = () ->
    paper.setup 'didlCanvas'
    width = view.size.width
    height = view.size.height

    circles = [0...5].map (i) -> Crcl()

    tb.touchBus.onValue (event) ->
        for item, index in event.alive
            position = [event.touches[item].position.current[0] * width,
                        event.touches[item].position.current[1] * height]
            circles[index].position = position
            circles[index].visible = true
        for i in [(index + 1)...circles.length]
            circles[i].visible = false

    view.onFrame = (event) ->
        return


