paper.install window
window.onload = () ->
    paper.setup 'didlCanvas'

    # for draw:
    tb = require('./sockets.js').touchBus

    # -----------------------------
    Crcl = () ->
        return new Path.Circle {
            center: [0, 0]
            radius: 20
            strokeColor: 'black'
            strokeWidth: 5
            visible: false
        }

    width = view.size.width
    height = view.size.height
    # -----------------------------
    circles = [0...5].map (i) -> Crcl()
    # -----------------------------
    tb.onValue (event) ->
        for i in [0...circles.length]
            circles[i].visible = false
        for item, index in event.alive
            position = [event.touches[item].position.current.x * width,
                        event.touches[item].position.current.y * height]
            circles[index].visible = true
            circles[index].position = position
            color = 'red' if event.touches[item].type == 'up'
            color = 'blue' if event.touches[item].type == 'down'
            color = 'green' if event.touches[item].type == 'drag'
            circles[index].style = { strokeColor: color }
        return
    # -----------------------------
