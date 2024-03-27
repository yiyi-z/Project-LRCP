#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>

#define SERVOMIN  150 // This is the 'minimum' pulse length count (out of 4096)
#define SERVOMAX  500 // This is the 'maximum' pulse length count (out of 4096)
#define NUM_SERVOS 6

// Create the servo driver object
Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();
static int firstNumber = 0; // Declare with default value
static int secondNumber = 0; // Declare with default value
static int thirdNumber = 0; // Declare with default value
static int fourthNumber = 0; // Declare with default value
static int fifthNumber = 0; // Declare with default value
static int sixthNumber = 0; // Declare with default value
// Array to keep track of the last angles for each motor
int lastAngles[6] = {0, 0, 0, 0, 0, 0};


//VOID SETUP --------------------------------------------------------------------------------------------------------------------------------------
void setup() {
  Serial.begin(9600);
  pwm.begin();
  // Set frequency of the PWM signals (default is 50Hz)
  pwm.setPWMFreq(60);  // Analog servos run at ~60 Hz updates

  // Set all servos to 0 degrees
  for (int i = 0; i < 6; i++) {
    pwm.setPWM(i, 0, angleToPulse(0));
  }
}



void updateMotorAngles(int angles[6]) {
  for(int i = 0; i < 6; i++) {
    if(angles[i] != lastAngles[i]) {
      uint16_t pulseLength = angleToPulse(angles[i]);
      pwm.setPWM(i, 0, pulseLength);
      lastAngles[i] = angles[i];
    }
  }
  delay(100);
}  // put your setup code here, to run once:

// Converts angle to pulse length
uint16_t angleToPulse(int angle) {
  return map(angle, 0, 180, SERVOMIN, SERVOMAX);
}


//VOID LOOP ----------------------------------------------------------------------------------------------------------------------------------------

void loop() {
  if (Serial.available() > 0) {
    // Read the incoming string
    String receivedData = Serial.readStringUntil('\n');
    // Use strtok to split the string into tokens
    char charArray[receivedData.length() + 1];
    receivedData.toCharArray(charArray, sizeof(charArray));
    char* ptr = strtok(charArray, ",");
    int angleArray[6];
    int index = 0;
    while (ptr != NULL) {
      if (index < 6) { // Make sure not to exceed the array bounds
        int angle = atoi(ptr);
        if (angle >= 0 && angle <=  180) {
          angleArray[index] = angle;
        } else {
          Serial.println("Error: Angles must be between 0 and 180 degrees.");
          return; // Exit if any angle is invalid
        }
        index++;
      }
      for(int i = 0; i < 5; i++)
        {
          Serial.println(angleArray[i]);
        }
      ptr = strtok(NULL, ",");
    }

    if (index == 6) { // Check if exactly 6 angles were provided
      updateMotorAngles(angleArray);
    } else {
      Serial.println("Error: Incorrect number of angles provided.");
    }
  }
}


//FUNCTIONS ---------------------------------------------------------------------------------------------------------------------------------------------------
//moving all servos together - same angle
void moveAllServos(uint16_t minAngle, uint16_t maxAngle) {
  uint16_t minPulse = map(minAngle, 0, 180, SERVOMIN, SERVOMAX);
  uint16_t maxPulse = map(maxAngle, 0, 180, SERVOMIN, SERVOMAX);

  for (uint8_t i = 0; i < NUM_SERVOS; i++) {
    pwm.setPWM(i, 0, minPulse); // Move to the minimum angle position'
    //Serial.println(minPulse);
  }
  delay(1000); // Wait for 1 second
  
  for (uint8_t i = 0; i < NUM_SERVOS; i++) {
    pwm.setPWM(i, 0, maxPulse); // Move to the maximum angle position
    //Serial.println(maxPulse);
  }
  delay(1000); // Wait for 1 second

}
//moving individual servos once
void moveindivServosSep(uint8_t servoNum, uint16_t minAngle, uint16_t maxAngle) {
  uint16_t minPulse = map(minAngle, 0, 180, SERVOMIN, SERVOMAX);
  uint16_t maxPulse = map(maxAngle, 0, 180, SERVOMIN, SERVOMAX);
  pwm.setPWM(servoNum, 0, minPulse); // Move to the minimum angle position'
  Serial.println(minPulse);               
  delay(1000); // Wait for 1 second
  pwm.setPWM(servoNum, 0, maxPulse); // Move to the maximum angle position
  Serial.println(maxPulse);
  delay(1000); // Wait for 1 second
}

//
void moveServoInRange(uint8_t servoNum, uint16_t minAngle, uint16_t maxAngle) {
  uint16_t minPulse = map(minAngle, 0, 180, SERVOMIN, SERVOMAX);
  uint16_t maxPulse = map(maxAngle, 0, 180, SERVOMIN, SERVOMAX);

  for (int angle = minAngle; angle <= maxAngle; angle++) {
    uint16_t pulse = map(angle, 0, 180, SERVOMIN, SERVOMAX);
    pwm.setPWM(servoNum, 0, pulse);
    Serial.println(pulse);
    //delay(10); // Adjust the delay as needed for the desired servo speed
  }
  delay(1000);
  for (int angle = maxAngle; angle >= minAngle; angle--) {
    uint16_t pulse = map(angle, 0, 180, SERVOMIN, SERVOMAX);
    pwm.setPWM(servoNum, 0, pulse);
    Serial.println(pulse);
    //delay(10); // Adjust the delay as needed for the desired servo speed
  }
  delay(1000);
}



void moveServos(uint16_t targetAngles[6]) {
  for (uint8_t servoNum = 0; servoNum < 6; servoNum++) {
    uint16_t targetPulse = map(targetAngles[servoNum], 0, 180, SERVOMIN, SERVOMAX);
    
    pwm.setPWM(servoNum, 0, targetPulse); // Move to the target angle position
    //Serial.print("Servo ");
    //Serial.print(servoNum);
   // Serial.print(": ");
    //Serial.println(targetPulse);
    
    delay(1000); // Wait for 1 second to visually see the servo move
  }
}

void moveServosloop(uint16_t targetAngles[6]) {
  uint16_t startAngle = 0; // Assuming the start angle is 0 degrees
  uint16_t steps = 10; // Number of steps for the transition. Increase for smoother movements.
  
  for (uint8_t servoNum = 0; servoNum < 6; servoNum++) {
    uint16_t startPulse = map(startAngle, 0, 180, SERVOMIN, SERVOMAX);
    uint16_t targetPulse = map(targetAngles[servoNum], 0, 180, SERVOMIN, SERVOMAX);
    
    // Move from startPulse to targetPulse in incremental steps
    for (uint16_t step = 1; step <= steps; step++) {
      uint16_t currentPulse = startPulse + (targetPulse - startPulse) * step / steps;
      pwm.setPWM(servoNum, 0, currentPulse);
      delay(20); // Short delay to allow the servo to move. Adjust as necessary for smoothness vs speed.
    }
    
    // Uncomment below to see debug output of servo movements
    //Serial.print("Servo ");
    //Serial.print(servoNum);
    //Serial.print(": ");
    //Serial.println(targetPulse);
  }
}

void initializeEvenMotors(uint16_t minAngle, uint16_t maxAngle) {
  uint16_t maxPulse = map(maxAngle, 0, 180, SERVOMIN, SERVOMAX);

  // Loop through the servos and initialize even-numbered ones
  for (uint8_t i = 0; i < NUM_SERVOS; i++) {
    if (i % 2 == 0) { // Check if the servo number is even
      pwm.setPWM(i, 0, maxPulse); // Set even motors to move anticlockwise to maxAngle
    }
    // Odd-numbered servos are not handled here
  }
  // Optionally, include a delay here if you want to ensure that all motors reach their position
  // before proceeding with the rest of your program, e.g., delay(1000);
}

void moveAllServosnew(uint16_t minAngle, uint16_t maxAngle) {
  uint16_t minPulse = map(minAngle, 0, 180, SERVOMIN, SERVOMAX);
  uint16_t maxPulse = map(maxAngle, 0, 180, SERVOMIN, SERVOMAX);
  // Simultaneously set even servos to move from maxAngle to minAngle and odd servos from minAngle to maxAngle
  for (uint8_t i = 0; i < NUM_SERVOS; i++) {
    if (i % 2 == 0) { // Even-numbered servos
      // Set even servos to start at maxPulse (equivalent to maxAngle)
      pwm.setPWM(i, 0, maxPulse);
    } else { // Odd-numbered servos
      // Set odd servos to start at minPulse (equivalent to minAngle)
      pwm.setPWM(i, 0, minPulse);
    }
  }
  delay(1000); // Wait for 1 second to allow servos to reach the start position

  for (uint8_t i = 0; i < NUM_SERVOS; i++) {
    if (i % 2 == 0) { // Even-numbered servos
      // Move even servos to minPulse (equivalent to minAngle), completing their anticlockwise movement
      pwm.setPWM(i, 0, minPulse);
    } else { // Odd-numbered servos
      // Move odd servos to maxPulse (equivalent to maxAngle), completing their clockwise movement
      pwm.setPWM(i, 0, maxPulse);
    }
  }
  delay(1000); // Wait for 1 second to allow servos to reach the final position
}




