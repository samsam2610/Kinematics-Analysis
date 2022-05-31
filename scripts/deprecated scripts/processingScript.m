close all
csvPath = 'C:\Users\Zhong\OneDrive - Northwestern University\J2\09102021J2\cam1_C0SAMP30_2021-09-10_1DLC_resnet101_Spinal ImplantOct5shuffle1_1868000.csv';
resFilePath = 'C:\Users\Zhong\OneDrive - Northwestern University\J2\09102021J2\capture-frames\video-data.csv';

rawData = readcsvData(csvPath);
PIXELRESOLUTION = getPixelResolution(csvPath, resFilePath); %pixel per cm

% Define list of joints and their name

list_of_joints = {{'pelvisTop', 'hip', 'knee', 'hip angles'}, ...
                 {'hip', 'knee', 'ankle', 'knee angles'}, ... 
                 {'knee', 'ankle', 'MTP', 'ankle angles'}, ...
                 {'pelvisTop', 'hip', 'MTP', 'lower limb angles'}};

% Filter raw data base on threshold P
THRESHOLDVALUE = 0.7;
filteredData = filterData(rawData, THRESHOLDVALUE);
             
%% Get the angle data
angleTable = extractAngle(filteredData, list_of_joints);

%% Get the travel distance data
distanceTable = extractDistance(filteredData, PIXELRESOLUTION);

%% Plot trajectory
plottedData = plotTrajectory(filteredData);

%% Polar coordinates
filteredData = polarizeData(filteredData);
plottedPolarData = plotPolar(filteredData);

%% Normalize data
normalizedData = normalizeData(filteredData, 1);
normalizedData = polarizeData(normalizedData);
normalizedPolarData = plotPolar(normalizedData);

%% determine cropping point in data
params.summationPoint = {'ankle', 'toe', 'MTP'};
[startPoint, stopPoint] = cropData(normalizedData, params);

%% crop data
stopPoint = 585;
croppedData = normalizedData(startPoint:stopPoint, :);

%% Plot cropped data
plottedPolarData = plotPolar(croppedData);
