% This script is used to test transferring sample data from matlab to
% Arduino

%% Generate data to test

numSamples = 5;

% test for same angles
AngleToBeRepeat = randi([0, 180], numSamples, 1);
servoAngleAllTime = repmat(AngleToBeRepeat, 1, 1, 6);
% Add a row of zeros at the end
servoAngleAllTime(end+1, :) = zeros(1, 6);
disp("all angles: " + servoAngleAllTime);

%test for different angles
 %servoAngleAllTime = rand(numSamples, 1, 6) * 180.0;
% disp("all angles: " + servoAngleAllTime);

%%
% Connect to Arduino
arduinoObj = serialport("COM7", 9600); % Update COM3 to your Arduino's port

for i=1:numSamples
    servoAngles = reshape(servoAngleAllTime(i, :, :), 1, 6);
    
    disp("time step " + i + " angles: " + servoAngles);
    % Give the Arduino time to reset
    %pause(2);
    
    % Define an array of numbers
    numbers = servoAngles;
    configure = [0,0,0,0,0,0];
    % Convert the array to a string format: "12,34"
    %configureString = strjoin(string(configure), ",");
    numberString = strjoin(string(configure), ",");
    
    % Send the string to Arduino
    writeline(arduinoObj, numberString);
    
    % Wait and read confirmation from Arduino
    confirmation = readline(arduinoObj);
    
    % Display the confirmation
    disp(['Confirmation from Arduino: ', confirmation]);
end

% Clean up
clear arduinoObj