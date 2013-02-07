#include <SPI.h>
#include <Ethernet.h>
#include <WebSocketClient.h>
#include "Adafruit_WS2801.h"
#include <aJSON.h>
#include <avr/wdt.h>

byte mac[] = { 0x90, 0xA2, 0xDA, 0x0D, 0x9C, 0xEA };
byte ip[] = { 192, 168, 0, 108 };  

int dataPin  = 2;    // Yellow wire on Adafruit Pixels
int clockPin = 3;    // Green wire on Adafruit Pixels
Adafruit_WS2801 strip = Adafruit_WS2801(25 /* number of LEDs */, dataPin, clockPin);

long previousMillis = 0;
int oldj = 0;
int isAnimating = 0;

char server[] = "evancoleman.net";
char path[] = "/";
int port = 9000;
WebSocketClient client;

String currentState = "";
int solidEvent = 1;
int queryEvent = 0;
int rainbowEvent = 2;
int colorWipeEvent = 3;
int rainbowCycleEvent = 6;
uint32_t animColors[] = {Color(255,0,0), Color(255,255,0), Color(0,255,0), Color(0,255,255), Color(0,0,255), Color(255,0,255)};
int colorIndex = 0;
int maxColors = 6;

void setup() {
  Serial.begin(9600);
  wdt_enable(WDTO_4S);
  strip.begin();
  strip.show();
}

void loop() {
  wdt_reset();
  if(!client.connected()) {
    setColor(0, 0, 0);
    strip.setPixelColor(0, Color(255, 0, 0));
    strip.show();
    connectToServer();
  }
  client.monitor();
  
  if(isAnimating != 0) {
    int interval = 0;
    if(isAnimating == 1) {
     interval = 20;
    } else if(isAnimating == 2) {
     interval = 50; 
    } else if(isAnimating == 6) {
     interval = 50; 
    }
    unsigned long currentMillis = millis();
    
    if(currentMillis - previousMillis > interval) { 
      previousMillis = currentMillis; 
      if(isAnimating == 1) {
        //Rainbow
        oldj++;
        if(oldj >= 256) oldj = 0;
        rainbow(oldj);
      } else if(isAnimating == 2) {
        //Color Wipe
        if(oldj >= strip.numPixels()) {
          oldj = 0;
          colorIndex++;
          if(colorIndex >= maxColors) {
            colorIndex = 0;
          }
        }
        strip.setPixelColor(oldj, animColors[colorIndex]);
        strip.show();
        oldj++;
      } else if(isAnimating == 3) {
        //Rainbow Cycle
        oldj++;
        if(oldj >= 256*5) oldj = 0;
        rainbowCycle(oldj);
      }
    }
  }
}

void connectToServer() {
  Serial.println("Connecting...");
  
  Ethernet.begin(mac,ip);
  if(client.connect(server,path,port)) {
    Serial.println("Connected"); 
    client.setDataArrivedDelegate(dataArrived);
    dataArrived(client, currentState);
  } else {
    Serial.println("Connection Failed");
    strip.setPixelColor(0, Color(255, 0, 0));
    strip.show();
  }
}

void dataArrived(WebSocketClient client, String data) {
  //Serial.println("Data Arrived: " + data);
  char *c = data.buffer;
  if(data.length() == 0) {
    setColor(0, 0, 0);
  }
  aJsonObject *root = aJson.parse(c);
  aJsonObject *event = aJson.getObjectItem(root, "event");
  //Serial.println(event->valuestring);
  oldj = 0;
  if(event->valueint == solidEvent) {
    Serial.println("Received Solid Event");
    isAnimating = 0;
    currentState = data;
    aJsonObject *colors = aJson.getObjectItem(root, "color");
    int r = aJson.getArrayItem(colors, 0)->valueint;
    int g = aJson.getArrayItem(colors, 1)->valueint;
    int b = aJson.getArrayItem(colors, 2)->valueint;
    setColor(r, g, b);
  } else if(event->valueint == queryEvent) {
    Serial.println("Received Query Event");
    client.send("currentState: " + currentState);
  } else if(event->valueint == rainbowEvent) {
    currentState = data;
    aJsonObject *option = aJson.getObjectItem(root, "option");
    isAnimating = 1;
  } else if(event->valueint == colorWipeEvent) {
    currentState = data;
    aJsonObject *option = aJson.getObjectItem(root, "option");
    isAnimating = 2;
    setColor(0,0,0);
  } else if(event->valueint == rainbowCycleEvent) {
    currentState = data;
    aJsonObject *option = aJson.getObjectItem(root, "option");
    isAnimating = 3;
  }
  aJson.deleteItem(root);
}

void setColor(int r, int g, int b) {
  for (int i=0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, Color(r, g, b));
  }
  strip.show();
}

void rainbow(int j) {
   int i;
    for (i=0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, Wheel( (i + j) % 255));
    }  
    strip.show();   // write all the pixels out
}

void rainbowCycle(int j) {
  int i;
  
  //for (j=0; j < 256 * 5; j++) {     // 5 cycles of all 25 colors in the wheel
    for (i=0; i < strip.numPixels(); i++) {
      // tricky math! we use each pixel as a fraction of the full 96-color wheel
      // (thats the i / strip.numPixels() part)
      // Then add in j which makes the colors go around per pixel
      // the % 96 is to make the wheel cycle around
      strip.setPixelColor(i, Wheel( ((i * 256 / strip.numPixels()) + j) % 256) );
    }  
    strip.show();   // write all the pixels out
    //delay(wait);
  //}
}

uint32_t Color(byte r, byte g, byte b)
{
  uint32_t c;
  c = r;
  c <<= 8;
  c |= g;
  c <<= 8;
  c |= b;
  return c;
}

uint32_t Wheel(byte WheelPos)
{
  if (WheelPos < 85) {
   return Color(WheelPos * 3, 255 - WheelPos * 3, 0);
  } else if (WheelPos < 170) {
   WheelPos -= 85;
   return Color(255 - WheelPos * 3, 0, WheelPos * 3);
  } else {
   WheelPos -= 170; 
   return Color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
}

String splitString(String s, char parser,int index){
  String rs='\0';
  int parserIndex = index;
  int parserCnt=0;
  int rFromIndex=0, rToIndex=-1;

  while(index>=parserCnt){
    rFromIndex = rToIndex+1;
    rToIndex = s.indexOf(parser,rFromIndex);

    if(index == parserCnt){
      if(rToIndex == 0 || rToIndex == -1){
        return '\0';
      }
      return s.substring(rFromIndex,rToIndex);
    }
    else{
      parserCnt++;
    }

  }
  return rs;
}
