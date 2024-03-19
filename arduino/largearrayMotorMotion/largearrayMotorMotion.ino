#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>

// Assuming you're using the Adafruit 16-Channel 12-bit PWM/Servo Driver
Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();

#define SERVOMIN  150 // This is the 'minimum' pulse length count (out of 4096)
#define SERVOMAX  600 // This is the 'maximum' pulse length count (out of 4096)
#define NUM_SERVOS 6

void setup() {
  Serial.begin(9600);
  pwm.begin();
  pwm.setPWMFreq(60); // Set frequency to 60 Hz
  while (!Serial); // Wait for serial port to connect.
  Serial.println("Ready");
}

void loop() {
  if (Serial.available()) {
    String receivedData = Serial.readStringUntil('\n'); // Read the incoming data until newline
    processAngleData(receivedData);
    Serial.println("Received and processed angles"); // Send confirmation back to MATLAB
  }
}

void processAngleData(String data) {
  // Split the received data by semicolon for each set of angles
  int startIndex = 0;
  int endIndex = 0;
  while ((endIndex = data.indexOf(';', startIndex)) > 0) {
    String angleSet = data.substring(startIndex, endIndex);
    moveMotors(angleSet);
    startIndex = endIndex + 1; // Move to the start of the next set
  }
  // Process the last set of angles (or the only set if there's no semicolon)
  moveMotors(data.substring(startIndex));
}

void moveMotors(String angleSet) {
  int angles[NUM_SERVOS];
  int angleIndex = 0;
  int startIndex = 0;
  int endIndex = 0;
  // Parse each angle from the set and move the corresponding motor
  while ((endIndex = angleSet.indexOf(',', startIndex)) > 0 && angleIndex < NUM_SERVOS) {
    angles[angleIndex] = angleSet.substring(startIndex, endIndex).toInt();
    moveServo(angleIndex, angles[angleIndex]);
    startIndex = endIndex + 1;
    angleIndex++;
  }
  // Process the last angle (or the only angle if there's no comma)
  if (angleIndex < NUM_SERVOS) {
    moveServo(angleIndex, angleSet.substring(startIndex).toInt());
  }
}

void moveServo(int servoNum, int angle) {
  // Convert angle to pulse length
  int pulseLength = map(angle, 0, 180, SERVOMIN, SERVOMAX);
  pwm.setPWM(servoNum, 0, pulseLength);
}
