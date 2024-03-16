% This script is used to test transferring sample data from matlab to
% Arduino

numSamples = 5;
servoAngleAllTime = rand(numSamples, 1, 6) * 180.0;
disp(servoAngleAllTime)

for i=1:numSamples
    servoAngles = reshape(servoAngleAllTime(i, :, :), 1, 6);
    servoAngle1 = servoAngles(1, 1);
    servoAngle2 = servoAngles(1, 2);
    servoAngle3 = servoAngles(1, 3);
    servoAngle4 = servoAngles(1, 4);
    servoAngle5 = servoAngles(1, 5);
    servoAngle6 = servoAngles(1, 6);

end