# Lights: Serial API #

This document discusses how to send serial commands to the Arduino.

## Overview ##

If you're using the serial setup instead of the Ethernet setup, this document will tell you how to control the Arduino with serial commands.

## Arduino Side ##

The included Arduino sketch interprets serial commands using [bitlash](http://bitlash.net). Bitlash allows you to send actual function names (actually aliases) to the Arduino via serial. The included sketch should work without modification for any serial device. For example, I use xbee, but you could just as easily send commands via USB.

## Serial Commands ##

Below are the serial commands that the Arduino will respond to.

* `setcolor()` sets the color of the RGB LEDs. It takes three arguments in the form of an RGB color.
* `animate()` animates the RGB LEDs. It takes three arguments: the animating event as an integer, the brightness and the speed.
* `x10command()` sends a command to an X10 device. It takes three arguments: the house code as an integer (A = 1, B = 2, etc.), the device id, and the command as an integer (only accepts on, off, dim and bright).

One thing to note: I've been sending a carriage return before and after each command. This reduces the chance that commands will get clumped together if you're sending them very quickly.