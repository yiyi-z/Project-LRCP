function sendMultipleServoAnglesToArduino(servoAngleAllTime)
    % Convert the servo angle matrix to a single string
    servoAngleAllTimeString = servoAngleMatrixToString(servoAngleAllTime);
    disp(servoAngleAllTimeString)

    % Connect to Arduino
    arduinoObj = serialport("COM7", 9600); % Update COM3 to your Arduino's port

    % Send the string to Arduino
    writeline(arduinoObj, servoAngleAllTimeString);

    % Wait and read confirmation from Arduino
    confirmation = readline(arduinoObj);

    % Display the confirmation
    disp(['Confirmation from Arduino: ', confirmation]);

    % Clean up
    clear arduinoObj
end

function servoAngleAllTimeString = servoAngleMatrixToString(servoAngleAllTime)
    % This function will convert the servoAngleAllTime matrix into a string
    % format that matches the specified format for Arduino.
    % Each row of servoAngleAllTime is a set of angles for a specific time,
    % and they will be concatenated into one long string with semicolons separating
    % each set of angles.

    % Initialize an empty string
    servoAngleAllTimeString = "";

    % Loop through each set of angles in the matrix
    for i = 1:size(servoAngleAllTime, 1)
        % Convert current row of angles to a comma-separated string, trim trailing comma
        angleSetString = strjoin(arrayfun(@(x) num2str(x, '%d'), servoAngleAllTime(i, :), 'UniformOutput', false), ',');
        
        % Append this set to the main string with a semicolon (if not the first set)
        if i > 1
            servoAngleAllTimeString = servoAngleAllTimeString + ";" + angleSetString;
        else
            servoAngleAllTimeString = angleSetString;
        end
    end
end