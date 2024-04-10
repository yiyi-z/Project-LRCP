%% add functions used in the script
addpath("../functions")


%% Stewart Platform configuration (of our model)
% refer to function computeServoAngleArray for more details
bArray = [99, 64, -46, -88, -46, 35; ...
         0, 71, 81, 14, -81, -88; ...
         0, 0, 0, 0, 0, 0]; % 3 * 6
pArrayPlatform = [45, 11, -11, -41, -27, 34; ...
         -11, 43, 43, -11, -29, -29; ...
         0, 0, 0, 0, 0, 0]; % 3 * 6
s = 100;
a = 25;
betaArray = deg2rad([120 + 180, 120 + 180, 240 + 180, 240 + 180, ...
    360 + 180, 360 + 180]); % 1 * 6, add 180 since motors face inwards
baseToTop = [0; 0; 85]; % from center of base coordinate to top platform coordinate (at home position)
topToTarget = [152; -95; 51]; % 3 * 1, from centor of the top platform to center of the target (at home position) in home top platform coordinate


%% Sample input values (Sine)
amplitude = 10;
frequency = 1;          
timeShift = 0;
amplitudeShift = 0;
duration = 3; 
samplingRate = 10;
numSamples = round(duration * samplingRate);

% we will use this threshold to filter value that's zero but not store as
% exactly zero
ZERO_THRESHOLD = 1e-6; 

% t and rotations are based on home target coordinate

sineData = generateSineData(amplitude, frequency, timeShift, ...
    amplitudeShift, duration, samplingRate);

t = [sineData, zeros(numSamples, 1) , zeros(numSamples, 1) ];  % numSample * 3
% t = [zeros(numSamples, 1), sineData, zeros(numSamples, 1)];  % numSample * 3
% t = [zeros(numSamples, 1), zeros(numSamples, 1), 0.3 * sineData];  % numSample * 3
% t = [zeros(numSamples, 1), zeros(numSamples, 1), zeros(numSamples, 1)];  % numSample * 3

% rotations = [0.015 * sineData, zeros(numSamples, 1), ...
%     zeros(numSamples, 1)];
% rotations = [zeros(numSamples, 1), 0.005 * sineData, ...
%     zeros(numSamples, 1)];
% rotations = [zeros(numSamples, 1), zeros(numSamples, 1), ...
%    0.01 * sineData];
rotations = [zeros(numSamples, 1), zeros(numSamples, 1), ...
     zeros(numSamples, 1)];  % numSample * 3


t(abs(t) < ZERO_THRESHOLD) = 0;
rotations(abs(rotations) < ZERO_THRESHOLD) = 0;

%% translate rotation and translation for target wrt home target coordinate to rotation and translation for center of top platform wrt base coordinate
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


%% Compute pArray, housingUnitVectors and servoAngles and save them to a matrix for later visualiation
pArrayAllTime = zeros(numSamples, 3, 6);
servoAngleAllTime = zeros(numSamples, 1, 6);
housingUnitVectorsAllTime = zeros(numSamples, 3, 3);
for i=1:numSamples
    pArray = convertToNewFrame(transformed_rotations(i, 1), transformed_rotations(i, 2), ...
        transformed_rotations(i, 3), transformed_t(i, :)', pArrayPlatform); % 3 * 6
    pArray(abs(pArray) < ZERO_THRESHOLD) = 0;
    pArrayAllTime(i, :, :) = pArray;

    housingUnitVectorsAllTime(i, :, :) = housingCoordinateToBaseCoordinate(topToTarget, baseToTop, t(i, :)', rotations(i, :)');

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


%% Create Visualization
for i = 1:numSamples    
    % Update plot
    updateStewartPlatformPlot(transformed_t(i, :)', reshape(pArrayAllTime(i, :, :), 3, 6), bArray, ...
        betaArray, reshape(servoAngleAllTime(i, :, :), 1, 6), a, baseToTop, topToTarget, t(i, :)', reshape(housingUnitVectorsAllTime(i, :, :), 3, 3));
    
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


