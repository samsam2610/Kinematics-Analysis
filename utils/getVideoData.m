function [numberChannel, amplitudetLevel, pulseWidth, frequencyValue, currentDate, resolution] = getVideoData(csvFileName, parameterTable, offset)
    arguments
        csvFileName
        parameterTable
        offset (1, 1) double = 0
    end
    expressionChannel = '(?<=C)[0-9]+';
    expressionAmplitude = '(?<=(AMP))[0-9]+';
    expressionFrequency = '(?<=([0-9]P))[0-9]+';
    expressionPulseWidth = '(?<=(PW))[0-9]+';

    currentTitle = split(csvFileName, '_');
    disp("Sample code: " + currentTitle(2 + offset));

    % get recorded date
    for indexDate = 3:5
        try
            currentDate = currentTitle(indexDate);
            currentDate = datetime(cell2mat(currentDate), 'InputFormat', 'yyyy-MM-dd');
            break
        catch
            currentDate = datetime('2000-01-01', 'InputFormat', 'yyyy-MM-dd');
            continue
        end
    end

    dateCheck = parameterTable.('RecordedDate') == currentDate;

    % get channel number
    expression = expressionChannel;
    matchExp = regexp(currentTitle(2 + offset), expression, 'match');
    numberChannel = str2double(cell2mat(matchExp{1})) + 1;

    if isempty(numberChannel) || isnan(numberChannel)
        numberChannel = -1;
    end
    disp("Number channel: " + num2str(numberChannel))
    channelCheck = parameterTable.('Channel') == numberChannel - 1;

    % get intensity level
    expression = expressionAmplitude;
    matchExp = regexp(currentTitle(2 + offset), expression, 'match');
    amplitudetLevel = str2double(cell2mat(matchExp{1}));
    

    if isempty(amplitudetLevel) || isnan(amplitudetLevel)
        amplitudetLevel = -1;
    end
    disp("Amplitude value: " + num2str(amplitudetLevel) + " adc")
    amplitudeCheck = parameterTable.('Amplitude') == amplitudetLevel;

    % get pulse width level
    expression = expressionPulseWidth;
    matchExp = regexp(currentTitle(2 + offset), expression, 'match');
    pulseWidth = str2double(matchExp{1});

    if isempty(pulseWidth) || isnan(pulseWidth)
        pulseWidth = -1;
    end
    disp("Pulse width: " + num2str(pulseWidth) + " µs")
    pulsewidthCheck = parameterTable.('PulseWidth') == pulseWidth;

    % get frequency
    expression = expressionFrequency;
    matchExp = regexp(currentTitle(2 + offset), expression, 'match');
    frequencyValue = str2double(matchExp{1});

    if isempty(frequencyValue) || isnan(frequencyValue)
        frequencyValue = -1; 
    end
    disp("Frequency " + num2str(frequencyValue) + " hz")
    frequencyCheck = parameterTable.('Frequency') == frequencyValue;

    resolutionCheck = dateCheck & channelCheck & amplitudeCheck & pulsewidthCheck;
    if sum(resolutionCheck) == 0
        resolution = 1;
        disp("Couldn't find matching resolution in file. Setting resolution to 1")
    else
        resolution = parameterTable.('Resolution')(resolutionCheck);
        disp("Resolution " + num2str(resolution) + " pixel/cm")
    end

end