s = require './sockets.js'
feedbackBus = s.feedbackBus
feedback = { intensity: 1 }
feedbackBus.onValue (b) -> feedback = b 

wiggle = (geom, time) ->
    for c in geom.curves
        vib = 20 * feedback.intensity * Math.sin(30 * time)
        c.handle1.angle = vib
        c.handle2.angle = 180 - vib

paper.install window
window.onload = () ->
    paper.setup 'didlCanvas'

    vector = new Point {
        angle: 0
        length: 558 / 3
    }

    ###string = new Path {
        strokeColor: 'black'
        strokeWidth: 5
        segments: [
            [[10, 160], null, vector.rotate(0)],
            [[568 / 2, 160], vector.rotate(0), vector.rotate(-180)],
            [[558, 160], vector.rotate(-180), null]
        ]
        applyMatrix: false
    }###
    string = new Path.Rectangle new Point(284 - 100, 160 - 100), new Size(200, 200)
    string.style = {
        fillColor: 'blue'
        strokeColor: 'orange'
        strokeWidth: 10
    }
    string.segments[0].handleIn = new Point { angle: 90, length: 200 / 3 }
    string.segments[0].handleOut = new Point { angle: 0, length: 200 / 3 }
    string.fullySelected = true
    string.applyMatrix = false

    view.onFrame = (event) ->
        wiggle string, event.time 
        string.rotate 1.12, new Point(284, 160)
