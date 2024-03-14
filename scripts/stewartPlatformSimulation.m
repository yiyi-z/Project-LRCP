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
duration = 5; 
samplingRate = 20;
numSamples = round(duration * samplingRate);
topToTarget = [100; -50; 30]; 

sineData = generateSineData(amplitude, frequency, timeShift, ...
    amplitudeShift, duration, samplingRate);
% t = [sineData, zeros(numSamples, 1) , zeros(numSamples, 1)];  % numSample * 3
% t = [zeros(numSamples, 1) + 20, sineData, zeros(numSamples, 1)];  % numSample * 3
% t = [zeros(numSamples, 1), zeros(numSamples, 1), 0.1 * sineData];  % numSample * 3

t = [zeros(numSamples, 1), zeros(numSamples, 1), zeros(numSamples, 1)];  % numSample * 3


% rotations = [0.01 * sineData, zeros(numSamples, 1), ...
%     zeros(numSamples, 1)];
rotations = [zeros(numSamples, 1), 0.005 * sineData, ...
    zeros(numSamples, 1)];
% rotations = [zeros(numSamples, 1), zeros(numSamples, 1), ...
%    0.01 * sineData];

% rotations = [zeros(numSamples, 1), zeros(numSamples, 1), ...
%      zeros(numSamples, 1)];  % numSample * 3


% translate rotation and translation for target wrt home target coordinate,
% to rotation and translation for center of top platform wrt base coordinate
transformed_t = zeros(size(t));
transformed_rotations = zeros(size(rotations));
for i = 1:size(t, 1)
    % Extract translation and rotation vectors
    ti = t(i, :)';
    rotationi = rotations(i, :)';
    % display(ti)
    % display(rotationi)

    % Apply targetToTopPlatform function
    [transformed_ti, transformed_rotationi] = targetToTopPlatform(ti, rotationi, topToTarget);
    % display(transformed_ti)
    % display(transformed_rotationi)
    transformed_ti(3) = transformed_ti(3) + s;
    % Store transformed vectors in matrices
    transformed_t(i, :) = transformed_ti';
    transformed_rotations(i, :) = transformed_rotationi';
end

% back to base coordinate


% Compute pArray and servoAngles and save them to a matrix for later
% visualiation
pArrayAllTime = zeros(numSamples, 3, 6);
servoAngleAllTime = zeros(numSamples, 1, 6);
for i=1:numSamples
    pArray = convertToNewFrame(transformed_rotations(i, 1), transformed_rotations(i, 2), ...
        transformed_rotations(i, 3), transpose(transformed_t(i, :)), pArrayPlatform);
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
    updateStewartPlatformPlot(transformed_t(i, :)', reshape(pArrayAllTime(i, :, :), 3, 6), bArray, ...
        betaArray, reshape(servoAngleAllTime(i, :, :), 1, 6), a, s, topToTarget, t(i, :)');
    
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


