# touch descriptor

include = (item, array) ->
    if array.indexOf(item) != -1
        return true
    return false

Touch = (set, timetag) ->
    @type = 'down'
    @position = {
        current: [set[0], set[1]]
        previous: [null, null]
    }
    @velocity = {
        current: [set[2], set[3]]
        previous: [null, null]
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
        @type = 'drag'
        for item in [@position, @velocity, @acceleration]
            item.previos = item.current
        @position.current = [set[0], set[1]]
        @velocity.current = [set[2], set[3]]
        @acceleration.current = set[4]
        @timetag.current = timetag
        return
    return this

TouchDescriptor = () ->
    @alive = []
    @timetag = 0
    @touches = {}
    @update = (tuio) ->
        @timetag = tuio.timetag
        # update all touches as necessary:
        for item in tuio.alive
            if include item, @alive
                @touches[item].update tuio[item], tuio.timetag
            else
                @alive.push item
                @touches[item] = new Touch tuio[item], tuio.timetag
        # remove lifted touches:
        remove = []
        for item, index in @alive
            if not include item, tuio.alive
                if @touches[item].type == 'up'
                    remove.push [item, index]
                else 
                    @touches[item].type = 'up'
        # remove the touches
        for r in remove
            delete @touches[r[0]]
            @alive.splice r[1], 1
        return
    return this

module.exports = {TouchDescriptor}


                