addpath("../functions")

disp("should be 180: " + convertAngleToMotorRange(pi/2));
disp("should be 0: " + convertAngleToMotorRange(-pi/2));
disp("should be 90: " + convertAngleToMotorRange(0));
disp("should be 45: " + convertAngleToMotorRange(-pi/4));
disp("should be 135: " + convertAngleToMotorRange(pi/4));