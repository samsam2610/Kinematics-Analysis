addpath(genpath(pwd))
clear all
close all
load
expressionSpeed = '(?<=S)[0-9]+';

list_of_joints = {{'pelvisTop', 'hip', 'knee', 'hip angles'}, ...
                 {'hip', 'knee', 'ankle', 'knee angles'}, ... 
                 {'knee', 'ankle', 'MTP', 'ankle angles'}, ...
                 {'pelvisTop', 'hip', 'MTP', 'lower limb angles'}};
             
% startPath = ['C:\Users\Zhong\OneDrive - Northwestern University\Wireless Interface Kinematics\Treadmill data'];
% startPath = 'C:\Users\Zhong\OneDrive - Northwestern University\Wireless Interface Kinematics\Treadmill data';
startPath = '/Users/sam/Library/CloudStorage/OneDrive-NorthwesternUniversity/Documents/Wireless Interface Kinematics/Treadmill data';
csvPaths = {
            'Quick analysis 4'
            };

numberFiles = length(csvPaths);
dataFiles = struct;
skipResolution = true;
resFilePaths = false;
dataFull = struct;

targetTypeName = 'Treadmill';

dataFull.(targetTypeName).index = 1;
dataFull.(targetTypeName).data = table;
dataFull.(targetTypeName).name = cell(1000, 2);

colorLineUnique = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#A2142F', ...
             '#4DBEEE', '#77AC30', '#40E0D0', '#6495ED', '#88A096', ...
             '#F8D210', '#94d2bd'};

offset = 0;
duration = 30; %second
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
        disp("Recorded date: " + datestr(currentDate));

        currentName = currentTitle{2};
        if strcmp(currentName, 'David')
            currentName = 'D1';
        end

        % get intensity level
        expression = expressionSpeed;
        matchExp = regexp(currentTitle(2), expression, 'match');
        speedValue = str2double(cell2mat(matchExp{1}));
        if isempty(speedValue) || isnan(speedValue)
            speedValue = 10;
        end
        disp("Treadmill speed: " + num2str(speedValue))
        currentVideoDir = strrep(currentFile, '.csv', '_labeled.mp4');
        v = VideoReader(currentVideoDir);
        currentFrameRate = v.FrameRate;

        rawData = readcsvData(currentFile);
        % Filter raw data base on threshold P
        THRESHOLDVALUE = 0.99999;
        variableNames = rawData.Properties.VariableNames;
        variableNames = variableNames([1, 8:length(variableNames)]);
        filteredData = filterData(rawData, THRESHOLDVALUE, variableNames);
        angleData = extractAngle(filteredData, list_of_joints);
        if size(filteredData, 1) <= size(rawData, 1)*0.2
            continue
        end
        
        dataStruct = struct;
        dataStruct.dataCoords = filteredData;
        dataStruct.dataRaws = rawData;
        dataStruct.angleData = angleData;
        
        dataFull.(targetTypeName).data.('Date')(indexFull) = currentDate;
        dataFull.(targetTypeName).data.('Data table')(indexFull) = dataStruct;
        dataFull.(targetTypeName).data.('FrameRate')(indexFull) = currentFrameRate;

        dataFull.(targetTypeName).name{indexFull, 1} = currentName;

        dataFull.(targetTypeName).index = dataFull.(targetTypeName).index + 1;
        

    end
end

dateList = dataFull.Treadmill.data.Date;
[dateList, dateListIndex] = sort(dateList);
dataFull.Treadmill.data = dataFull.Treadmill.data(dateListIndex, :);
dataFull.Treadmill.name = dataFull.Treadmill.name(dateListIndex, :);