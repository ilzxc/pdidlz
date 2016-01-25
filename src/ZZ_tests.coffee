s = require './sockets.js'
forward = s.forwardBus

connection = (parent, child) ->
    @parent = parent
    @next = child
    @segment = new Path {
        segments: [parent.position, child.position]
        strokeColor: 'black'
        strokeWidth: 0.5
    }
    @make = (payload) ->
        result = new Path.Circle {
            position: parent.position
            radius: 3
            fillColor: { hue: Math.random() * 360, saturation: 1, brightness: .5 }
            payload: payload
            alive: true
        }
        result.birth = new Date().getTime()
        return result
    @datum = []
    @duration = @segment.length # in milliseconds
    @start = (payload) ->
        @datum.push @make payload
    @update = (frame_event) ->
        for d in @datum
            time_ratio = (new Date().getTime() - d.birth) / @duration
            if time_ratio < 1
                d.position = @segment.getPointAt time_ratio * @segment.length
            else
                d.alive = false # remove from model
                d.remove() # remove from view
                @next.trigger d.payload
        @datum = @datum.filter (d) -> d.alive == true
        return
    return this


node = (x, y, parent = null) ->
    @position = new Point x, y
    @connection = null
    if parent != null
        parent.connection = new connection parent, this
    @view = new Path.Circle {
        position: @position
        radius: 6
        strokeColor: 'black'
        strokeWidth: 0.5
        fillColor: 'white'
        model: this
    }
    @update = (event) ->
        if @connection != null
            @connection.update event
    @view.onMouseDown = (event) ->
        @model.trigger "gogogo!"
    @trigger = (payload) ->
        forward.push { command: 'bang' }
        if @connection != null
            @connection.start payload
    return this

paper.install window
window.onload = () ->
    paper.setup 'didlCanvas'

    nodes = [new node 10, view.size.height * 0.5]
    for i in [0...10]
        nodes.push new node(Math.random() * view.size.width, Math.random() * view.size.height, nodes[i])

    view.onFrame = (event) ->
        for n in nodes
            n.update event
        