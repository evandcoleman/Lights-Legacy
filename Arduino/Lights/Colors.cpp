#include "Colors.h"

Colors::Colors(int dataPin, int clockPin, int numPixels) {
  strip = Adafruit_WS2801(numPixels , dataPin, clockPin);
}

void Colors::init(void) {
  animDirection = 0;
  oldj = 0;
  brightness = 255;
  colorIndex = 0;
  maxColors = 6;
  strip.begin();
  strip.show();
}

void Colors::setPixelColor(int n, uint32_t c) {
  strip.setPixelColor(n, c);
  strip.show();
}

void Colors::setColor(int r, int g, int b) {
  for (int i=0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, Color(r, g, b));
  }
  strip.show();
}

uint32_t Colors::animColors(int i) {
  //animColors[] = {Color(brightness,0,0), Color(brightness,brightness,0), Color(0,brightness,0), 
  //Color(0,brightness,brightness), Color(0,0,brightness), Color(brightness,0,brightness)};
  uint32_t retVal;
  switch(i) {
     case 0:
       retVal = Color(brightness,0,0);
       break;
     case 1:
       retVal = Color(brightness,brightness,0);
       break;
     case 2:
       retVal = Color(0,brightness,0);
       break;
     case 3:
       retVal = Color(0,brightness,brightness);
       break;
     case 4:
       retVal = Color(0,0,brightness);
       break;
     case 5:
       retVal = Color(brightness,0,brightness);
       break;
     default:
       retVal = Color(brightness,0,0);
       break;
  }
  return retVal;
}

void Colors::rainbow(int j) {
   int i;
    for (i=0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, Wheel( (j) % brightness));
    }  
    strip.show();   // write all the pixels out
}

void Colors::rainbowCycle(int j) {
  int i;
  
  //for (j=0; j < 256 * 5; j++) {     // 5 cycles of all 25 colors in the wheel
    for (i=0; i < strip.numPixels(); i++) {
      // tricky math! we use each pixel as a fraction of the full 96-color wheel
      // (thats the i / strip.numPixels() part)
      // Then add in j which makes the colors go around per pixel
      // the % 96 is to make the wheel cycle around
      strip.setPixelColor(i, Wheel( ((i * (brightness+1) / strip.numPixels()) + j) % (brightness+1)) );
    }  
    strip.show();   // write all the pixels out
    //delay(wait);
  //}
}

void Colors::bounce(void) {
  if(animDirection == 0) {
          for(int i=0;i<strip.numPixels();i++) {
            if(i == oldj) {
              strip.setPixelColor(i, animColors(colorIndex));
            } else {
              strip.setPixelColor(i, Color(0,0,0));
            }
          }
          if(oldj == (strip.numPixels()-1)) {
            animDirection = 1;
          }
        } else if(animDirection == 1) {
          for(int i=0;i<strip.numPixels();i++) {
            if(i == oldj) {
              strip.setPixelColor(i, animColors(colorIndex));
            } else {
              strip.setPixelColor(i, Color(0,0,0));
            }
          }
          if(oldj == 0) {
            animDirection = 0;
          }
        }
        strip.show();
        
        if(animDirection == 0) {
          oldj++;
        } else {
          oldj--;
        }
}

uint32_t Colors::Color(byte r, byte g, byte b)
{
  uint32_t c;
  c = r;
  c <<= 8;
  c |= g;
  c <<= 8;
  c |= b;
  return c;
}

uint32_t Colors::Wheel(byte WheelPos)
{
  if (WheelPos < (brightness/3)) {
   return Color(WheelPos * 3, brightness - WheelPos * 3, 0);
  } else if (WheelPos < (brightness/1.5)) {
   WheelPos -= (brightness/3);
   return Color(brightness - WheelPos * 3, 0, WheelPos * 3);
  } else {
   WheelPos -= (brightness/1.5); 
   return Color(0, WheelPos * 3, brightness - WheelPos * 3);
  }
}

void Colors::handleAnimation(int isAnimating) {
        if(isAnimating == 1) {
        //Rainbow
        oldj++;
        if(oldj >= (brightness+1)) oldj = 0;
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
        strip.setPixelColor(oldj, animColors(colorIndex));
        strip.show();
        oldj++;
      } else if(isAnimating == 3) {
        //Rainbow Cycle
        oldj++;
        if(oldj >= 256*5) oldj = 0;
        rainbowCycle(oldj);
      } else if(isAnimating == 4) {
        //Bounce
        if(oldj == 0) {
          colorIndex++;
          if(colorIndex >= maxColors) {
            colorIndex = 0;
          }
        }
        
        bounce();
      }
}

void Colors::resetAnimation(void) {
  oldj = 0;
}
