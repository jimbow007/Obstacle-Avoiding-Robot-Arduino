import processing.serial.*; // imports library for serial communication
import java.awt.event.KeyEvent; // imports library for reading the data from the serial port
import java.awt.Toolkit; // imports library for reading the data from the serial port
import java.awt.Dimension; // imports library for reading the data from the serial port
import java.io.IOException;
Serial myPort; // defines Object Serial

// Adjust following constants to your needs
final int MAX_DISTANCE = 60;         // cm
final int RANGE_DIV = 6;             // Range divisions
final int ANGLE_MARK_SEP = 30;       // Angle mark separations in radar display
final int ANGLE_MARK_TEXT_SEP = 5;   // Angle mark text sep. in radar display
final String PROJECT_NAME = "My name / Project Name" ; // My name, my Project Name, etc
final String SERIAL_PORT = "COM7";  // Serial communication port
final int BAUD_RATE = 115200;       // Serial communication Baud rate

// defubes variables
String angle="";
String distance="";
String data="";
float pixsDistance;
int iAngle, iDistance;
int index1=0;

void setup() {
    //surface.setResizable(true);
  Dimension size = Toolkit.getDefaultToolkit().getScreenSize(); 
  
  // width will store the width of the screen 
  int width = (int)size.getWidth(); 
  
  // height will store the height of the screen 
  int height = (int)size.getHeight(); 
        
  // Auto screen resolution
  surface.setSize(width,height-20);
  
  smooth();
  myPort = new Serial(this, "SERIAL_PORT", BAUD_RATE); // starts the serial communication
  myPort.bufferUntil('.'); // reads the data from the serial port up to the character '.'. So actually it reads this: angle,distance.
}

void draw() {

  fill(98, 245, 31);
  // simulating motion blur and slow fade of the moving line
  noStroke();
  fill(0, 4); 
  rect(0, 0, width, height-height*0.065); 

  fill(98, 245, 31); // green color
  // calls the functions for drawing the radar
  drawRadar(); 
  drawLine();
  drawObject();
  drawText();
}

void serialEvent (Serial myPort) { // starts reading data from the Serial Port
  // reads the data from the Serial Port up to the character '.' and puts it into the String variable "data".
  data = myPort.readStringUntil('.');
  data = data.substring(0, data.length()-1);

  index1 = data.indexOf(","); // find the character ',' and puts it into the variable "index1"
  angle= data.substring(0, index1); // read the data from position "0" to position of the variable index1 or thats the value of the angle the Arduino Board sent into the Serial Port
  distance= data.substring(index1+1, data.length()); // read the data from position "index1" to the end of the data pr thats the value of the distance

  // converts the String variables into Integer
  iAngle = int(angle);
  iDistance = int(distance);
}

void drawRadar() {
  pushMatrix();
  translate(width/2, height-height*0.074); // moves the starting coordinats to new location
  noFill();
  strokeWeight(2);
  stroke(98, 245, 31);
  
  // draws the arc lines
  float iSep = (1 -.0625) / RANGE_DIV;
  for (int i = 0; i < RANGE_DIV; i++) {
    arc(0, 0, (width-width*(iSep*i+0.0625)), (width-width*(iSep*i+0.0625)), PI, TWO_PI);
  }

  // Draw base line
  line(-width/2, 0, width/2, 0);
  
  int i = 0;
  // draws the angle lines at ANGLE_MARK_SEP deggres separation
  while (++i * ANGLE_MARK_SEP < 180) {
      line(0, 0, (-width/2)*cos(radians(ANGLE_MARK_SEP * i)), (-width/2)*sin(radians(ANGLE_MARK_SEP * i)));
  } 
  popMatrix();
}

void drawObject() {
  pushMatrix();
  translate(width/2, height-height*0.074); // moves the starting coordinats to new location
  strokeWeight(9);
  stroke(255, 10, 10); // red color
  pixsDistance = iDistance*((height-height*0.1666)/MAX_DISTANCE); // covers the distance from the sensor from cm to pixels
  // limiting the range to MAX_DISTANCE cms
  if (iDistance<MAX_DISTANCE) {
    // draws the object according to the angle and the distance
    line(pixsDistance*cos(radians(iAngle)), -pixsDistance*sin(radians(iAngle)), (width-width*0.514)*cos(radians(iAngle)), -(width-width*0.514)*sin(radians(iAngle)));
  }
  popMatrix();
}

void drawLine() {
  pushMatrix();
  strokeWeight(9);
  stroke(30, 250, 60);
  translate(width/2, height-height*0.074); // moves the starting coordinats to new location
  line(0, 0, (height-height*0.12)*cos(radians(iAngle)), -(height-height*0.12)*sin(radians(iAngle))); // draws the line according to the angle
  popMatrix();
}

void drawText() { // draws the texts on the screen
  pushMatrix();
  
  fill(0, 0, 0);
  noStroke();
  rect(0, height-height*0.0648, width, height);
  fill(98, 245, 31);
  textSize(25);

  float iSep = (.5 -.0625) / RANGE_DIV;
  for (int i = 0; i < RANGE_DIV; i++) {
    text((MAX_DISTANCE - MAX_DISTANCE/ RANGE_DIV * i)+"cm", (width-width*(iSep*i+0.0625)), height-height*0.0833);
  }
  
  textSize(40);
  text(PROJECT_NAME, width-width*0.875, height-height*0.0277);
  text("Angle: " + iAngle +" ", width-width*0.48, height-height*0.0277);
  if (iDistance<MAX_DISTANCE) {
    text("Distance: " + iDistance +" cm", width-width*0.26, height-height*0.0277);
  } else {
    text("Distance: ", width-width*0.26, height-height*0.0277);
  }
  textSize(25);
  fill(98, 245, 60);
  
  // draws the angle lines text at  ANGLE_MARK_SEP deggres separation
  textAlign(CENTER);
  int i = 0;
  while (++i * ANGLE_MARK_SEP < 180){
    resetMatrix();  
    translate(width/2, height-height*0.074); // moves the starting coordinats to new location
    translate((-width/2 - ANGLE_MARK_TEXT_SEP)*cos(radians(ANGLE_MARK_SEP * i)), (-width/2 - ANGLE_MARK_TEXT_SEP)*sin(radians(ANGLE_MARK_SEP * i)));
    rotate(-radians(90 - ANGLE_MARK_SEP * i));
  
    text(ANGLE_MARK_SEP * i, 0, 0);   
  } 
  textAlign(LEFT);
  popMatrix();
}
