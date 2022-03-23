close all
clear all
% Define list of joints and their name

list_of_joints = {{'pelvisTop', 'hip', 'knee', 'hip angles'}, ...
                 {'hip', 'knee', 'ankle', 'knee angles'}, ... 
                 {'knee', 'ankle', 'MTP', 'ankle angles'}, ...
                 {'pelvisTop', 'hip', 'MTP', 'lower limb angles'}};
             
startPath = '/Users/sam/Library/CloudStorage/OneDrive-NorthwesternUniversity/Documents/Wireless Interface Kinematics';

csvPaths = {
            'J2/08052021J2', ...
            'J2/08122021J2', ...
            'J2/08212021J2', ...
            'J2/08262021J2', ...
            'J2/08312021J2', ...
            'J2/09102021J2', ...
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
    dataFull.(targetTypeVariable).data = zeros(1000, 3);
    dataFull.(targetTypeVariable).name = cell(1000, 1);
end

colorLine = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#A2142F', '#4DBEEE', '#77AC30', '#40E0D0', '#6495ED'};
numberOfPoints = 20;
stepPoint = 2;
for indexPath = 5:5 %length(csvPaths)
    disp("Current path number is " + num2str(indexPath));
    rawCSVPath = csvPaths{indexPath};
    folderPath = composePath(rawCSVPath, startPath);
    myfiles = dir(folderPath);
    splitCSVPath = split(rawCSVPath, '/');
    nameGroup = string(strjoin(splitCSVPath, '-'));
    subjectName = splitCSVPath(1);

    currentDate = splitCSVPath(2);
    expression = '[0-9]*';
    currentDate = regexp(currentDate, expression, 'match', 'once');
    currentDate = datetime(cell2mat(currentDate), 'InputFormat', 'MMddyyyy');

    if ~strcmp(subjectName, currentSubject)
        currentSubject = subjectName;
        initialDate = currentDate;
 
    end

    diffDate = round(daysact(initialDate, currentDate));

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
        

        for indexCSV = 1:length(files)
            
            currentFile = files{indexCSV};

            if contains(currentFile, 'analysis-status')
                continue
            end

            currentTitle = split(csvfiles(indexCSV, 1), '_');
            disp("Sample code: " + currentTitle(2) + " of subject " + subjectName);
            
            % get channel number
            expression = targetType;
            matchExp = regexp(currentTitle(2), expression, 'match');
            numberChannel = str2double(cell2mat(matchExp{1})) + 1;
            disp("Number channel: " + num2str(numberChannel))
      
            if isnan(numberChannel)
                continue
            end

            % get intensity level
            for expression = expressionIntensity
                matchExp = regexp(currentTitle(2), expression, 'match');
                if ~isempty(matchExp{1})
                    break
                end
            end
%             expression = '(?<=P)[0-9]+';
%             matchExp = regexp(currentTitle(2), expression, 'match');
            powerLevel = str2double(cell2mat(matchExp{1}));
            disp("Intensity level: " + num2str(powerLevel))

            if isnan(powerLevel)
                continue
            else
                expression = '(PW0)|(PW100)';
                matchExp = regexp(currentTitle(2), expression);
                if ~isempty(matchExp{1})
                    continue
                end

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

            angleTable = extractAngle(filteredData, list_of_joints);
            angleInstantTable = getInstantAngle(angleTable, filteredData, list_of_joints); % get coordinate of when angle is max
            angleInstantTable = polarizeData(angleInstantTable);
            distanceTable = extractDistance(filteredData, PIXELRESOLUTION);
            displacementTable = extractDisplacement(filteredData);

            dataFiles.(sampleName).displacementToeMax = displacementTable{'toe', 'Maximum Displacement Index'};
            dataFiles.(sampleName).distanceTable = distanceTable;
            dataFiles.(sampleName).data = filteredData;
            
            indexData = indexData + 1;
            indexFull = indexFull + 1;

            displacementMaxIndex = displacementTable{'toe', 'Maximum Displacement Index'};
            startIndex = displacementMaxIndex - numberOfPoints*stepPoint;
            if startIndex < 1
                startIndex = 1;
            end

            finalIndex = displacementMaxIndex + numberOfPoints*stepPoint;
            if finalIndex > height(filteredData)
                finalIndex = length(filterData);
            end

            dataStartCoords = dataFiles.(sampleName).data([startIndex:stepPoint:displacementMaxIndex], :);
            dataFinalCoords = dataFiles.(sampleName).data([displacementMaxIndex:stepPoint:finalIndex], :);
        
            t = tiledlayout('flow', 'Padding', 'loose');
            ax = nexttile;

            for indexTable = 1:height(dataStartCoords)
                skeletonInitial = SkeletonModel(dataStartCoords(indexTable, :));
                ax = skeletonInitial.plotPosition(ax, colorLine{1});
            end

            plot(dataStartCoords{:, 'toe'}.X, dataStartCoords{:, 'toe'}.Y, ...
                'Color', colorLine{6}, ...
                'LineWidth', 1.5);

%             for indexTable = 1:height(dataStartCoords)
%                 skeletonInitial = SkeletonModel(dataFinalCoords(indexTable, :));
%                 ax = skeletonInitial.plotPosition(ax, colorLine{2});
%             end
%             plot(dataFinalCoords{:, 'toe'}.X, dataFinalCoords{:, 'toe'}.Y, ...
%                  'Color', colorLine{6}, ...
%                  'LineWidth', 1.5);

            axis equal;
            xlabel('Vertical displacement (pixel)', 'FontSize', 10)
            ylabel('Horizontal displacement (pixel)', 'FontSize', 10)
            title(t, "Toe trajectory from rest to max, at channel " + num2str(numberChannel - 1) + " and intensity = " + num2str(powerLevel), 'FontSize', 15);
            figName = subjectName + " " + string(currentTitle{2}) + " " + string(currentTitle{3}) + " " + "RTM";
            ax = gcf;
            exportName = startPath + "/" + figName + ".png";
            exportgraphics(ax, exportName, 'Resolution', 1000);
        end



    end
end
