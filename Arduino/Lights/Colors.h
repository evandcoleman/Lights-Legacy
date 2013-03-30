#include <Arduino.h>
#include <Adafruit_WS2801.h>

class Colors {
  
  public:
    Colors(int dataPin, int clockPin, int numPixels);
    
    void
      handleAnimation(int isAnimating),
      setPixelColor(int n, uint32_t c),
      setColor(int r, int g, int b),
      rainbowCycle(int j),
      bounce(void),
      rainbow(int j),
      resetAnimation(void);
    int
      brightness;
    uint32_t
      Color(byte r, byte g, byte b);
  
  private:
    uint32_t
      animColors(int i),
      Wheel(byte WheelPos);
      
    Adafruit_WS2801 strip;
      
    int
      oldj,
      animDirection,
      colorIndex,
      maxColors;
};

