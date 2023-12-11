#include <Servo.h>
#include <LiquidCrystal.h>
#include <NewPing.h>

#define TRIG_PIN 12
#define ECHO_PIN 13
#define MAX_DISTANCE 60  // cm

#define SERVO_PIN 8
#define SERVO_DELAY 30


// Creating objects, servo, lcd and sonar
Servo myservo;
LiquidCrystal lcd(7, 6, 5, 4, 3, 2); // Creates an LCD object. Parameters: (rs, enable, d4, d5, d6, d7)
NewPing sonar(TRIG_PIN, ECHO_PIN, MAX_DISTANCE);


void setup()
{
  myservo.attach(SERVO_PIN);
  Serial.begin(115200);

  lcd.begin(16,2); 
  
  // Print a message to the LCD.
  lcd.print("Ultrasonic Radar");
  lcd.setCursor(0, 1);
  lcd.print("Jimbow007 ");
  
  myservo.write(90); //  initPosition to 90 degrees
  delay(5000);
}

void loop()
{
 int iAngle;
 for (iAngle=15; iAngle<=165; iAngle++)
 {
  scanAngle(iAngle);
 }
 for(iAngle=164; iAngle>=16; iAngle--)
 {
  scanAngle(iAngle);
 }
}

void scanAngle(int iAngle) {
  int iDistance;
  
 // Position servo to desired angle
  myservo.write(iAngle);
  delay(SERVO_DELAY);

  // look for object echo
  iDistance = sonar.ping_cm();

  // Write data to LCD
  writeDataToLCD(iAngle, iDistance);

  // write data to serial port 
  writeDataToSerialPort(iAngle, iDistance);
}


void writeDataToLCD(int iAngle, int iDistance) {
  lcd.setCursor(0,0); // set LCD cursor position to first column first line
  lcd.print("Distance: "); 
  if (iDistance!=NO_ECHO){ // If find object print distance
    lcd.print(iDistance); 
    lcd.print(" cm ");
  } 
  else {
     lcd.print("       "); 
  }

  lcd.setCursor(0,1); // set LCD cursor position to first column second line
  lcd.print("Angle : "); 
  lcd.print(iAngle);
  lcd.print(" deg ");
}

void writeDataToSerialPort(int iAngle, int iDistance){
  if (iDistance==NO_ECHO){ // Object not found in MAX_DISTANCE range
     iDistance=MAX_DISTANCE+1;
  }
  Serial.print(iAngle);
  Serial.print(",");
  Serial.print(iDistance);
  Serial.print(".");
}
