#include "Config.h"
//#include <avr/wdt.h>
#include <X10Firecracker.h>
#include <Adafruit_WS2801.h>
#include "Colors.h"

#if USE_SERIAL == 1
  #include <SoftwareSerial.h>
  #include "bitlash.h"
  
  SoftwareSerial xbee(RX_PIN, TX_PIN); // RX, TX
  
#else
  #include <SPI.h>
  #include <Ethernet.h>
  #include <WebSocketClient.h>
  #include <aJSON.h>
  
  byte mac[] = { 0x90, 0xA2, 0xDA, 0x0D, 0x9C, 0xEA };
  byte ip[] = { 192, 168, 0, 108 }; 
 
  char server[] = "server.com";
  char path[] = "/";
  int port = 9000;
  WebSocketClient client; 
  
  void dataArrived(WebSocketClient client, String data);
  void connectToServer();
#endif

String splitString(String s, char parser,int index);
HouseCode houseCodeForChar(int code);
CommandCode commandForInt(int command);

Colors colors = Colors(RGB_DATA_PIN, RGB_CLOCK_PIN, NUM_PIXELS);

long previousMillis = 0;

int isAnimating = 0;
unsigned long interval = 50;

String currentState = "";
int solidEvent = 1;
int queryEvent = 0;
int rainbowEvent = 2;
int colorWipeEvent = 3;
int rainbowCycleEvent = 6;
int bounceEvent = 7;
int x10Event = 9;

void setup() {
  //Serial.println("Running...");
  #if USE_SERIAL == 1
    initBitlash(38400);
    //Serial.begin(38400);
    
    addBitlashFunction("setcolor", (bitlash_function) func_setcolor);
    addBitlashFunction("x10command", (bitlash_function) func_x10command);
    addBitlashFunction("animate", (bitlash_function) func_animate);

    xbee.begin(38400);
  #endif
  //wdt_enable(WDTO_4S);
  colors.init();
  X10.init( X10_RTS, X10_DTR, 1 );
}

void loop() {
  //wdt_reset();
  #if USE_SERIAL == 1
    runBitlash();
    //getSerialData();
    while(xbee.available() > 0) {
       doCharacter(xbee.read());
    }
  #else
    if(!client.connected()) {
      colors.setColor(0, 0, 0);
      colors.setPixelColor(0, colors.Color(255, 0, 0));
      connectToServer();
    }
    client.monitor();
  #endif
  
  unsigned long currentMillis = millis();
  
  #if USE_SERIAL == 0 
  if(currentMillis - previousMillis > 300000) { 
    previousMillis = currentMillis; 
    client.send("ping");
  }
  #endif
    
  if(isAnimating != 0) {
    
    if(currentMillis - previousMillis > interval) { 
      previousMillis = currentMillis; 
      colors.handleAnimation(isAnimating);
    }
  }
}

#if USE_SERIAL == 0

void handleData(String data) {
    if(data.startsWith("currentState")) {
    return;
  }
  
  //Serial.println("Data Arrived: " + data);
  char *c = data.buffer;
  if(data.length() == 0) {
    colors.setColor(0, 0, 0);
  }
  
  aJsonObject *root = aJson.parse(c);
  Serial.println(aJson.print(root));
  aJsonObject *event = aJson.getObjectItem(root, "event");
  //Serial.println(event->valuestring);
  colors.resetAnimation();
  if(event->valueint == solidEvent) {
    Serial.println("Received Solid Event");
    isAnimating = 0;
    currentState = data;
    aJsonObject *colorArr = aJson.getObjectItem(root, "color");
    int r = aJson.getArrayItem(colorArr, 0)->valueint;
    int g = aJson.getArrayItem(colorArr, 1)->valueint;
    int b = aJson.getArrayItem(colorArr, 2)->valueint;
    colors.setColor(r, g, b);
  } else if(event->valueint == queryEvent) {
    Serial.println("Received Query Event");
    #if USE_SERIAL == 1
    //xbee.print("currentState: " + currentState);
    #else
    client.send("currentState: " + currentState);
    #endif
  } else if(event->valueint == x10Event) {
    int device = aJson.getObjectItem(root, "device")->valueint;
    int house = aJson.getObjectItem(root, "houseCode")->valueint;
    int command = aJson.getObjectItem(root, "command")->valueint;
    //Serial.println(commandForInt(command));
    X10.sendCmd(houseCodeForChar(house), device, commandForInt(command));
  } else if(event->valueint == rainbowEvent) {
    currentState = data;
    interval = aJson.getObjectItem(root, "speed")->valueint;
    colors.brightness = aJson.getObjectItem(root, "brightness")->valueint;
    isAnimating = 1;
  } else if(event->valueint == colorWipeEvent) {
    currentState = data;
    interval = aJson.getObjectItem(root, "speed")->valueint;
    colors.brightness = aJson.getObjectItem(root, "brightness")->valueint;
    isAnimating = 2;
    colors.setColor(0,0,0);
  } else if(event->valueint == rainbowCycleEvent) {
    currentState = data;
    interval = aJson.getObjectItem(root, "speed")->valueint;
    colors.brightness = aJson.getObjectItem(root, "brightness")->valueint;
    isAnimating = 3;
  } else if(event->valueint == bounceEvent) {
    currentState = data;
    interval = aJson.getObjectItem(root, "speed")->valueint;
    colors.brightness = aJson.getObjectItem(root, "brightness")->valueint;
    isAnimating = 4;
  }
  
  aJson.deleteItem(root);
  
}

void connectToServer() {
  Serial.println("Connecting...");
  
  Ethernet.begin(mac, ip);
  if(client.connect(server,path,port)) {
    Serial.println("Connected"); 
    colors.setColor(0, 0, 0);
    client.setDataArrivedDelegate(dataArrived);
    //dataArrived(client, currentState);
  } else {
    Serial.println("Connection Failed");
    colors.setPixelColor(0, colors.Color(255, 0, 0));
  }
}

void dataArrived(WebSocketClient client, String data) {
  handleData(data);
}

#else

numvar func_setcolor(void) {
  isAnimating = 0;
  int red = getarg(1);
  int green = getarg(2);
  int blue = getarg(3);
  colors.setColor(red, green, blue);
}

numvar func_x10command(void) {
  int device = getarg(1);
  int houseCode = getarg(2);
  int command = getarg(3);
  X10.sendCmd(houseCodeForChar(houseCode), device, commandForInt(command));
}

numvar func_animate(void) {
  int event = getarg(1);
  colors.brightness = getarg(2);
  interval = getarg(3);
  if(event == rainbowEvent) {
    isAnimating = 1;
  } else if(event == colorWipeEvent) {
    isAnimating = 2;
    colors.setColor(0,0,0);
  } else if(event == rainbowCycleEvent) {
    isAnimating = 3;
  } else if(event == bounceEvent) {
    isAnimating = 4;
  }
}

#endif

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

HouseCode houseCodeForChar(int code) {
  HouseCode ret;
  switch(code) {
    case 1:
        ret = hcA;
        break;
    case 2:
        ret = hcB;
        break;
    case 3:
        ret = hcC;
        break;
    case 4:
        ret = hcD;
        break;
    case 5:
        ret = hcE;
        break;
    case 6:
        ret = hcF;
        break;
    case 7:
        ret = hcG;
        break;
    case 8:
        ret = hcH;
        break;
    case 9:
        ret = hcI;
        break;
    case 10:
        ret = hcJ;
        break;
    case 11:
        ret = hcK;
        break;
    case 12:
        ret = hcL;
        break;
    case 13:
        ret = hcM;
        break;
    case 14:
        ret = hcN;
        break;
    case 15:
        ret = hcO;
        break;
    case 16:
        ret = hcP;
        break;
    default:
        ret = hcA;
        break;
  }
  return ret;
}

CommandCode commandForInt(int command) {
  CommandCode ret = cmdOff;
  switch(command) {
    case 0:
      ret = cmdOff;
      break;
    case 1:
      ret = cmdOn;
      break;
    case 2:
      ret = cmdDim;
      break;
    case 3:
      ret = cmdBright;
      break;
    default:
      ret = cmdOff;
      break;
  }
  return ret;
}
