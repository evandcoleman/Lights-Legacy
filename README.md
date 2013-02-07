# Lights: control RGB LEDs from your iPhone #

`Lights` is an iOS app that controls an RGB LED strip connected to an Arduino.

`Lights` allows you to change the color of the LEDs, animate the LEDs, and schedule events.

## How does it work? ##

`Lights` uses a central WebSocket server to proxy commands from the iOS app to the Arduino. In theory, this project could be modified so that the WebSocket server runs directly on the Arduino, thus removing the need for a separate server, but that is outside the scope of this project.

**Note:** See the `doc` folder for more information such as the app's API in case you wish to code your own Arduino sketch or WebSocket server.

## Parts ##

Your exact setup may vary, but here is a list of parts that my setup uses (All links are to [Adafruit.com](http://adafruit.com), but many parts can be found cheaper elsewhere on the internet):

* [Arduino Uno](https://www.adafruit.com/products/50)
* [Arduino Ethernet Shield](https://www.adafruit.com/products/201)
* [WS2801 RGB LEDs](https://www.adafruit.com/products/322)
	
	**Note:** Any WS2801 LED strip will work without modification to my Arduino code.
* [DC Power Adapter](https://www.adafruit.com/products/368)
* [Power Supply](https://www.adafruit.com/products/276)

	**Note:** These last two items on this list may vary depending on your exact needs. For example, to power more LEDs, you may need a more powerful power supply.
* [4-pin JST SM Cables](https://www.adafruit.com/products/578)

	This is just to connect the LEDs to the Arduino. I, for example, just used a few breadboard wires that I had lying around in place of this.



## Usage ##

### Arduino ###

#### Installation ####

1. The Arduino sketch requires several third-party libraries, all of which can be found on Github. Download each one and place it in the `libraries` folder of your Arduino directory, which, in my setup, is `~/Documents/Arduino/`.
	* [WebSocketClient](https://github.com/hadleyrich/ArduinoWebsocketClient)
	* [aJSON Library](https://github.com/interactive-matter/aJson)
	* [WS2801 Library](https://github.com/adafruit/Adafruit-WS2801-Library)
	
2. Open the Arduino sketch `Lights.ino` which is included in this repository.
3. Edit lines 7 and 8. Line 7 is the MAC address of the Arduino ethernet shield. This can be found on a sticker on newer shields. Line 8 is the local IP address to be assigned to the Arduino on your network.
4. You may need to edit lines 10-12 depending on your configuration.
5. Edit lines 18-20. These lines tell the Arduino where your WebSocket server is.
6. Upload the sketch to your Arduino.

#### Wiring ####

Follow the tutorial [here](http://learn.adafruit.com/12mm-led-pixels/wiring).

### WebSocket Server ###

1. Install [node.js](http://nodejs.org)
2. Install required Node packages:
	* [ws](https://github.com/einaros/ws): 
		```npm install ws```
	* [cubby](https://github.com/icodeforlove/node-cubby): 
		```npm install cubby```
	* [cron](https://github.com/ncb000gt/node-cron): 
		```npm install cron```
	* You may also want to install [forever](https://github.com/nodejitsu/forever) to keep your server running in case of a crash: 
		```npm install forever -g```
3. Upload the app.js file included in this repository to your server and start it.
	```forever start app.js```
	
### iOS App ###

Nothing special is required for this part. Just open the Xcode project, build, and install. The server address can be set from inside the app.

## TODO ##

* Add more animations
* Allow editing of scheduled events
* Add speed and brightness settings for animations
* Make Mac version