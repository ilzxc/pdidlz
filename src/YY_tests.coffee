s = require './sockets.js'
feedbackBus = s.feedbackBus
forwardBus = s.forwardBus

feedback = { intensity: 0 }
feedbackBus.onValue (result) -> feedback = result # fucking fix this

max = Math.max
min = Math.min

wiggle = (obj, frame, touch, rtch) ->
    ### wiggles the way you'd expect a string to wiggle ###
    # todo: figure out implicit functions (if possible)
    # for now, we compute 8 in-between values and hit-test them all
    path = obj.segment
    if touch != null
        times = [7..0].map((i) -> frame.time - (frame.delta * i / 7))
    else 
        times = [frame.time]

    # console.log times # debug

    for t in times
        vib = 10 * feedback.intensity * Math.sin(111 * t)
        for c in path.segments
            c.handleIn.angle = c.angle[0] + vib
            c.handleOut.angle = c.angle[1] - vib
        if touch != null then rtch.shape.proc touch, obj
        if rtch.shape.tracking != null then break

    return

setupHandles = (segment) ->
    ###
        Ensures the handles for the string are well-placed:
        ensures that when angle of handle is zero, the linear
        segment is unchanged.
    ###
    for seg in segment
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
            next.angle[0] = b # handleIn of next point
            seg.angle[1] = a # handleOut of the current point
    return

createOffset = (string_segments, touch) ->
    ###
        Creates a fiducial denoting the perpendicular offset
        of the string (upon being touched)
    ###
    start = string_segments[0].point
    end = string_segments[string_segments.length - 1].point
    xd = end.x - start.x
    yd = end.y - start.y
    xsq = xd * xd
    ysq = yd * yd
    k = (yd * (touch.x - start.x) - xd * (touch.y - start.y)) / (xsq + ysq)
    offsetLine = new Path({
        segments: [touch, [touch.x - k * yd, touch.y + k * xd]]
        strokeColor: 'red'
        strokeWidth: 1
    }).removeOnDrag().removeOnUp() # dragging & releasing clears the line
    return offsetLine.length

### THIS IS WHY YOU SHOULD NOT WORK WHILE SLEEPY, KIDS ###
# TODO:
#   - move the @shape.proc into its own class (wtf in renderTouch?)
#   - make renderTouch encapsulate the .removeOnUp() shape and do nothing else
renderTouch = () ->
    @shape = new Path.Circle new Point(0, 0), 10
    @shape.style = {
        strokeColor: 'black'
        strokeWidth: 3
    }
    @shape.visible = false
    @shape.tracking = {
        object: null
        offset: null
    }
    @shape.proc = (event, obj) ->
        if event.type == 'mousedown'
            if obj.segment.hitTest event.point, { stroke: true }
                obj.segment.onMouseDrag event
                @tracking.object = obj
            @position = event.point
            @visible = true
        if event.type == 'mousedrag'
            if @tracking.object == null
                intersects = obj.segment.getIntersections this
                if intersects.length != 0
                    obj.segment.onMouseDrag event
                    @tracking.object = obj
                else
                    intersects = obj.segment.getIntersections new Path event.lastPoint, event.point
                    if intersects.length != 0
                        obj.segment.onMouseDrag event
                        @tracking.object = obj
            else 
                @tracking.object.segment.onMouseDrag event
                @tracking.offset = createOffset obj.segment.segments, event.point

            @position = event.point
        if event.type == 'mouseup'
            @last = null
            if @tracking.object != null
                forwardBus.push { 
                    index: 0
                    pluck: @tracking.offset 
                }
                @tracking.object.segment.onMouseLeave event
                @tracking.object = null
            @visible = false
        return event
    return this


String = (start, end) ->
    @start = new Path.Circle start, 10
    @end = new Path.Circle end, 10
    @start.style = @end.style = { fillColor: 'black' } 

    @segment = new Path {
        segments: [start, end]
        applyMatrix: false
        strokeColor: 'black'
        strokeWidth: 7
    }
    @segment.onMouseDrag = (event) ->
        @clearHandles()
        @segments = [@segments[0], event.point, @segments[@segments.length - 1]]
        forwardBus.push { 
            index: 0
            pluck: 0 
        }
    @segment.onMouseLeave = (event) ->
        @segments = [@segments[0], @segments[@segments.length - 1]]
        setupHandles @segments # ensure we have handles for vibration

    @handle = new Group()
    @handle.addChildren [@start, @end, @segment]
    return this

### main ###

paper.install window
window.onload = () ->
    paper.setup 'didlCanvas'
    mouse_segment = new Path { segments: [[0, 0], [1, 1]] }
    h = 0.5 * view.size.height
    string = new String new Point(0.05 * view.size.width, h), new Point(0.9 * view.size.width, h)
    setupHandles string.segment.segments

    rt = new renderTouch()
    touch = new Tool()
    lev = null
    touch.onMouseDown = (event) -> 
        lev = rt.shape.proc event, string
    touch.onMouseUp = (event) -> 
        rt.shape.proc event, string
        lev = null
    touch.onMouseDrag = (event) -> 
        lev = rt.shape.proc event, string

    view.onFrame = (event) ->
        # need to ensure that the string is not currently being touched:
        if string.segment.segments.length == 2 # this means wiggle is a go:
            wiggle string, event, lev, rt

    joke = new PointText {
        point: [view.size.width * .5, view.size.height - 5]
        content: 'ce ne est pas une chaine'
        justification: 'center'
        fillColor: 'black'
        fontSize: 8
    }