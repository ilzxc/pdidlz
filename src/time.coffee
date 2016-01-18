time = new Bacon.Bus()
start = new Date().getTime() # start time

poll = () -> 
    t = new Date().getTime()
    time.push .001 * (t - start) # in seconds
 
module.exports = { time, poll } 
