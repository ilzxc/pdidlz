# didl prototypes
## a sketchbook

### warning

A research project in active pursuit.

### installing dependencies

At the moment, needs [CoffeeScript](http://coffeescript.org) at the global level for build scripts to work -- `sudo npm install -g coffee-script` will do the trick. Current dependencies are [Bacon](https://baconjs.github.io), [Paper](http://paperjs.org), and [osc.js](https://github.com/colinbdclark/osc.js). Install them by running `bower install` in the project directory. (`npm install -g bower` if you don't have bower)

<!-- [Ramda](http://ramdajs.com/0.18.0/index.html) -->

### building & running

#### build:

```
git clone https://github.com/ilzxc/pdidlz.git && cd pdidlz
sudo npm install -g coffee-script
sudo npm install -g bower && bower install
./make.sh
```
#### run:

* Open Google Chrome
* Window -> Extensions
* Check the box next to "Developer Mode"
* Click on "Load unpacked extension"
* Navigate to the repo folder and click "Select"
	* Extension should pop up as *didlies*
* Click "Launch"

### working with audio generators

***coming soon*** -- until then, see `/max`

### didl summarized

* each prototype initializes as follows:
	* opening a udp send & a udp receive sockets:
		* sends to "didl" -- `49412`
		* receives on "server" -- `49419`
	* instantiating a canvas w/ objects & scripts
* each prototype does the following every frame:
	* construct the common namespace from:
		* user input
		* feedback data
		* time increment
	* compute new state
	* update stateful objects (`paper`)

### examples roadmap

* **`00_hello`** : the hello world equivalent to didl (sending cursor location to Max)
* **`01_feedback_basic`** : Max audio value driving a graphic object
* **`02_primitive_trigger`** : button reacting to the sound it triggers
* `03_drum` : circles for varied harmonics
* `04_create_on_touch` : dynamically generated objects from touch
* `05_create_on_feedback` : dynamically generated objects from feedback (Max)
* `06_string` : a polyphonic string
* `07_pitch_controls` : a set of ideas for various pitch controls (with many inspired by the repertoire)

### todos

* bacon-wrap paper callbacks
* redo `01_feedback_basic` and `02_primitive_trigger` to be graphically controlled