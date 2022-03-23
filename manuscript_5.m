close all
clear all
% Define list of joints and their name

list_of_joints = {{'pelvisTop', 'hip', 'knee', 'hip angles'}, ...
                 {'hip', 'knee', 'ankle', 'knee angles'}, ... 
                 {'knee', 'ankle', 'MTP', 'ankle angles'}, ...
                 {'pelvisTop', 'hip', 'MTP', 'lower limb angles'}};
             
% startPath = 'C:\Users\Zhong\OneDrive - Northwestern University\WSI Videos for Manuscript\Recruitment Curve\Medusa\Amp modulation\Spinal';
% startPath = 'C:\Users\Zhong\OneDrive - Northwestern University\WSI Videos for Manuscript\Recruitment Curve\Medusa';
startPath = '/Users/sam/Library/CloudStorage/OneDrive-NorthwesternUniversity/WSI Videos for Manuscript/Recruitment Curve/Medusa';

csvPaths = {
            'Pulse width modulation/Spinal', ...
            'Pulse width modulation/Muscle', ...
            'Pulse width modulation/Muscle flat mod', ...
            'Amp modulation/Spinal', ...
            'Amp modulation/Muscle'
            }'
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
    dataFull.(targetTypeVariable).data = zeros(1000, 5);
    dataFull.(targetTypeVariable).name = cell(1000, 2);
    dataFull.(targetTypeVariable).skeletonMax = table;
    dataFull.(targetTypeVariable).skeletonMin = table;
end

 parameterTable = readtable('video-data.csv', 'DatetimeType','text', 'TextType', 'string');
 parameterTable.('RecordedDate') = datetime(parameterTable.('RecordedDate'), 'InputFormat', 'MM/dd/yy');

    
colorLine = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#A2142F', '#4DBEEE', '#77AC30', '#40E0D0', '#6495ED'};
numberOfPoints = 20;
stepPoint = 2;
for indexPath = 1:5 %length(csvPaths)
    disp("Current path number is " + num2str(indexPath));
    rawCSVPath = csvPaths{indexPath};
    folderPath = composePath(rawCSVPath, startPath);
    myfiles = dir(folderPath);
    splitCSVPath = split(rawCSVPath, '/');
    nameGroup = string(strjoin(splitCSVPath, '-'));
    subjectName = splitCSVPath(1);
    subjectGroup = splitCSVPath(2);

    filenames={myfiles(:).name}';
    filefolders={myfiles(:).folder}';

    csvfiles=filenames(endsWith(filenames,'.csv'));
    csvfolders = filefolders(endsWith(filenames,'.csv'));

    files = fullfile(csvfolders,csvfiles);


    for indexType = 1:1%length(targetTypes)
        targetType = targetTypes{indexType};
        targetName = targetTypeNames{indexType};
        targetTypeVariable = targetTypeVariables{indexType};

        dataTable = zeros(100, 3);
        indexData = 1;

        indexFull = dataFull.(targetTypeVariable).index;
        dataFull_small = dataFull.(targetTypeVariable).data;
        dataFull_smallName = dataFull.(targetTypeVariable).name;
        skeletonMax = dataFull.(targetTypeVariable).skeletonMax;
        skeletonMin = dataFull.(targetTypeVariable).skeletonMin;
        

        for indexCSV = 1:length(files)
            
            currentFile = files{indexCSV};

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
            expression = targetType;
            matchExp = regexp(currentTitle(2), expression, 'match');
            numberChannel = str2double(cell2mat(matchExp{1})) + 1;
            disp("Number channel: " + num2str(numberChannel))
      
            if isnan(numberChannel)
                continue
            else
                channelCheck = parameterTable.('Channel') == numberChannel - 1;
            end

            % get intensity level
            for expression = expressionIntensity
                matchExp = regexp(currentTitle(2), expression, 'match');
                if ~isempty(matchExp{1})
                    break
                end
            end
            expression = '(?<=P)[0-9]+';
            matchExp = regexp(currentTitle(2), expression, 'match');
            intensityLevel = str2double(cell2mat(matchExp{1}));
            disp("Intensity level: " + num2str(intensityLevel))

            if isnan(intensityLevel)
                continue
            else
                amplitudeCheck = parameterTable.('Amplitude') == intensityLevel;
            end

            matchExp = split(currentTitle(2), 'PW');
            pulseWidth = str2double(matchExp{2});
            disp("Pulse width: " + num2str(pulseWidth))

            if isnan(pulseWidth)
                continue
            else
                pulsewidthCheck = parameterTable.('PulseWidth') == pulseWidth;
            end

            resolutionCheck = dateCheck & channelCheck & amplitudeCheck & pulsewidthCheck;
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

            angleTable = extractAngle(filteredData, list_of_joints);
            angleInstantTable = getInstantAngle(angleTable, filteredData, list_of_joints); % get coordinate of when angle is max
            angleInstantTable = polarizeData(angleInstantTable);
            distanceTable = extractDistance(filteredData, PIXELRESOLUTION);
            displacementTable = extractDisplacement(filteredData);

            dataFiles.(sampleName).displacementToeMax = displacementTable{'toe', 'Maximum Displacement'};
            dataFiles.(sampleName).distanceTable = distanceTable;
            dataFiles.(sampleName).data = filteredData;
            
            dataTable(indexData, 1:5) = [intensityLevel, ...
                                         pulseWidth, ...
                                         numberChannel, ...
                                         dataFiles.(sampleName).displacementToeMax, ...
                                         resolution];
            dataFull_small(indexFull, 1:5) = [intensityLevel, ...
                                              pulseWidth, ...
                                              numberChannel, ...
                                              dataFiles.(sampleName).displacementToeMax, resolution];
            dataFull_smallName(indexFull, 1:2) = [subjectName(1), subjectGroup(1)];
            skeletonMax(indexFull, :) = filteredData(displacementTable{'toe', 'Maximum Displacement Index'}, :);
            skeletonMin(indexFull, :) = filteredData(1, :);

            
            indexData = indexData + 1;
            indexFull = indexFull + 1;
        end
        dataFull.(targetTypeVariable).index = indexFull;
        dataFull.(targetTypeVariable).data = dataFull_small;
        dataFull.(targetTypeVariable).name = dataFull_smallName;
        dataFull.(targetTypeVariable).skeletonMax = skeletonMax;
        dataFull.(targetTypeVariable).skeletonMin = skeletonMin;

        dataTable(~any(dataTable, 2), : ) = [];
        if isempty(dataTable)
            continue
        end

        if ~dataPlotAndExport
            continue
        end


    end
end
