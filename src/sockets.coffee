Touch = require './touchDescriptor.js'

touchDescriptor = new Touch.TouchDescriptor()

### Bacon Busses for sending & receiving data from UDP ###
feedbackBus = new Bacon.Bus()
forwardBus = new Bacon.Bus() 
touchBus = new Bacon.Bus()
### Private variables for identifying sockets & routing data ###
ffsocket_id = 0 # socket id for feedback & forwarding
tsocket_id = 0 # touch socket id

### create feedback & forward socket (didl = 49412) ###
chrome.sockets.udp.create {}, (info) ->
    console.log "creating ffsocket"
    ffsocket_id = info.socketId
    chrome.sockets.udp.bind ffsocket_id, '127.0.0.1', 49412, (result) ->
        if result < 0 then console.log "error binding ffsocket"

### create touch socket (ditd = 49204) ###
chrome.sockets.udp.create {}, (info) ->
    console.log "creating tsocket"
    tsocket_id = info.socketId
    chrome.sockets.udp.bind tsocket_id, '127.0.0.1', 49204, (result) ->
        if result < 0 then console.log "error binding tsocket"

### stream of feedback & touch bundles ###
chrome.sockets.udp.onReceive.addListener (info) ->
    # console.log info
    try 
        result = osc.readPacket info.data, {}
    catch error
        console.log "An error occurred: ", error.message
        return
    if info.socketId is tsocket_id
        touchBus.push touch2json result
    else if info.socketId is ffsocket_id
        feedbackBus.push osc2json result
    return

### bundles sent to forwardBus are currently sent out of udp asap (need my json2osc first) ###
forwardBus.onValue (bundle) ->
    chrome.sockets.udp.send ffsocket_id, (json2osc bundle).buffer, '127.0.0.1', 56765, (sendInfo) ->
            if sendInfo.resultCode < 0 then console.log "error sending stuff"
        return

### json 2 osc: ###
json2osc = (json, timeTag = osc.timeTag(0)) ->
    result = {
        timeTag : timeTag
        packets: []
    }
    for key, value of json
        result.packets.push setOscData key, value, timeTag
    return osc.writePacket result

### for recursion ###
getOscData = (args) ->
    if typeof args != 'object' or Array.isArray(args) is true then return args
    else osc2json args

setOscData = (key, value, tt) ->
    a = '/' + key
    if typeof args != 'object' or Array.isArray(value) is true
        { address: a, args: value }
    else { address: a, args: json2osc key, value, tt }

### straight-up osc 2 json: ###
osc2json = (jsosc) ->
    result = {}
    for p in jsosc.packets
        a = p.address.substring 1, p.address.length
        result[a] = getOscData(p.args)
    result

touch2json = (tuio) ->
    parsed = { timetag: new Date().getTime() }
    for p in tuio.packets
        if p.args[0] == 'set'
            parsed[p.args[1]] = [2...p.args.length].map (i) -> p.args[i]
        else
            parsed[p.args[0]] = [1...p.args.length].map (i) -> p.args[i]
    touchDescriptor = touchDescriptor.update parsed
    return touchDescriptor

module.exports = {feedbackBus, forwardBus, touchBus}