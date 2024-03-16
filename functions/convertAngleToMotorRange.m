function servoAngleAllTimeDegree = convertAngleToMotorRange(servoAngleAllTimeRad)
% Convert Angles in radians [-pi/2, pi/2] to degree [0, 180]
    servoAngleAllTimeDegree = rad2deg(servoAngleAllTimeRad) + 90;
end

