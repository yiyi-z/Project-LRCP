#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>

Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();
#define SERVOMIN  150 // This is the 'minimum' pulse length count (out of 4096)
#define SERVOMAX  600 // This is the 'maximum' pulse length count (out of 4096)

// Adjust these values for your servos
float angles[6]; // Current angles for each motor
int servoNums[6] = {0, 1, 2, 3, 4, 5}; // Servo numbers on the PWM driver

void setup() {
  Serial.begin(9600);
  pwm.begin();
  
  pwm.setPWMFreq(60);  // Analog servos run at ~60 Hz updates
  delay(10);
}

void parseAndMoveServos(String command) {
  // Replace MATLAB format brackets with Arduino compatible ones
  command.replace('[', ' ');
  command.replace(']', ' ');
  command.trim();

  int prevIdx = 0;
  int nextIdx;
  String angleSet;

  while ((nextIdx = command.indexOf(';', prevIdx)) != -1) {
    angleSet = command.substring(prevIdx, nextIdx);
    moveServos(angleSet);
    prevIdx = nextIdx + 1;
  }
  // For the last set of angles
  angleSet = command.substring(prevIdx);
  if (angleSet.length() > 0) {
    moveServos(angleSet);
  }
}

void moveServos(String anglesStr) {
  anglesStr.replace(";", "");
  int angles[6];
  int startIdx = 0;
  int endIdx = 0;
  int i = 0;

  // Parse angles for each motor
  while ((endIdx = anglesStr.indexOf(',', startIdx)) != -1 && i < 6) {
    angles[i++] = anglesStr.substring(startIdx, endIdx).toInt();
    startIdx = endIdx + 1;
  }
  angles[i] = anglesStr.substring(startIdx).toInt(); // Last angle

  // Move each servo
  for (int i = 0; i < 6; i++) {
    setServoPulse(servoNums[i], angles[i]);
  }
}

void setServoPulse(uint8_t n, float angle) {
  float pulseLength = map(angle, 0, 180, SERVOMIN, SERVOMAX); // Map angle to pulse length
  pwm.setPWM(n, 0, pulseLength);
}


void loop() {
  if (Serial.available() > 0) {
    String command = Serial.readStringUntil('\n'); // Read the command from MATLAB
    parseAndMoveServos(command); // Parse and move servos according to the command
  }
}
