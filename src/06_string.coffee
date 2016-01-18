### string test ###



paper.install window
window.onload = () ->
    paper.setup 'didlCanvas'

    vector = new Point {
        angle: 0
        length: 558 / 3
    }
    string = new Path()
    string.strokeColor = 'black'
    string.strokeWidth = 5
    string.prev_vib = 0
    string.segments = [
        [[10, 160], null, vector.rotate(0)],
        [[558, 160], vector.rotate(-180), null]
    ]
    string.applyMatrix = false
    console.log string

    view.onFrame = (event) ->
        c = string.curves[0]
        c.handle1 = c.handle1.rotate -string.prev_vib
        c.handle2 = c.handle2.rotate string.prev_vib
        vib = 20 * Math.sin(50 * event.time)
        c.handle1 = c.handle1.rotate vib
        c.handle2 = c.handle2.rotate -vib
        string.prev_vib = vib
        string.rotate 1.12
        console.log string.rotation
