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

### value-from-bundle extractor (for now to test things with) ###
getVal = (packets, address, current) -> 
    for p in packets
        if p.address == address
            return p.args[0]
    current

### straight-up json 2 osc: ###
json2osc = (json, timeTag = 0) ->
    # iterate over json
    # add slashes to all keys, store as addresses
    # recurse on objects
    # hand the resulting JSON off to osc bundle maker

### straight-up osc 2 json: ###
osc2json = (array) ->
    result = {}
    for p in packets
        result[getAddr(p)] = getData(p)