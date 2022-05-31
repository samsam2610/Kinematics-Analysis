addpath(genpath(pwd))
clear all
close all

expressionChannel = '(?<=C)[0-9]+';
expressionAmplitude = '(?<=(AMP))[0-9]+';
expressionFrequency = '(?<=([0-9]P))[0-9]+';
expressionPulseWidth = '(?<=(PW))[0-9]+';

startPath = 'C:\Users\Zhong\OneDrive - Northwestern University\Wireless Interface Kinematics\Treadmill data\D2';
csvPaths = {
            ...
            '0513(cropped)', ...
            '0513channel 6(cropped)'
            };

targetTypeName = 'Treadmill';

dataFull.(targetTypeName).index = 1;
dataFull.(targetTypeName).data = table;
dataFull.(targetTypeName).name = cell(1000, 2);

colorLineUnique = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#A2142F', ...
             '#4DBEEE', '#77AC30', '#40E0D0', '#6495ED', '#88A096', ...
             '#F8D210', '#94d2bd'};
patternFile = ("analysis-status"|"calib"|"tetanic"|"walking"|"propulsion"|"flexion"|"bilateral");

parameterTable = readtable('video-data.csv', 'DatetimeType','text', 'TextType', 'string');
parameterTable.('RecordedDate') = datetime(parameterTable.('RecordedDate'), 'InputFormat', 'MM/dd/yy');

for indexPath = 1:length(csvPaths)
    disp("Current path number is " + num2str(indexPath));
    rawCSVPath = csvPaths{indexPath};
    folderPath = composePath(rawCSVPath, startPath);
    dataFiles = dir(folderPath);

    framePath = fullfile(folderPath, 'capture-frames');
    frameFiles = dir(framePath);
    [csvFrameFiles, csvFrameFolders] = getCSV(frameFiles);
    files = fullfile(csvFrameFolders, csvFrameFiles);
    for indexCSV = 1:length(files)
        currentFile = files{indexCSV};
        
        if contains(currentFile, "video-data", 'IgnoreCase', true)
            continue
        end
        parameterTable = readcsvData(currentFile);
        parameterNames = parameterTable.bodyparts;
    end

    splitCSVPath = split(rawCSVPath, '/');
    nameGroup = string(strjoin(splitCSVPath, '-'));
    subjectName = splitCSVPath(1);

    [csvFiles, csvFolders] = getCSV(dataFiles);


    files = fullfile(csvFolders, csvFiles);
    for indexCSV = 1:length(files)

        currentFile = files{indexCSV};


        indexFull = dataFull.(targetTypeName).index;

        if contains(currentFile, patternFile, 'IgnoreCase', true)
            continue
        end
    
        currentTitle = split(csvFiles(indexCSV, 1), '_');
        for indexCode = 2:4
            sampleCode = currentTitle(indexCode);
            patternCode = ("AMP");
            if contains(sampleCode, patternCode, 'IgnoreCase', true)
                break
            end
        end
        disp("Sample code: " + sampleCode + " of subject " + subjectName);
        cameraCode = currentTitle(1);
        disp("Camera name: " + cameraCode);
        
        % get resolution 
        patternSample = string(currentTitle(1)) + "_" + string(currentTitle(2)) + "_" + string(currentTitle(3));
        sampleParamIndex = find(contains(parameterNames, patternSample));
        x1 = parameterTable(sampleParamIndex, :).UpperPoint.X;
        x2 = parameterTable(sampleParamIndex, :).LowerPoint.X;
        y1 = parameterTable(sampleParamIndex, :).UpperPoint.Y;
        y2 = parameterTable(sampleParamIndex, :).LowerPoint.Y;
        distancePixel = sqrt((x1 - x2)^2 + (y1 - y2)^2);
        resolutionValue = distancePixel/5; %pixel per 5 cm;
        disp("Resolution is " + resolutionValue + " pixels per cm");

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
        disp("Recorded date: " + datestr(currentDate));

        % get channel number
        expression = expressionChannel;
        matchExp = regexp(sampleCode, expression, 'match');
        numberChannel = str2double(cell2mat(matchExp{1})) + 1;
        disp("Number channel: " + num2str(numberChannel));

        % get intensity level
        expression = expressionAmplitude;
        matchExp = regexp(sampleCode, expression, 'match');
        amplitudetLevel = str2double(cell2mat(matchExp{1}));
        if isempty(amplitudetLevel)
            amplitudeLevel = -1;
        end
        disp("Amplitude value: " + num2str(amplitudetLevel) + " adc");

        % get pulse width level
        expression = expressionPulseWidth;
        matchExp = regexp(currentTitle(2), expression, 'match');
        pulseWidth = str2double(matchExp{1});
        if isempty(pulseWidth)
            pulseWidth = -1;     
        end
        disp("Pulse width: " + num2str(pulseWidth) + " µs")

        % get frequency
        expression = expressionFrequency;
        matchExp = regexp(currentTitle(2), expression, 'match');
        frequencyData = str2double(matchExp{1});
        if isempty(frequencyData)
            frequencyData = -1;
        end
        disp("Frequency " + num2str(frequencyData) + " hz")
        
        rawData = readcsvData(currentFile);
        % Filter raw data base on threshold P
        THRESHOLDVALUE = 0.7;
        variableNames = rawData.Properties.VariableNames;
        variableNames = variableNames([1, 8:length(variableNames)]);
        filteredData = filterData(rawData, THRESHOLDVALUE, variableNames);

        if size(filteredData, 1) <= size(rawData, 1)*0.2
            continue
        end


        displacementTable = extractDisplacement(filteredData, true, false);
    
        dataStruct = struct;
        dataStruct.dataCoords = filteredData;
        dataStruct.dataDisplacement = displacementTable;

        dataFull.(targetTypeName).data.('Camera Name')(indexFull) = cameraCode;
        dataFull.(targetTypeName).data.('Amplitude')(indexFull) = amplitudetLevel;
        dataFull.(targetTypeName).data.('Channel')(indexFull) = numberChannel;
        dataFull.(targetTypeName).data.('Pulse Width')(indexFull) = pulseWidth;
        dataFull.(targetTypeName).data.('Frequency')(indexFull) = frequencyData;
        dataFull.(targetTypeName).data.('Date')(indexFull) = currentDate;
        dataFull.(targetTypeName).data.('Displacement Toe Max')(indexFull) = displacementTable{'toe', 'Maximum Displacement'};
        dataFull.(targetTypeName).data.('Displacement Toe Max Index')(indexFull) = displacementTable{'toe', 'Maximum Displacement Index'};
        dataFull.(targetTypeName).data.('Data table')(indexFull) = dataStruct;
        dataFull.(targetTypeName).data.('Resolution')(indexFull) = resolutionValue;

        dataFull.(targetTypeName).name{indexFull, 1} = subjectName{1};
        dataFull.(targetTypeName).name{indexFull, 2} = splitCSVPath{1};

        dataFull.(targetTypeName).index = dataFull.(targetTypeName).index + 1;

    end
end

dataName = dataFull.(targetTypeName).name;
dataFull.(targetTypeName).name = dataName(~cellfun(@isempty, dataName(:, 1)), :);