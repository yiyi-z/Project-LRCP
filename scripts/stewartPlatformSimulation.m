% add functions used in the script
addpath("../functions")


% Stewart Platform configuration (of our model)
bArray = [90.53, 49.00, -46.66, -89.04, -41.28, 42.62; ...
         0, 74.28, 74.28, 0, -81.72, -81.72; ...
         0, 0, 0, 0, 0, 0]; % 3 * 6
pArrayPlatform = 0.6 * bArray; % 3 * 6
s = 100;
a = 25;
betaArray = deg2rad([120 + 180, 120 + 180, 240 + 180, 240 + 180, 360 + 180, 360 + 180]); % 1 * 6, add 180 since motors face inwards

% Sample input values (Sine)
amplitude = 20;
frequency = 1;          
timeShift = 0;
amplitudeShift = 0;
duration = 1; 
samplingRate = 2;
numSamples = round(duration * samplingRate);

sineData = generateSineData(amplitude, frequency, timeShift, ...
    amplitudeShift, duration, samplingRate);
% t = [sineData, zeros(numSamples, 1) , zeros(numSamples, 1) + 100];  % numSample * 3
% t = [zeros(numSamples, 1) + 20, sineData, zeros(numSamples, 1) + 100];  % numSample * 3
% t = [zeros(numSamples, 1), zeros(numSamples, 1), 0.1 * sineData + 100];  % numSample * 3

t = [zeros(numSamples, 1), zeros(numSamples, 1), zeros(numSamples, 1) + 100];  % numSample * 3


% rotations = [0.01 * sineData, zeros(numSamples, 1), ...
%     zeros(numSamples, 1)];
% rotations = [zeros(numSamples, 1), 0.01 * sineData, ...
%     zeros(numSamples, 1)];
% rotations = [zeros(numSamples, 1), zeros(numSamples, 1), ...
%    0.01 * sineData];

rotations = [zeros(numSamples, 1), zeros(numSamples, 1), ...
     zeros(numSamples, 1)];  % numSample * 3

% Compute pArray and servoAngles and save them to a matrix for later
% visualiation
pArrayAllTime = zeros(numSamples, 3, 6);
servoAngleAllTime = zeros(numSamples, 1, 6);
for i=1:numSamples
    pArray = convertToNewFrame(rotations(i, 1), rotations(i, 2), ...
        rotations(i, 3), transpose(t(i, :)), pArrayPlatform);
    pArrayAllTime(i, :, :) = pArray;

    try
        servoAngleArray = computeServoAngleArray(pArray, bArray, s, a, ...
            betaArray);
        servoAngleAllTime(i, :) = servoAngleArray;
    catch exception
        % Display the error message
        fprintf('Error in computeServoAngleArray at iteration %d:\n%s\n', ...
            i, exception.message);
        % End the program
        error('Terminating the program due to an error.');
    end
end

% Create Visualization
for i = 1:numSamples    
    % Update plot
    updateStewartPlatformPlot(t(i, :), reshape(pArrayAllTime(i, :, :), 3, 6), bArray, ...
        betaArray, reshape(servoAngleAllTime(i, :, :), 1, 6), a);
    
    % Set plot properties
    title('Stewart Platform Animation');
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    grid on;
    
    % Pause to create animation effect
    pause(0.1);
end

% Display the result
disp('Servo Angles (in radians):');
disp(servoAngleAllTime);


