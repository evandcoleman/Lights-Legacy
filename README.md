# Lights: control your lights from your iPhone #

`Lights` is an iOS app that controls an RGB LED strip connected to an Arduino.

`Lights` allows you to change the color of the LEDs, animate the LEDs, and schedule events.

`Lights` also allows you to control X10 devices.

## How does it work? ##

`Lights` uses a central WebSocket server to proxy commands from the iOS app to the Arduino. In theory, this project could be modified so that the WebSocket server runs directly on the Arduino, thus removing the need for a separate server, but that is outside the scope of this project.

**Note:** See the `doc` folder for more information such as the app's API in case you wish to code your own Arduino sketch or WebSocket server.

## Parts ##

Your exact setup may vary, but here is a list of parts that my setup uses (All links are to [Adafruit.com](http://adafruit.com), but many parts can be found cheaper elsewhere on the internet):

* [Arduino Uno](https://www.adafruit.com/products/50)
* [WS2801 RGB LEDs](https://www.adafruit.com/products/322)
	
	**Note:** Any WS2801 LED strip will work without modification to my Arduino code.
* [DC Power Adapter](https://www.adafruit.com/products/368)
* [Power Supply](https://www.adafruit.com/products/276)

	**Note:** These last two items on this list may vary depending on your exact needs. For example, to power more LEDs, you may need a more powerful power supply.
* [4-pin JST SM Cables](https://www.adafruit.com/products/578)

	This is just to connect the LEDs to the Arduino. I, for example, just used a few breadboard wires that I had lying around in place of this.
* For X10 you'll need the following
	* CM17A Firecracker (About $6 on eBay)
	* TM751 Transceiver
	* Any modules you want	
* Here you have an option
	* Connect the Arduino directly to the internet
		* 	This is the simplest option. All you'll need is an [Arduino Ethernet Shield](https://www.adafruit.com/products/201)
	* You can also send commands to the Arduion via a serial device. My setup, for example, uses Xbee with a Raspberry Pi action as the Xbee gateway. This is useful if you plan to add more Arduinos to the setup or if you want to make the system wireless. For this, you'll need the following items
		* A Raspberry Pi and USB WiFi mobule or use Ethernet
		* Two [Series 1 Xbee modules](http://www.adafruit.com/products/128)
		* A Xbee Arduino shield (any should work)
		* [Xbee board for Raspberry Pi](http://shop.ciseco.co.uk/slice-of-pi-add-on-for-raspberry-pi/)
		
		**Note:** You can also just plug the Arduino directly into a computer (including Raspberry Pi) and send serial commands that way.
		
### Alternate Setup ###
If you only want to control X10 devices, an Arduino isn't really necessary. Instead you can use a Raspberry Pi (or any computer that can run node.js) and a CM15A. I have included the necessary code for this type of setup. There are just a few things to note:

* You'll need to install [mochad](http://sourceforge.net/projects/mochad/) on the computer connected to the CM15A.
* Change the target in the app to `Simple Lights`. This is a version of the app without the RGB LED controller interface.
* Use `app-simple.js` instead of `app.js` for the server.
* You'll need to install `node-cat` on your server (`npm install node-cat`) 



## Usage ##

### Arduino ###

#### Installation ####

1. The Arduino sketch requires several third-party libraries, all of which can be found on Github. Download each one and place it in the `libraries` folder of your Arduino directory, which, in my setup, is `~/Documents/Arduino/`.
	* [WebSocketClient](https://github.com/hadleyrich/ArduinoWebsocketClient) (Only for Ethernet shield)
	* [aJSON Library](https://github.com/interactive-matter/aJson) (Only for Ethernet shield)
	* [bitlash](http://bitlash.net) (Only for serial)
	* [WS2801 Library](https://github.com/edc1591/Adafruit-WS2801-Library)
	* [CM17A Library](http://playground.arduino.cc/X10/CM17A)
		* **Note:** you may need to change `wiring.h` to `Arduino.h` in `X10Firecracker.h`
	
2. Open the Arduino sketch `Lights.ino` which is included in this repository.
3. Edit `Config.h`.
4. Edit the beginning of `Lights.ino` to specify your IP address and MAC address (Ethernet shield only)
5. Upload the sketch to your Arduino.

#### Wiring ####

For the RGB LED string, follow the tutorial [here](http://learn.adafruit.com/12mm-led-pixels/wiring).

For the X10 wiring, see [here](http://playground.arduino.cc/X10/CM17A)

### WebSocket Server ###

1. Install [node.js](http://nodejs.org)
2. Install required Node packages:
	* [ws](https://github.com/einaros/ws): 
		```npm install ws```
	* [cubby](https://github.com/icodeforlove/node-cubby): 
		```npm install cubby```
	* [cron](https://github.com/ncb000gt/node-cron): 
		```npm install cron```
	* [winston](https://github.com/flatiron/winston): 
		```npm install winston```
	* You may also want to install [forever](https://github.com/nodejitsu/forever) to keep your server running in case of a crash: 
		```npm install forever -g```
3. Upload the app.js file included in this repository to your server and start it.
	```forever start app.js```
	
### Serial Controller ###

If you're using an Ethernet shield you can ignore this section.

On the computer sending the serial commands to the Arduino (in my case, a Raspberry Pi with xbee), you'll need to run a WebSocket client to replay commands to the Arduino. A python script is included in the `Server` directory of this repository for this purpose.

One important thing to note, I have my xbee modules running at a baud rate of 38400. If you choose to use any baud rate other than 9600 with xbee, you'll have to configure the xbee modules to do so. Otherwise you can just change all instances of 38400 to 9600 in the Arduino sketch and python script.

A tutorial to changing the baud rate of your xbee module can be found [here](http://www.ladyada.net/make/xbee/configure.html). See the "Configuring with terminal" section.
	
### iOS App ###

Nothing special is required for this part. Just open the Xcode project, build, and install. The server address can be set from inside the app.

## TODO ##

* ~~Add more animations~~
* Allow editing of scheduled events
* ~~Add speed and brightness settings for animations~~
* Make Mac version
* ~~Remove the need for an ethernet shield using Xbee and a Raspberry Pi as the gateway.~~

## Acknowledgments ##

* All listed node.js packages and Arduino libraries
* [SocketRocket](https://github.com/square/SocketRocket)
* [KZColorPicker](https://github.com/alexrestrepo/KZColorPicker)