# Lights: API #

This document discusses how to interact with the iOS app. This is particularly useful if you wish to write your own Arduino code or WebSocket server.

## Overview ##

All requests from the iOS app go through the WebSocket server before being relayed to the Arduino. There are certain cases where the server will not forward events to the Arduino. This will be discussed later on.

## Data Structure ##

All communication occurs in the form of JSON data. Each JSON request consists of several parts. An example JSON request sent by the iOS app is shown below:

	{
	  "color" : [
		  0,
	      255,
	      0],
	  "event" : 1
	}
	
Breaking this down, we have two parts. There's an event element and a color element. The color object is just an array with three integers in the form of red, blue, green (RGB). In this case, the color is green. The event element is just that, the event type. Event types are integers and will be covered more in-depth in the next section.

## Event Types ##

Currently there are 7 event types. The event tells the server what to do with the request. Event types are integers. In the iOS code they are declared in a `typedef enum`.

* **Query Event**
	* **Integer:** `0`
	* **iOS app:** `LTEventTypeQuery`
	* Tells the server to ask the Arduino what the current state of the LEDs is and forwards that back to the iOS app.
	* **Other elements:** none.
* **Query Scheduled Event**
	* **Integer:** `4`
	* **iOS app:** `LTEventTypeQuerySchedule`
	* Asks the server to respond with all scheduled events. This event does not get sent to the Arduino since scheduled events are stored on the server.
	* **Other elements:** none.
* **Flush Scheduled Events**
	* **Integer:** `5`
	* **iOS app:** `LTEventTypeFlushEvents`
	* Tells the server to clear all scheduled events. This event does not get sent to the Arduino.
	* **Other elements:** none.
* **Solid Event**
	* **Integer:** `1`
	* **iOS app:** `LTEventTypeSolid`
	* Tells the Arduino to display a single color on the LEDs.
	* **Other elements:**
		* Key: `color`
		* Object: Array of three integers signifying an RGB color code (Red, Blue, Green)
* **Animation Events**
	* **Integer:** `2`, `3`, `6`, `7`
	* **iOS app:** `LTEventTypeAnimateRainbow`, `LTEventTypeAnimateColorWipe`, `LTEventTypeAnimateRainbowCycle`,`LTEventTypeAnimateBounce`
	* Tells the Arduino to animate the LEDs.
	* **Other elements:**
		* Key: `speed`
		* Object: Integer representing the interval to animate (in milliseconds)
		* Key: `brightness`
		* Object: Integer representing the brightness of the colors. Can range from 255 to 100. (Below 100 causes some weird things to happen with the animation, so let's just make that the minimum)
* **Query X10 Devices**
	* **Integer:** `8`
	* **iOS app:** `LTEventTypeGetX10Devices`
	* Returns the available X10 devices. See server app for structure.
	* **Other elements:** none.
* **Send X10 Command**
	* **Integer:** `9`
	* **iOS app:** `LTEventTypeX10Command`
	* Sends a command to an X10 device.
	* **Other elements:**
		* Key: `command`
		* Object: Integer from 0 to 3 representing the command. Commands are (respectivly from 0 to 3) `LTX10CommandOff`, `LTX10CommandOn`, `LTX10CommandDim`, `LTX10CommandBright`
		* Key: `houseCode`
		* Object: Integer of the X10 house code. 0 for A, 1 for B, etc.
		* Key: `device`
		* Object: Integer of the X10 device ID.

## Scheduling Events ##

Scheduled events are very similar to other requests. They just send along a few other crucial elements. Scheduled events come in two different flavors. Repeating and non-repeating. The following section takes the form of `element name` : description.

* `repeat` : A string of the days to repeat the event (repeating events only).
	* Example: `0,3,6` (repeats on Sunday, Wednesday and Saturday)
* `time` : The Unix epoch time to schedule the event for (in seconds).
* `state` : An integer representing the state of the event (on or off).
* `timeZone` : Time zone string where the event was scheduled.
	* Example: `America/New_York`