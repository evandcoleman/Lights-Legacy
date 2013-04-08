#!/usr/bin/env python

import serial
import websocket
import thread
import time
import sys
import json
import threading

PORT = '/dev/ttyAMA0'
BAUD = 38400

ser = serial.Serial(PORT, BAUD)

currentState = ''

def heartbeat(ws):
  ws.send('{ }')
  t = threading.Timer(300.0, heartbeat, [ws])
  t.daemon = True
  t.start()

def on_close(ws):
    ser.close()

def on_message(ws, message):
	global currentState
	j = json.loads(message)
	event = j['event']
	ser.write(chr(13))
	if event == 0:
		ws.send(currentState)
	elif event == 1:
		currentState = "currentState: " + message
		ser.write('setcolor('+str(j['color'][0])+','+str(j['color'][1])+','+str(j['color'][2])+')')
	elif event == 2 or event == 3 or event == 6 or event == 7:
		currentState = "currentState: " + message
		ser.write('animate('+str(event)+','+str(j['brightness'])+','+str(j['speed'])+')')
	elif event == 9:
		ser.write('x10command('+str(j['device'])+','+str(j['houseCode'])+','+str(j['command'])+')')
	ser.write(chr(13))
	time.sleep(0.02)

def on_error(ws, error):
    print(error)
    
def on_open(ws):
    print("Opened...")
    
if __name__ == "__main__":
    websocket.enableTrace(True)
    if len(sys.argv) < 2:
        host = "ws://server.com:9000"
    else:
        host = sys.argv[1]
    ws = websocket.WebSocketApp(host,
                                on_message = on_message,
                                on_error = on_error,
                                on_close = on_close)
    ws.on_open = on_open
    t = threading.Timer(300.0, heartbeat, [ws])
    t.daemon = True
    t.start()
    ws.run_forever()