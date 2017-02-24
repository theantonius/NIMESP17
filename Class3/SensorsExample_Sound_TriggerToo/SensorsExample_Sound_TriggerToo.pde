
// This example code is in the public domain.

import processing.serial.*;     // import the Processing serial library
Serial myPort;                  // The serial port

// audio files here
import ddf.minim.*;
import ddf.minim.effects.*;

Minim minim;
AudioPlayer groove1;
AudioPlayer groove2;
AudioSample snare;

float bgcolor;      // Background color
float fgcolor;      // Fill color
float xpos, ypos;          // Starting position of the ball
boolean snareOn = false; // to make sure snare only hits once

void setup() {
  size(640, 480);

  // List all the available serial ports
  // if using Processing 2.1 or later, use Serial.printArray()
  println(Serial.list());

  // I know that the first port in the serial list on my mac
  // is always my  Arduino module, so I open Serial.list()[0].
  // Change the 0 to the appropriate number of the serial port
  // that your microcontroller is attached to.
  myPort = new Serial(this, Serial.list()[3], 9600);

  // read bytes into a buffer until you get a linefeed (ASCII 10):
  myPort.bufferUntil('\n');

  // draw with smooth edges:
  smooth();

  minim = new Minim(this);

  groove1 = minim.loadFile("01.mp3");
  groove2 = minim.loadFile("02.mp3");
  groove1.loop();
  groove2.loop();
  // make them quiet
  groove1.setGain(-70);
  groove2.setGain(-70);

  // load SD.wav from the data folder
  snare = minim.loadSample("SD.wav", 512);
  if ( snare == null ) println("Didn't get snare!");
}

void draw() {
  background(bgcolor);
  fill(fgcolor);
  // Draw the shape
  ellipse(xpos, ypos, 20, 20);
}

// serialEvent  method is run automatically by the Processing applet
// whenever the buffer reaches the  byte value set in the bufferUntil()
// method in the setup():

void serialEvent(Serial myPort) {
  // read the serial buffer:
  String myString = myPort.readStringUntil('\n');
  // if you got any bytes other than the linefeed:
  myString = trim(myString);

  // split the string at the commas
  // and convert the sections into integers:
  int sensors[] = int(split(myString, ','));

  // print out the values you got:
  for (int sensorNum = 0; sensorNum < sensors.length; sensorNum++) {
    print("Sensor " + sensorNum + ": " + sensors[sensorNum] + "\t");
  }
  // add a linefeed after all the sensor values are printed:
  println();
  if (sensors.length > 1) {
    xpos = map(sensors[0], 0, 1023, 0, width);
    ypos = map(sensors[1], 0, 1023, 0, height);
    groove1.setGain(map(sensors[0], 0, 1023, -70, 0));
    groove2.setGain(map(sensors[1], 0, 1023, -70, 0));
    fgcolor = sensors[2];

    if (sensors[2]>1) {
      if (snareOn==false) {
        snare.trigger();
      }
      snareOn = true;
    } else {
      snareOn = false;
    }
  }
  // send a byte to ask for more data:
  myPort.write("A");
}