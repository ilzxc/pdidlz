### Bacon Busses for sending & receiving data from UDP ###
feedbackBus = new Bacon.Bus()
forwardBus = new Bacon.Bus() 
sid = 0 # socket id, used internally

### constructor ###
chrome.sockets.udp.create {}, (info) ->
    sid = info.socketId
    chrome.sockets.udp.bind sid, '127.0.0.1', 56766, (result) ->
        if result < 0 then console.log "error binding socket"

### stream of feedback bundles ###
chrome.sockets.udp.onReceive.addListener (info) ->
    try 
        result = osc.readPacket info.data, {}
    catch error
        console.log "An error occurred: ", error.message
        return
    feedbackBus.push result
    return

### bundles sent to forwardBus are currently sent out of udp asap (need my json2osc first) ###
forwardBus.onValue (bundle) ->
    chrome.sockets.udp.send sid, bundle.buffer, '127.0.0.1', 56765, (sendInfo) ->
            if sendInfo.resultCode < 0 then console.log "error sending stuff"
        return

### straight-up json 2 osc: ###
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
