function stringServoAngleAllTime = servoAngleMatrixToString(servoAngleAllTime)
% servoAngleAllTime: number of samples * 1 * 6
% each time step should be separated by a ";"
% each motor angle should be separated by a ","

% Get the size of the matrix
    [numSamples, ~, numMotors] = size(servoAngleAllTime);
    
    % Initialize string
    stringServoAngleAllTime = '';

    % Iterate over each sample
    for i = 1:numSamples
        % Iterate over each motor angle
        for j = 1:numMotors
            % Append motor angle to string
            stringServoAngleAllTime = strcat(stringServoAngleAllTime, num2str(servoAngleAllTime(i, 1, j)));
            % Add comma if it's not the last motor angle
            if j < numMotors
                stringServoAngleAllTime = strcat(stringServoAngleAllTime, ',');
            end
        end
        % Add new line character after each sample
        stringServoAngleAllTime = strcat(stringServoAngleAllTime, ';');
    end

end

