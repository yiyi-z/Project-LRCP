addpath("../functions/")
amplitude = 1;
frequency = 2;
timeShift = 0;
amplitudeShift = 0;
duration = 10;
samplingRate = 20;

numSamples = round(duration * samplingRate);
dataX = linspace(0, duration, numSamples);
dataY = generateSineData(amplitude, frequency, timeShift, ...
    amplitudeShift, duration, samplingRate);

DataMapS1 = containers.Map;
keysListS1 = {'DataS1X', 'DataS1Y', 'DataS1Z', 'DataS1Yaw', 'DataS1Pitch', 'DataS1Roll'};
for i = 1:length(keysListS1)
    DataMapS1(keysListS1{i}) = [];
end

motionX = dataX;
motionY = transpose(dataY);
dimension = 'x';
platformNumber = 1;
DataMapS1('DataS1Y') = {motionX * 2, motionY};

switch platformNumber
    case 1
        key = char('DataS1' + string(upper(dimension(1))) + string(dimension(2:end)));
        DataMapS1(key) = {motionX, motionY};
        keys = DataMapS1.keys;
        figure;
        hold on;
        for i = 1:length(keys)
            curveData = DataMapS1(keys{i});
            if ~isempty(curveData)
                plot(curveData{1}, curveData{2}, 'DisplayName', keys{i});
            end
        end
        legend('show');

        hold off;
end