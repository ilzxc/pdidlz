# touch descriptor

include = (item, array) ->
    if array.indexOf(item) != -1
        return true
    return false

Touch = (set, timetag) ->
    @type = 'down'
    @position = {
        current: { x: set[0], y: set[1] }
        previous: { x: null, y: null } 
    }
    @velocity = {
        current: { x: set[2], y: set[3] }
        previous: { x: null, y: null }
    }
    @acceleration = {
        current: set[4]
        previous: null
    }
    @timetag = {
        started: timetag
        current: timetag
    }
    @update = (set, timetag) ->
        ###
            Note that updates generates a new object, since the older
            mutable version had issues -- rapidly removing 3 or 5 touches
            at once caused the Bacon.Bus event handler throw errors 
            about accessing non-existent fields.
        ###
        result = new Touch set, timetag
        result.type = 'drag'
        result.position.previous = {
            x: @position.current.x
            y: @position.current.y
        }
        result.velocity.previous = {
            x: @velocity.current.x
            y: @velocity.current.y
        }
        result.acceleration.previous = @acceleration.current
        result.timetag.started = @timetag.started
        return result
    @clone = (other, timetag) ->
        other.timetag.current = timetag
        other.type = 'up'
        return other

    return this

TouchDescriptor = () ->
    @alive = []
    @timetag = null
    @touches = {}
    @update = (tuio) ->
        ###
            Note that updates generates a new object, since the older
            mutable version had issues -- rapidly removing 3 or 5 touches
            at once caused the Bacon.Bus event handler throw errors 
            about accessing non-existent fields.
        ###
        # create a new snapshot of state:
        result = new TouchDescriptor()
        # result.alive = i for i in @alive
        result.timetag = tuio.timetag # set the new timetag to a proper value
        # for every touch in TUIO bundle:
        for item in tuio.alive
            result.alive.push item # register touch as alive
            if include item, @alive
                # if an item already exists, clone touch w/ changes:
                result.touches[item] = @touches[item].update tuio[item], tuio.timetag
            else
                # otherwise create a new item:
                result.touches[item] = new Touch tuio[item], tuio.timetag
        # clear touches that are gone:
        for item in @alive
            if not include item, tuio.alive # if it's not in the incoming packet
                if @touches[item].type != 'up' # if it's not up
                    result.alive.push item # register as alive, still
                    # create a new copy of self:
                    result.touches[item] = @touches[item].clone @touches[item], tuio.timetag
        # else: we do nothing, no copy is made
        return result
    return this

module.exports = { TouchDescriptor }


                