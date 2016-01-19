s = require './sockets.js'
feedbackBus = s.feedbackBus
feedback = { intensity: 1 }
feedbackBus.onValue (b) -> feedback = b 

wiggle = (path, time) ->
    vib = 40 * feedback.intensity * Math.sin(30 * time)
    for c in path.segments
        c.handleIn.angle = c.angle[0] + vib
        c.handleOut.angle = c.angle[1] + vib

paper.install window
window.onload = () ->
    paper.setup 'didlCanvas'

    vector = new Point {
        angle: 0
        length: 558 / 3
    }

    # string = new Path {
    #     strokeColor: 'black'
    #     strokeWidth: 5
    #     segments: [
    #         [[10, 160 - 88], null, vector.rotate(0)],
    #         [[568 / 2, 160], vector.rotate(0), vector.rotate(-180)],
    #         [[558, 160 + 88], vector.rotate(-180), null]
    #     ]
    #     applyMatrix: false
    # }
    string = new Path.RegularPolygon new Point(284, 160), 7, 100
    # string = new Path.Rectangle new Point(284 - 100, 160 - 100), new Size(200, 200)
    string.style = {
        fillColor: 'blue'
        strokeColor: 'orange'
        strokeWidth: 10
    }

    for seg in string.segments
        if seg.angle is undefined then seg.angle = [null, null]
        next = seg.next
        if next != null
            if next.angle is undefined then next.angle = [null, null]
            np = next.point
            cp = seg.point
            diff = new Point np.x - cp.x, np.y - cp.y
            console.log diff
            l = diff.length / 3
            a = diff.angle
            b = a - 180 
            seg.handleOut = new Point { angle: a, length: l }
            next.handleIn = new Point { angle: b, length: l }
            seg.angle[1] = a
            next.angle[0] = b

    # string.fullySelected = true
    string.applyMatrix = false

    view.onFrame = (event) ->
        wiggle string, event.time 
        # string.rotate 1.12, new Point(284, 160)
