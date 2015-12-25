EventQueue = () ->
    @time = new Date().getTime() # start time of the eventQueue (updated onFrame)
    @length = 1000 # milliseconds
    @events = [] # events remembered by the queue
    @positions = [] # [0...1] describing where in our queue do events lie
    @filterGenerator = (t, l) -> (e) -> (t - e.time) < l
    colorize = (t) -> 
        if (t == "mousedrag") 
            "#0000ff" 
        else if (t == "mousedown") 
            "#00ff00" 
        else "#ff0000"
    @mapGenerator = (t, l, c) -> (e) -> [(t - e.time) / l, c(e.type)]
    @update = () ->
        @time = new Date().getTime()
        filter = @filterGenerator(@time, @length)
        posmap = @mapGenerator(@time, @length, colorize)
        @events = @events.filter (e) -> filter(e)
        @positions = @events.map (e) -> posmap(e)
    @add = (event) ->
        @events.push event
        @update()
    this

Stream = (idx, event_queue) ->
    @vert = 40 * idx
    @eq = event_queue
    @getQueue = () -> @eq
    stream = new Path new Point(20, @vert), new Point(548, @vert)
    stream.strokeColor = '#232323'
    @circles = []
    @update = () ->
        @eq.update()
        for c in @circles 
            c.remove()
        @circles = []
        for p in @eq.positions
            @circles.push new Path.Circle {
                center: [528 * p[0] + 20, @vert]
                radius: 5
                fillColor: p[1]
                strokeColor: "#232323"
            }
    this

paper.install window
window.onload = () ->
    paper.setup 'didlCanvas'
    clickBus = new Bacon.Bus()
    makeEvent = (event) ->
        event.time = new Date().getTime()
        clickBus.push event

    tool = new Tool()
    tool.onMouseDown = (event) ->
        makeEvent event
    tool.onMouseDrag = (event) ->
        makeEvent event
    tool.onMouseUp = (event) ->
        makeEvent event

    stream = new Stream 1, new EventQueue()
    mdstream = new Stream 2, new EventQueue()
    dblstream = new Stream 3, new EventQueue()
    clickBus.onValue (event) -> 
        stream.getQueue().add event
        if event.type == 'mousedown' 
            mdstream.getQueue().add event
            onevents = mdstream.getQueue().events
            if onevents.length > 1
                console.log event.time + ", " + onevents[onevents.length - 2].time
                console.log "diff " + (event.time - onevents[onevents.length - 2].time)
                if (event.time - onevents[onevents.length - 2].time) < 400
                    dblstream.getQueue().add event
        return

    view.onFrame = (event) ->
        stream.update()
        mdstream.update()
        dblstream.update()
