close all
clear all
% Define list of joints and their name
expressionChannel = '(?<=C)[0-9]+';
expressionAmplitude = '(?<=(AMP))[0-9]+';
expressionFrequency = '(?<=([0-9]P))[0-9]+';
expressionPulseWidth = '(?<=(PW))[0-9]+';

list_of_joints = {{'pelvisTop', 'hip', 'knee', 'hip angles'}, ...
                 {'hip', 'knee', 'ankle', 'knee angles'}, ... 
                 {'knee', 'ankle', 'MTP', 'ankle angles'}, ...
                 {'pelvisTop', 'hip', 'MTP', 'lower limb angles'}};
             
startPath = '/Users/sam/Library/CloudStorage/OneDrive-NorthwesternUniversity/WSI Videos for Manuscript/';

parameterTable = readtable('video-data.csv', 'DatetimeType','text', 'TextType', 'string');
parameterTable.('RecordedDate') = datetime(parameterTable.('RecordedDate'), 'InputFormat', 'MM/dd/yy');

csvPaths = {'SCI'};

numberFiles = length(csvPaths);
dataFiles = struct;
skipResolution = true;
resFilePaths = false;
targetAngles = {'hip angles'; 'knee angles'; 'ankle angles'; 'lower limb angles'};
targetTypes = {'(?<=C).*(?=S)'; '(?<=C).*(?=T)'};
targetTypeNames = {'single pulse'; 'tetanic'};
targetTypeVariables = {'SAM', 'TAM'};
expressionIntensity = {'(?<=P)[0-9]+', '(?<=T)[0-9]+'};
dataFull = struct;
dataPlotAndExport = false;
currentSubject = 'None';
dateTimeTable = cell(8, 50);
xticklabel = num2str([0:7]');
for indexType = 1:length(targetTypes) 
    targetTypeVariable = targetTypeVariables{indexType};
    dataFull.(targetTypeVariable).index = 1;
    dataFull.(targetTypeVariable).data = zeros(1000, 3);
    dataFull.(targetTypeVariable).name = cell(1000, 1);
end

targetTypeName = 'SCI';
dataFull.(targetTypeName).index = 1;
dataFull.(targetTypeName).data = table;
dataFull.(targetTypeName).name = cell(1000, 2);

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
        
        currentFile = files{indexCSV};
        indexFull = dataFull.(targetTypeName).index;

        if contains(currentFile, 'analysis-status')
            continue
        end
    
        currentTitle = split(csvfiles(indexCSV, 1), '_');
        disp("Sample code: " + currentTitle(2) + " of subject " + subjectName);
          
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
        matchExp = regexp(currentTitle(2), expression, 'match');
        numberChannel = str2double(cell2mat(matchExp{1})) + 1;
        disp("Number channel: " + num2str(numberChannel))
  
        if isnan(numberChannel)
            numberChannel = -1;
        end
        channelCheck = parameterTable.('Channel') == numberChannel - 1;

        % get intensity level
        expression = expressionAmplitude;
        matchExp = regexp(currentTitle(2), expression, 'match');
        amplitudetLevel = str2double(cell2mat(matchExp{1}));
        disp("Amplitude value: " + num2str(amplitudetLevel) + " adc")

        if isempty(amplitudetLevel)
            amplitudeLevel = -1;
        end
        amplitudeCheck = parameterTable.('Amplitude') == amplitudetLevel;

        % get pulse width level
        expression = expressionPulseWidth;
        matchExp = regexp(currentTitle(2), expression, 'match');
        pulseWidth = str2double(matchExp{1});
        disp("Pulse width: " + num2str(pulseWidth) + " µs")

        if isempty(pulseWidth)
            pulseWidth = -1;     
        end
        pulsewidthCheck = parameterTable.('PulseWidth') == pulseWidth;
        % get frequency
        expression = expressionFrequency;
        matchExp = regexp(currentTitle(2), expression, 'match');
        frequencyData = str2double(matchExp{1});
        disp("Frequency " + num2str(frequencyData) + " hz")

        if isempty(frequencyData)
            frequencyData = -1;
        end
        frequencyCheck = parameterTable.('Frequency') == frequencyData;

        resolutionCheck = dateCheck & channelCheck & amplitudeCheck & pulsewidthCheck &frequencyCheck;
        resolution = parameterTable.('Resolution')(resolutionCheck);
        if isempty(resolution)
            resolution = 1;
        end

        rawData = readcsvData(currentFile);
        [PIXELRESOLUTION, sampleName, sampleDate] = getPixelResolution(currentFile, skipResolution); %pixel per cm

        % Filter raw data base on threshold P
        THRESHOLDVALUE = 0.7;
        filteredData = filterData(rawData, THRESHOLDVALUE);

        if size(filteredData, 1) <= size(rawData, 1)*0.2
            continue
        end

        if indexType == 1
            currentDateDiffDate = dateTimeTable{numberChannel, diffDate + 1};
            if isempty(currentDateDiffDate)
                currentDateDiffDate = zeros(1, length(targetAngles));
            end
        end

        displacementTable = extractDisplacement(filteredData);
    
        dataStruct = struct;
        dataStruct.dataCoords = filteredData;
        dataStruct.dataDisplacement = displacementTable;

        dataFull.(targetTypeName).data.('Amplitude')(indexFull) = amplitudetLevel;
        dataFull.(targetTypeName).data.('Channel')(indexFull) = numberChannel;
        dataFull.(targetTypeName).data.('Pulse Width')(indexFull) = pulseWidth;
        dataFull.(targetTypeName).data.('Frequency')(indexFull) = frequencyData;
        dataFull.(targetTypeName).data.('Date')(indexFull) = currentDate;
        dataFull.(targetTypeName).data.('Displacement Toe Max')(indexFull) = displacementTable{'toe', 'Maximum Displacement'};
        dataFull.(targetTypeName).data.('Displacement Toe Max Index')(indexFull) = displacementTable{'toe', 'Maximum Displacement Index'};
        dataFull.(targetTypeName).data.('Data table')(indexFull) = dataStruct;
        dataFull.(targetTypeName).data.('Resolution')(indexFull) = resolution(1);

        dataFull.(targetTypeName).name{indexFull} = [subjectName{1}];

        dataFull.(targetTypeName).index = dataFull.(targetTypeName).index + 1;
    end

end
dataName = dataFull.(targetTypeName).name;
dataFull.(targetTypeName).name = dataName(~cellfun(@isempty, dataName(:, 1)), :);
