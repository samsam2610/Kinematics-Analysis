addpath(genpath(pwd))
close all
% Define list of joints and their name

list_of_joints = {{'pelvisTop', 'hip', 'knee', 'hip angles'}, ...
                 {'hip', 'knee', 'ankle', 'knee angles'}, ... 
                 {'knee', 'ankle', 'MTP', 'ankle angles'}, ...
                 {'pelvisTop', 'hip', 'MTP', 'lower limb angles'}};

startPath = '/Users/sam/OneDrive - Northwestern University/Documents/Wireless Interface Kinematics';
% csvPaths = {'C:\Users\Zhong\OneDrive - Northwestern University\J2\Preliminary Data Visualization Demo\Channel Modulation\cam1_C0SAMP40_2021-08-12_1DLC_resnet101_Spinal ImplantOct5shuffle1_1868000.csv', ...
%             'C:\Users\Zhong\OneDrive - Northwestern University\J2\Preliminary Data Visualization Demo\Channel Modulation\cam1_C3SAMP40_2021-08-12_1DLC_resnet101_Spinal ImplantOct5shuffle1_1868000.csv', ...
%             'C:\Users\Zhong\OneDrive - Northwestern University\J2\Preliminary Data Visualization Demo\Channel Modulation\cam1_C4SAMP40_2021-08-12_1DLC_resnet101_Spinal ImplantOct5shuffle1_1868000.csv', ...
%             'C:\Users\Zhong\OneDrive - Northwestern University\J2\Preliminary Data Visualization Demo\Channel Modulation\cam1_C6SAMP30_2021-08-12_1DLC_resnet101_Spinal ImplantOct5shuffle1_1868000.csv', ...
%             'C:\Users\Zhong\OneDrive - Northwestern University\J2\Preliminary Data Visualization Demo\Channel Modulation\cam1_C7SAMP40_2021-08-12_1DLC_resnet101_Spinal ImplantOct5shuffle1_1868000.csv'};
csvPaths = {'Freddy/11012021/cam1_C0SAMP50_2021-11-01_1DLC_resnet101_Spinal ImplantOct5shuffle1_2476500.csv', ...
            'Freddy/11012021/cam1_C1SAMP60_2021-11-01_1DLC_resnet101_Spinal ImplantOct5shuffle1_2476500.csv', ...
            'Freddy/11012021/cam1_C7SAMP60_2021-11-01_1DLC_resnet101_Spinal ImplantOct5shuffle1_2476500.csv', ...
            'Freddy/11012021/cam1_C4SAMP35_2021-11-01_1DLC_resnet101_Spinal ImplantOct5shuffle1_2476500.csv', ...
            'Freddy/11012021/cam1_C6SAMP45_2021-11-01_1DLC_resnet101_Spinal ImplantOct5shuffle1_2476500.csv', ...
            'Freddy/11012021/cam1_C3SAMP35_2021-11-01_1DLC_resnet101_Spinal ImplantOct5shuffle1_2476500.csv', ...
            'Freddy/11012021/cam1_C4SAMP45_2021-11-01_1DLC_resnet101_Spinal ImplantOct5shuffle1_2476500.csv', ...
            'Freddy/11012021/cam1_C4SAMP55_2021-11-01_1DLC_resnet101_Spinal ImplantOct5shuffle1_2476500.csv'};
resFilePaths = 'C:\Users\Zhong\OneDrive - Northwestern University\J2\09102021J2\capture-frames\video-data.csv';

numberFiles = length(csvPaths);
dataFiles = struct;
skipResolution = true;
resFilePaths = false;
for indexPath = 1:numberFiles
    rawCSVPath = csvPaths{indexPath};
    csvPath = composePath(rawCSVPath, startPath);
    
    rawData = readcsvData(csvPath);
    [PIXELRESOLUTION, sampleName, sampleDate] = getPixelResolution(csvPath, skipResolution); %pixel per cm

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
end
%%
% plottedPolar = plotInstantAngle(dataFiles, list_of_joints);

%%
numberOfData = plotRecordingData(dataFiles, list_of_joints);

%%
targetAngle = 'hip angles';
numberOfData = plotRecordingDataAll(dataFiles, list_of_joints, targetAngle);

%%
plotAllData = true;
numberOfData = plotRecordingMag(dataFiles, list_of_joints, plotAllData);
plotAllData = false;
numberOfData = plotRecordingMag(dataFiles, list_of_joints, plotAllData);

