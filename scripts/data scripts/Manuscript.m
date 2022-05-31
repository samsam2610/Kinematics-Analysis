addpath(genpath(pwd))

close all
% Define list of joints and their name

list_of_joints = {{'pelvisTop', 'hip', 'knee', 'hip angles'}, ...
                 {'hip', 'knee', 'ankle', 'knee angles'}, ... 
                 {'knee', 'ankle', 'MTP', 'ankle angles'}, ...
                 {'pelvisTop', 'hip', 'MTP', 'lower limb angles'}};
             
startPath = '/Users/sam/Library/CloudStorage/OneDrive-NorthwesternUniversity/WSI Videos for Manuscript';
% csvPaths = {'Amp Modulation/J2', ...
%            'Channel Modulation/Tetanic/Freddy', ...
%            'Channel Modulation/Tetanic/Godzilla', ...
%            'Channel Modulation/Single Pulse/Freddy'};

% plotDimension = [2, 3, 300, 600, 0, 500; ...
%                  2, 2, 200, 550, 100, 500; ...
%                  2, 2, 100, 550, 150, 500; ...
%                  2, 3, 200, 550, 100, 500];

csvPaths = {'Pulse Width/Godzilla', ...
                 'Spinal & Muscle Co-stim/Godzilla', ...
                 'Frequency Modulation/Alpha (Muscle only)', ... % TODO: Need retrain Jan-9-22
                 'Frequency Modulation/Freddy', ...
                 'Chronic Stability/Godzilla (5weeks)/First', ...
                 'Chronic Stability/Godzilla (5weeks)/Second', ...
                 'Chronic Stability/Godzilla (5weeks)/Third', ... % TODO: Need retrain Jan-9-22
                 'Chronic Stability/Godzilla (5weeks)/Fourth', ...
                 'Chronic Stability/Godzilla (5weeks)/Fifth', ...
                 'Chronic Stability/Julie (4weeks)(Field Power Modulation)/First (Trembling Video)', ...
                 'Chronic Stability/Julie (4weeks)(Field Power Modulation)/Second', ... % TODO: Need retrain Jan-9-22
                 'Chronic Stability/Julie (4weeks)(Field Power Modulation)/Third', ...
                 'Chronic Stability/Alpha(3weeks, muscle electrodes)/First', ... % TODO: Need retrain Jan-9-22
                 'Chronic Stability/Alpha(3weeks, muscle electrodes)/Second', ...
                 'Chronic Stability/Alpha(3weeks, muscle electrodes)/Third', ... % TODO: Need retrain Jan-9-22
                 'Chronic Stability/Freddy(3weeks)/First', ...
                 'Chronic Stability/Freddy(3weeks)/Second', ...
                 'Chronic Stability/Freddy(3weeks)/Third'};

plotDimension = [2, 2, 200, 650, 0, 600; ...
                 2, 2, 0, 650, 100, 500; ...
                 2, 2, 100, 550, 150, 500; ... % Frequency Modulation Alpha
                 2, 2, 200, 550, 100, 500; ...
                 1, 1, 300, 600, 100, 600; ...
                 1, 1, 300, 600, 100, 600; ...% Chronic Godzilla Third
                 1, 1, 300, 600, 100, 600; ...
                 1, 2, 100, 600, 100, 600; ...
                 1, 1, 100, 500, 100, 500; ...
                 2, 2, 300, 700, 0, 500; ...
                 2, 2, 300, 700, 0, 500; ... % Chronic Julie Second
                 2, 2, 100, 600, 0, 500; ...
                 1, 3, 100, 600, 0, 500; ...% Chronic Alpha First 
                 1, 3, 100, 600, 0, 500; ... % Hip angle bad choice
                 1, 3, 100, 600, 0, 500; ... % Chronic Alpha Third 
                 1, 1, 100, 600, 0, 500; ...
                 1, 1, 100, 600, 0, 500; ...
                 1, 2, 300, 600, 200, 500;];
       
numberFiles = length(csvPaths);
dataFiles = struct;
skipResolution = true;
resFilePaths = false;
targetAngle = 'hip angles';
for indexPath = 18:18
    rawCSVPath = csvPaths{indexPath};
    folderPath = composePath(rawCSVPath, startPath);
    
    myfiles = dir(folderPath);
    filenames={myfiles(:).name}';
    filefolders={myfiles(:).folder}';

    csvfiles=filenames(endsWith(filenames,'.csv'));
    csvfolders = filefolders(endsWith(filenames,'.csv'));

    files=fullfile(csvfolders,csvfiles);
    currentPlotDimension = plotDimension(indexPath, :);
    figure
    
    indexFile = 0;
    for indexCSV = 1:length(files)
        
        currentFile = files{indexCSV};
        
        if contains(currentFile, 'analysis-status')
            continue
        else
            indexFile = indexFile + 1;
        end
        
        currentTitle = split(csvfiles(indexCSV, 1), '_');
        currentTitle = join(currentTitle(1:3), '_');
        
        rawData = readcsvData(currentFile);
        [PIXELRESOLUTION, sampleName, sampleDate] = getPixelResolution(currentFile, skipResolution); %pixel per cm

        % Filter raw data base on threshold P
        THRESHOLDVALUE = 0.7;
        filteredData = filterData(rawData, THRESHOLDVALUE);
        normalizedData = normalizeData(filteredData);
                    
        %% Get the angle data
        angleTable = extractAngle(filteredData, list_of_joints);
        angleInstantTable = getInstantAngle(angleTable, filteredData, list_of_joints); % get coordinate of when angle is max
        angleInstantTable = polarizeData(angleInstantTable);
        distanceTable = extractDistance(filteredData, PIXELRESOLUTION);
        dataFiles.(sampleName).angleInstantTable = angleInstantTable;
        dataFiles.(sampleName).angleTable = angleTable;
        dataFiles.(sampleName).distanceTable = distanceTable;
        dataFiles.(sampleName).data = filteredData;
        dataFiles.(sampleName).pixelResolution = PIXELRESOLUTION;
        
        currentInstantData = dataFiles.(sampleName).angleInstantTable(targetAngle, :);
        dataAngleMaxIndex = currentInstantData.('Highest Angle Instant').Index;
        dataCoords = dataFiles.(sampleName).data([1 dataAngleMaxIndex], :);
        
        h1 = subplot(currentPlotDimension(1), currentPlotDimension(2), indexFile);
        skeletonInitial = SkeletonModel(dataCoords(1, :));
        skeletonMaximal = SkeletonModel(dataCoords(2, :));
        h1 = skeletonInitial.plotPosition(h1, 'b');
        h1 = skeletonMaximal.plotPosition(h1, 'r');
        xlim([currentPlotDimension(3) currentPlotDimension(4)]);
        ylim([currentPlotDimension(5) currentPlotDimension(6)]);
        title(currentTitle, 'Interpreter', 'none');
    end
end
    