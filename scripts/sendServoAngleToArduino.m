% This script is used to test transferring sample data from matlab to
% Arduino

addpath("../functions")

%% test data with compatible with stewart platform model
% refer to function computeServoAngleArray for more details
bArray = [90.53, 49.00, -46.66, -89.04, -41.28, 42.62; ...
         0, 74.28, 74.28, 0, -81.72, -81.72; ...
         0, 0, 0, 0, 0, 0]; % 3 * 6
pArrayPlatform = 0.6 * bArray; % 3 * 6
s = 100;
a = 25;
betaArray = deg2rad([120 + 180, 120 + 180, 240 + 180, 240 + 180, ...
    360 + 180, 360 + 180]); % 1 * 6, add 180 since motors face inwards
baseToTop = [0; 0; 90]; % from center of base coordinate to top platform coordinate (at home position)
topToTarget = [100; -50; 30]; % 3 * 1, from centor of the top platform to center of the target (at home position) in home top platform coordinate

amplitude = 20;
frequency = 1;          
timeShift = 0;
amplitudeShift = 0;
duration = 2; 
samplingRate = 3;
numSamples = round(duration * samplingRate);

ZERO_THRESHOLD = 1e-6; 

sineData = generateSineData(amplitude, frequency, timeShift, ...
    amplitudeShift, duration, samplingRate);

t = [sineData, zeros(numSamples, 1) , zeros(numSamples, 1) ];  % numSample * 3
rotations = [zeros(numSamples, 1), zeros(numSamples, 1), ...
    zeros(numSamples, 1)];

t(abs(t) < ZERO_THRESHOLD) = 0;
rotations(abs(rotations) < ZERO_THRESHOLD) = 0;

transformed_t = zeros(size(t));
transformed_rotations = zeros(size(rotations));
for i = 1:size(t, 1)
    % Extract translation and rotation vectors
    ti = t(i, :)';
    rotationi = rotations(i, :)';

    % first translate to center of top platform in home top platform
    % coordinate
    [transformed_ti, transformed_rotationi] = targetToTopPlatform(ti, rotationi, topToTarget);
    % then translate to center of top platform in base coordinate
    transformed_ti = transformed_ti + baseToTop;

    % Store transformed vectors in matrices
    transformed_t(i, :) = transformed_ti';
    transformed_rotations(i, :) = transformed_rotationi';
end
servoAngleAllTime = zeros(numSamples, 1, 6);
for i=1:numSamples
    pArray = convertToNewFrame(transformed_rotations(i, 1), transformed_rotations(i, 2), ...
        transformed_rotations(i, 3), transformed_t(i, :)', pArrayPlatform); % 3 * 6
    pArray(abs(pArray) < ZERO_THRESHOLD) = 0;

    try
        servoAngleArray = computeServoAngleArray(pArray, bArray, s, a, ...
            betaArray);
        servoAngleArray(abs(servoAngleArray) < ZERO_THRESHOLD) = 0;

        servoAngleAllTime(i, :) = servoAngleArray;
    catch exception
        % Display the error message
        fprintf('Error in computeServoAngleArray at iteration %d:\n%s\n', ...
            i, exception.message);
        % End the program
        error('Terminating the program due to an error.');
    end
end

% disp(servoAngleAllTime)

servoAngleAllTime = convertAngleToMotorRange(servoAngleAllTime);
% add last time step as all zero (not compatible with the model, but just
% for testing)

servoAngleAllTime = cat(1, servoAngleAllTime, zeros(1, 1, 6));
disp(size(servoAngleAllTime))
disp(servoAngleAllTime)
%%
test = [0,0,0,0,0,0;180,180,180,180,180,180;270,270,270,270,270,270];
display(test);
 
%% passing one time step by one time step
% Generate 5 arrays with 6 random integers between 0 and 180
numArrays = 80; % Number of arrays
numAngles = 6; % Number of angles in each array

% Preallocate a matrix for efficiency
randomAngles = zeros(numArrays, numAngles);

for i = 1:numArrays-1 % Adjust the loop to fill only up to the second-to-last array
    randomAngles(i, :) = randi([0, 60], 1, numAngles);
end
% for i = 1:numArrays-1 % Adjust the loop to fill only up to the second-to-last array
%     % Generate a single random integer between 0 and 180
%     randomNum = randi([0, 60], 1, 1);
%     
%     % Fill the entire array with this number
%     randomAngles(i, :) = repmat(randomNum, 1, 6);
% end

% Ensure the last array contains only zeros
% This step might be redundant given the preallocation step, but it's here for clarity.
randomAngles(end, :) = zeros(1, numAngles);

% Display the generated arrays
disp(randomAngles);
 %Connect to Arduino
arduinoObj = serialport("COM7", 9600); % Update COM3 to your Arduino's port

for i=1:numArrays
    servoAngles = reshape(randomAngles(i, :, :), 1, 6);
    %disp("time step " + i + " angles: " + servoAngles);
    disp(servoAngles);
    % Give the Arduino time to reset
    pause(0.5);
    % Define an array of numbers
    numbers = servoAngles;
    %numbers = test;
    %configure = [30,50,70,90,140,180];
    % Convert the array to a string format: "12,34"
    %configureString = strjoin(string(configure), ",");
    numbersString = strjoin(string(numbers), ",");
    display(numbersString);
    % Send the string to Arduino
    writeline(arduinoObj, numbersString);

    % Wait and read confirmation from Arduino
    confirmation = readline(arduinoObj);

    % Display the confirmation
    disp(['Confirmation from Arduino: ', confirmation]);

end
% Clean up
clear arduinoObj

%% passing whole servoAngleAllTime at once
%servoAnglesTest = [30,40,50,60,70,80];
%sendMultipleServoAnglesToArduino(servoAnglesTest);




