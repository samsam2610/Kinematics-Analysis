close all
clear all
% Define list of joints and their name

list_of_joints = {{'pelvisTop', 'hip', 'knee', 'hip angles'}, ...
                 {'hip', 'knee', 'ankle', 'knee angles'}, ... 
                 {'knee', 'ankle', 'MTP', 'ankle angles'}, ...
                 {'pelvisTop', 'hip', 'MTP', 'lower limb angles'}};
             
startPath = '/Users/sam/Library/CloudStorage/OneDrive-NorthwesternUniversity/Documents/Wireless Interface Kinematics';

csvPaths = {'Augusto(T)/08232021Augusto', ...
            'Augusto(T)/08262021Augusto', ...
            'Freddy/11012021', ...
            'Freddy/11112021', ...
            'J2/08052021J2', ...
            'J2/08122021J2', ...
            'J2/08212021J2', ...
            'J2/08262021J2', ...
            'J2/08312021J2', ...
            'J2/09102021J2', ...
            'Sep(R0)/09072021Sep', ...
            'Godzilla/11152021', ...
            'Godzilla/11252021', ...
            'Godzilla/12022021', ...
            'Godzilla/12062021'};

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


for indexPath = 1:length(csvPaths)
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


    for indexType = 1:length(targetTypes)
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

            dataFiles.(sampleName).displacementToeMax = displacementTable{'toe', 'Maximum Displacement'};
            dataFiles.(sampleName).angleInstantTable = angleInstantTable;
            dataFiles.(sampleName).angleTable = angleTable;
            dataFiles.(sampleName).distanceTable = distanceTable;
            dataFiles.(sampleName).data = filteredData;
            dataFiles.(sampleName).pixelResolution = PIXELRESOLUTION;

            dataTable(indexData, 1:3) = [powerLevel, ...
                                         numberChannel, ...
                                         dataFiles.(sampleName).displacementToeMax];
            dataFull_small(indexFull, 1:3) = [powerLevel, ...
                                              numberChannel, ...
                                              dataFiles.(sampleName).displacementToeMax];
            dataFull_smallName(indexFull, 1) = subjectName(1);

            if indexType == 1
                currentDiffMax = currentDateDiffDate(1, 1);
                if abs(currentDiffMax) < abs(dataFiles.(sampleName).displacementToeMax)
                    currentDateDiffDate(1, 1) = dataFiles.(sampleName).displacementToeMax;
                end
            end


            if indexType == 1
                dateTimeTable{numberChannel, diffDate+1} = currentDateDiffDate;
                dataFull_small(indexFull, 4) = diffDate+1;
            end
            
            indexData = indexData + 1;
            indexFull = indexFull + 1;
        end


        dataFull.(targetTypeVariable).index = indexFull;
        dataFull.(targetTypeVariable).data = dataFull_small;
        dataFull.(targetTypeVariable).name = dataFull_smallName;

        dataTable(~any(dataTable, 2), : ) = [];
        if isempty(dataTable)
            continue
        end

        if ~dataPlotAndExport
            continue
        end

        % x = min(dataTable(:, 2)):1:max(dataTable(:, 2));
        x = 1:1:8;
%         y = min(dataTable(:, 1)):5:max(dataTable(:, 1));
        y = 0:5:140;
        [X, Y] = meshgrid(x, y);
        Z = [Y(:) X(:)];
        angleMatrix = zeros(size(y, 2), size(x, 2));
        clear indexDataTable
        [~, indexDataTable] = ismember(dataTable(:, 1:2), Z, 'rows' );

    end
end

%%
for indexType = 1:length(targetTypes) 
    targetTypeVariable = targetTypeVariables{indexType};
    targetName = targetTypeNames{indexType};
    dataIndex = dataFull.(targetTypeVariable).index;
    dataTable = dataFull.(targetTypeVariable).data;

    dataTable(~any(dataTable, 2), : ) = [];
    % Process data table
    dataTable_lite = dataTable(:, 1:2);
    [C, ia, ic] = unique(dataTable_lite, 'rows');
    dataTableClean = zeros(size(ia, 1), size(dataTable, 2));
    for indexTable = 1:length(ia)
        currentData = dataTable(ic == ic(indexTable), :);
        dataTableClean(indexTable, :) = mean(currentData, 1);
    end

    if ~dataPlotAndExport
        continue
    end

%     x = min(dataTableClean(:, 2)):1:max(dataTableClean(:, 2));
%     y = min(dataTableClean(:, 1)):5:max(dataTableClean(:, 1));
    x = 1:1:8;
    y = 0:5:140;
    [X, Y] = meshgrid(x, y);
    Z = [Y(:) X(:)];
    angleMatrix = zeros(size(y, 2), size(x, 2));
    clear indexDataTable
    [~, indexDataTable] = ismember(dataTableClean(:, 1:2), Z, 'rows' );

    for indexAngle = 1:length(targetAngles)
        figure
        angleMatrix(indexDataTable) = dataTableClean(:, indexAngle+2);

        imagesc(x, y, angleMatrix);
        xlabel('Channel number');
        ylabel('Power level (step of 5)');
        figName = string(targetAngles{indexAngle}) + " - " + string(targetName);
        title(figName);
        set(gca,'YDir','normal', 'XTick', x, 'YTick', y);
        xticklabels(xticklabel);
        colormap jet
        colorBar = colorbar;
        colorBar.Label.String = 'Angles (degree)';
        ax = gcf;
        exportName = startPath + "/" + figName + ".png";
        exportgraphics(ax, exportName, 'Resolution', 400);
    end
end