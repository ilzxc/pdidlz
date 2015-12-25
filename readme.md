# didl prototypes
## a sketchbook

### warning

A research project in active pursuit.

### purpose

Distributed Interaction Description Language (didl) is a framework for visual, declarative programming of performative graphical controllers for music instruments. The code in this repo is a set of prototypes to inform the design -- tiny demos to explore ideas through, without any pretense of this implementation being a sensible product of any kind.

### motivation

Didl started as an odot scripting layer for graphical objects (original demo implemented in Cinder, and the first take on the IDE implemented in JUCE). However, while odot is undergoing a redesign, I needed a sensible test-bed for creating graphical controllers. After looking at V8 and Lua in C++, however, I realized that the time cost of developing a robust test bed was more than I could afford. Thus, this testbed cobbles together a few JavaScript libraries to prototype the research problems. Graphics & shapes are obtained via HTML5 canvas and Paper.js. Bacon.js serves as a prototype for the functional reactive semantics.

The didl prototypes will only exist as a Chrome App, since that gives me access to UDP sockets without having to run a server and mixing it all up with websockets. Multitouch is tested through TUIOPad for iOS (by Mehmet Akten & Martin Kaltenbrunner).

The goal of this repo is to demonstrate the authoring process of didl instruments. Particularly, I am writing code to ensure that didl instrument authors won't have to.

### installing dependencies

At the moment, needs [CoffeeScript](http://coffeescript.org) at the global level for build scripts to work -- `sudo npm install -g coffee-script` will do the trick. Current dependencies are [Bacon](https://baconjs.github.io), [Paper](http://paperjs.org), and [osc.js](https://github.com/colinbdclark/osc.js). Install them by running `bower install` in the project directory. (`npm install -g bower` if you don't have bower).

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

#### multitouch:

Multitouch is supported through TUIOPad and is tested using the iOS version of the app. To get multitouch to the Chrome App, open `_touch_node.maxpat` Max patch, and leave it running. (Max patch adds timetags to all touch interactions & forwards a didl-esque collection of stuff to the application).

#### uninstall:

Commands to uninstall CoffeeScript & Bower should go here.

### didl summarized

* each prototype initializes as follows:
	* opening a udp send & a udp receive sockets:
		* sends to "didl" -- `49412`
		* receives on "server" -- `49419`
		* multitouch data is received on "ditd" -- `49204`
	* instantiating a canvas w/ objects & scripts
* each prototype does the following every frame:
	* constructs the common namespace from:
		* user input
		* feedback data
		* time increment
	* computes new state
	* updates stateful objects (`paper`)

### examples roadmap

* **`00_hello`** : the hello world equivalent to didl (sending cursor location to Max)
* **`01_feedback_basic`** : Max audio value driving a graphic object
* **`02_primitive_trigger`** : button reacting to the sound it triggers
* `03_drum` : circles for varied harmonics
* `04_create_on_touch` : dynamically generated objects from touch
* `05_create_on_feedback` : dynamically generated objects from feedback
* `06_string` : a polyphonic string
* `07_pitch_controls` : a set of ideas for various pitch controls (with many inspired by the repertoire)

### touch examples roadmap

* `mouse_basic` : wrapping paper callbacks into signal streams
* `double_click` : functional transformation of onset events to double-click events
* `drag_into` : objects responding to drag events originating outside of objects
* `dynamic_route` : touch signal dispatch to multiple objects

### todos

* clean up everything with RequireJS and proper modules
* create a demo viewer and make it the entry level for the app
* bacon-wrap paper callbacks
* redo `01_feedback_basic` and `02_primitive_trigger` to be graphically controlled