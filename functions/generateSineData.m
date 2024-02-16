function sineData = generateSineData(amplitude, frequency, timeShift, amplitudeShift, duration, samplingRate)
% Generate sine wave data as a matrix
% output a column vector that takes duration * samplingRate samples from a
% sine wave of amplitude * sin(2 * pi * frequency * (t - timeShift)) + 
% amplitudeShift

    % Calculate the number of samples
    numSamples = round(duration * samplingRate);

    % Time vector
    t = linspace(0, duration, numSamples);

    % Generate sine wave data
    sineData = amplitude * sin(2 * pi * frequency * (t - timeShift)) + amplitudeShift;
    sineData = sineData(:);  
end
