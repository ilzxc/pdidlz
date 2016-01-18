s = require './sockets.js'
feedbackBus = s.feedbackBus
feedback = { intensity: 0 }
feedbackBus.onValue (b) -> feedback = b 

paper.install window
window.onload = () ->
    paper.setup 'didlCanvas'

    vector = new Point {
        angle: 0
        length: 558 / 3
    }
    string = new Path {
        strokeColor: 'black'
        strokeWidth: 5
        segments: [
            [[10, 160], null, vector.rotate(0)],
            [[558, 160], vector.rotate(-180), null]
        ]
        applyMatrix: false
    }

    view.onFrame = (event) ->
        c = string.curves[0]
        vib = 20 * feedback.intensity * Math.sin(50 * event.time)
        c.handle1.angle = vib
        c.handle2.angle = 180 - vib
        string.rotate 1.12
