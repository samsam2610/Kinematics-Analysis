addpath(genpath(pwd))
%% Load data
close all
clear all
% Define list of joints and their name

list_of_joints = {{'pelvisTop', 'hip', 'knee', 'hip angles'}, ...
                 {'hip', 'knee', 'ankle', 'knee angles'}, ... 
                 {'knee', 'ankle', 'MTP', 'ankle angles'}, ...
                 {'pelvisTop', 'hip', 'MTP', 'lower limb angles'}};
             
startPath = '/Users/sam/Library/CloudStorage/OneDrive-NorthwesternUniversity/WSI Videos for Manuscript/';
csvPaths = {
            'SCI'
            };

numberFiles = length(csvPaths);
dataFiles = struct;
skipResolution = true;
resFilePaths = false;
targetAngles = {'hip angles'; 'knee angles'; 'ankle angles'; 'lower limb angles'};

expressionChannel = '(?<=C)[0-9]+';
expressionAmplitude = '(?<=(AMP))[0-9]+';
expressionFrequency = '(?<=([0-9]P))[0-9]+';
expressionPulseWidth = '(?<=(PW))[0-9]+';


targetTypeName = 'SCI';
dataFull.(targetTypeName).index = 1;
dataFull.(targetTypeName).data = table;
dataFull.(targetTypeName).name = cell(1000, 2);

dataTable = zeros(100, 3);
indexTable = 1;

for indexPath = 1:length(csvPaths)
    disp("Current path number is " + num2str(indexPath));
    rawCSVPath = csvPaths{indexPath};
    folderPath = composePath(rawCSVPath, startPath);
    myfiles = dir(folderPath);
    splitCSVPath = split(rawCSVPath, '/');
    nameGroup = string(strjoin(splitCSVPath, '-'));
    subjectName = splitCSVPath(1);

    filenames={myfiles(:).name}';
    filefolders={myfiles(:).folder}';

    csvfiles=filenames(endsWith(filenames,'.csv'));
    csvfolders = filefolders(endsWith(filenames,'.csv'));

    files = fullfile(csvfolders,csvfiles);

    

    for indexCSV = 1:length(files)
        
        indexFull = dataFull.(targetTypeName).index;
        currentFile = files{indexCSV};

        if contains(currentFile, 'analysis-status')
            continue
        end

        currentTitle = split(csvfiles(indexCSV, 1), '_');
        disp("Sample code: " + currentTitle(2) + " of subject " + subjectName);
        
        % get channel number
        expression = expressionChannel;
        matchExp = regexp(currentTitle(2), expression, 'match');
        numberChannel = str2double(cell2mat(matchExp{1})) + 1;
        disp("Number channel: " + num2str(numberChannel))
  
        if isnan(numberChannel)
            continue
        end

        % get intensity level
        expression = expressionAmplitude;
        matchExp = regexp(currentTitle(2), expression, 'match');
        amplitudetLevel = str2double(cell2mat(matchExp{1}));
        disp("Amplitude value: " + num2str(amplitudetLevel) + " adc")

        if isnan(amplitudetLevel)
            continue
        end

        % get pulse width level
        expression = expressionPulseWidth;
        matchExp = regexp(currentTitle(2), expression, 'match');
        pulseWidth = str2double(matchExp{1});
        disp("Pulse width: " + num2str(pulseWidth) + " µs")

        if isnan(pulseWidth)
            continue
        end

        % get frequency
        expression = expressionFrequency;
        matchExp = regexp(currentTitle(2), expression, 'match');
        frequencyData = str2double(matchExp{1});
        disp("Frequency " + num2str(frequencyData) + " hz")

        if isnan(frequencyData)
            continue
        end

        rawData = readcsvData(currentFile);
        % Filter raw data base on threshold P
        THRESHOLDVALUE = 0.7;
        filteredData = filterData(rawData, THRESHOLDVALUE);

        if size(filteredData, 1) <= size(rawData, 1)*0.2
            continue
        end
        displacementTable = extractDisplacement(filteredData);
        
        dataStruct = struct;
        dataStruct.dataCoords = filteredData;
        dataStruct.dataDisplacement = displacementTable;

        dataFull.(targetTypeName).data.('Amplitude')(indexFull) = amplitudetLevel;
        dataFull.(targetTypeName).data.('Channel')(indexFull) = numberChannel;
        dataFull.(targetTypeName).data.('Pulse Width')(indexFull) = pulseWidth;
        dataFull.(targetTypeName).data.('Frequency')(indexFull) = frequencyData;
        dataFull.(targetTypeName).data.('Displacement Toe Max')(indexFull) = displacementTable{'toe', 'Maximum Displacement'};
        dataFull.(targetTypeName).data.('Displacement Toe Max Index')(indexFull) = displacementTable{'toe', 'Maximum Displacement Index'};
        dataFull.(targetTypeName).data.('Data table')(indexFull) = dataStruct;

        dataFull.(targetTypeName).name{indexFull} = 'Frequency Modulation';

        dataFull.(targetTypeName).index = dataFull.(targetTypeName).index + 1;
    end
end