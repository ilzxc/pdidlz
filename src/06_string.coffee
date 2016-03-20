s = require './sockets.js'
feedbackBus = s.feedbackBus
feedback = { intensity: 1 }
feedbackBus.onValue (b) -> feedback = b 

wiggle = (path, time) ->
    ### wiggles the way you'd expect a string to wiggle ###
    vib = 30 * feedback.intensity * Math.sin(50 * time)
    for c in path.segments
        c.handleIn.angle = c.angle[0] + vib
        c.handleOut.angle = c.angle[1] - vib

waggle = (path, time) ->
    ### wags like the dog wags it's tail, wonky ###
    vib = 30 * feedback.intensity * Math.sin(50 * time)
    for c in path.segments
        c.handleIn.angle = c.angle[0] + vib
        c.handleOut.angle = c.angle[1] + vib

autoHandles = (seg) ->
    if seg.angle is undefined then seg.angle = [null, null]
    next = seg.next
    if next != null
        if next.angle is undefined then next.angle = [null, null]
        np = next.point
        cp = seg.point
        diff = new Point np.x - cp.x, np.y - cp.y
        l = diff.length / 3
        a = diff.angle
        b = a - 180 
        seg.handleOut = new Point { angle: a, length: l }
        next.handleIn = new Point { angle: b, length: l }
        seg.angle[1] = a
        next.angle[0] = b

stringModel = (start, stop, index) ->
        @start = start
        @end = stop
        @index = index
        return this

reconstruct_string = () ->
    ### the not-good stateless version: ###
    dstring = []
    prevsion = start
    counter = 0
    for touch in sorted_touches
        dstring.push new string previous, touch.point, counter
        previous = touch.point
        ++counter
    dstring.push new string previous end counter

### main ---------------------------------------------------- ###

paper.install window
window.onload = () ->
    paper.setup 'didlCanvas'

    strings = [new stringModel new Point(10, 160), new Point(558, 160), 0]

    string = new Path {
        strokeColor: 'black'
        strokeWidth: 5
        segments: [
            [[10, 160 - 88]],
            [[558, 160 + 88]]
        ]
        applyMatrix: false
    }
    string.style = {
        strokeColor: 'grey'
        strokeWidth: 10
        strokeJoin: 'round'
    }

    ###
    handleless = (seg for seg in string.segments when seg.hasHandles() is false)
    handlefull = (seg for seg in string.segments when seg.hasHandles() is true)
    console.log handleless
    console.log handlefull
    ###

    for seg in handlefull
        # todo: fix this
        if seg.angle is undefined then seg.angle = [seg.handleOut.angle, seg.handleIn.angle]

    for seg in handleless
        if seg.angle is undefined then seg.angle = [null, null]
        next = seg.next
        if next != null
            if next.angle is undefined then next.angle = [null, null]
            np = next.point
            cp = seg.point
            diff = new Point np.x - cp.x, np.y - cp.y
            l = diff.length / 3
            a = diff.angle
            b = a - 180 
            seg.handleOut = new Point { angle: a, length: l }
            next.handleIn = new Point { angle: b, length: l }
            seg.angle[1] = a
            next.angle[0] = b

    # aw, man, this is annoying:
    string.applyMatrix = false

    view.onFrame = (event) ->
        # need to fix this, also
        wiggle string, event.time 
        string.rotate 1.12, new Point(284, 160)
