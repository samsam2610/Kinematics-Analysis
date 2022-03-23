%% Plot skeleton
close all
skipResolution = true;
subjectName = "Godzilla";
numberOfPoints = 30;
stepPoint = 3;
% folderPath = 'C:\Users\Zhong\OneDrive - Northwestern University\WSI Videos for Manuscript\Skeletal Trajectory for diverse response';
folderPath = 'C:\Users\Zhong\OneDrive - Northwestern University\WSI Videos for Manuscript\Skeletal Trajectory for diverse response';
startPath = 'C:\Users\Zhong\OneDrive - Northwestern University\Wireless Interface Kinematics\Skeletal Trajectory for diverse response\Skeletal Trajectory';

parameterTable = readtable('video-data.csv', 'DatetimeType','text', 'TextType', 'string');
parameterTable.('RecordedDate') = datetime(parameterTable.('RecordedDate'), 'InputFormat', 'MM/dd/yy');

% currentFile = 'C:\Users\Zhong\OneDrive - Northwestern University\Wireless Interface Kinematics\J2\08312021J2\cam1_C7SAMP20_2021-08-31_200f-10e100g1DLC_resnet101_Spinal ImplantOct5shuffle1_1868000';
% currentFile = '/Users/sam/Library/CloudStorage/OneDrive-NorthwesternUniversity/Documents/Wireless Interface Kinematics/J2/08312021J2/cam1_C7SAMP20_2021-08-31_200f-10e100g1DLC_resnet101_Spinal ImplantOct5shuffle1_1868000.csv';
% sampleName = 'cam1_C7SAMP20_2021-08-31_200f-10e100g1DLC_resnet101_Spinal ImplantOct5shuffle1_1868000';
% currentTitle = split(sampleName, '_');

list_of_joints = {{'pelvisTop', 'hip', 'knee', 'hip angles'}, ...
                 {'hip', 'knee', 'ankle', 'knee angles'}, ... 
                 {'knee', 'ankle', 'MTP', 'ankle angles'}, ...
                 {'pelvisTop', 'hip', 'MTP', 'lower limb angles'}};

colorLineUnique = {'#29ABE2', '#D95319', '#FF2F15', '#7E2F8E', '#35F6FF', ...
                   '#4DBEEE', '#77AC30', '#40E0D0', '#6495ED', '#88A096', ...
                   '#F8D210', '#94d2bd'};

myfiles = dir(folderPath);

filenames={myfiles(:).name}';
filefolders={myfiles(:).folder}';

csvfiles=filenames(endsWith(filenames,'.csv'));
csvfolders = filefolders(endsWith(filenames,'.csv'));

files = fullfile(csvfolders,csvfiles);

plottingList = ["start", "end"];
numberOfPointsList = [40, 30, 30];
stepPointList = [2, 2, 2];

for currentFileIndex = 1:length(files)
    numberOfPoints = numberOfPointsList(currentFileIndex);
    stepPoint = stepPointList(currentFileIndex);
    
    for plottingIndex = 1:1
        plottingType = plottingList(plottingIndex);
        currentFile = files{currentFileIndex};
        sampleName = csvfiles{currentFileIndex};
        currentTitle = split(sampleName, '_');
    
        [numberChannel, intensityLevel, pulseWidth, frequencyValue, currentDate, resolution] = getVideoData(sampleName, parameterTable);
        rawData = readcsvData(currentFile);
        [PIXELRESOLUTION, sampleName, sampleDate] = getPixelResolution(currentFile, skipResolution); %pixel per cm
    
        % Filter raw data base on threshold P
        THRESHOLDVALUE = 0.7;
        filteredData = filterData(rawData, THRESHOLDVALUE);
    
        angleTable = extractAngle(filteredData, list_of_joints);
        displacementTable = extractDisplacement(filteredData);
    
        dataFiles.(sampleName).displacementToeMax = displacementTable{'toe', 'Maximum Displacement Index'};
        dataFiles.(sampleName).data = filteredData;
    
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
        
        if strcmp(plottingType, "start")
            dataCoordToPlot = dataStartCoords;
        else
            dataCoordToPlot = dataFinalCoords;
            dataCoordToPlot = flip(dataCoordToPlot);
        end
    
        t = tiledlayout('flow', 'Padding', 'loose');
        ax = nexttile;
        set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 1.96 1.58]);
        flipSkeleton = false;
    
        options.resolution = resolution;
        for indexTable = 1:height(dataCoordToPlot) - 1
            skeletonInitial = SkeletonModel(dataCoordToPlot(indexTable, :), "resolution", resolution);
            plotName = '';
            indexColor = 1;
            LineStyle = '-';
            ax = skeletonInitial.plotPositionUpdate(ax, colorPallete=colorLineUnique{indexColor}, ...
                                                        plotNameDisplay=false, ...
                                                        flipSkeleton=flipSkeleton, ...
                                                        LineWidth= 0.5, ...
                                                        LineStyle = '--', ...
                                                        MarkerSize= 2);
        end
        
        axis equal;
        ylimData = ylim;
        ylimData(1) = 2;
        ylimData(2) = 19;
        ylim(ylimData);

        xlimData = xlim;
        xlimData(1) = 10;
        xlimData(2) = 27;
        xlim(xlimData);
    
        plotNameList = {'Resting position', 'Maximum position'};
    
        plot(dataCoordToPlot{:, 'toe'}.X./resolution, dataCoordToPlot{:, 'toe'}.Y./resolution, ...
                                                        'Color', colorLineUnique{6}, ...
                                                        'LineWidth', 1, ...
                                                        'HandleVisibility','off');
    
        skeletonMaximum = SkeletonModel(dataCoordToPlot(1, :), "resolution", resolution);
        ax = skeletonMaximum.plotPositionUpdate(ax, colorPallete=colorLineUnique{3}, ...
                                                    plotName=plotNameList{1}, ...
                                                    flipSkeleton=flipSkeleton, ...
                                                    LineWidth= 0.5, ...
                                                    LineStyle = '-', ...
                                                    MarkerSize= 2);
        pointMax = skeletonMaximum.toe;
        annotationMax = annotation('textarrow', 'String', plotNameList{1}, ...
                                                'HeadStyle', 'none', ...
                                                'LineWidth', 1.5, ...
                                                'FontSize', 12, ...
                                                'TextMargin', 3);
        annotationMax.Parent = ax;
        annotationMax.X = [pointMax(1) - 1 pointMax(1)];
        annotationMax.Y = [pointMax(2) - 0.3 pointMax(2)];
    
    
    
        skeletonResting = SkeletonModel(dataCoordToPlot(end, :), "resolution", resolution);
        ax = skeletonResting.plotPositionUpdate(ax, colorPallete=colorLineUnique{5}, ...
                                                    plotName=plotNameList{2}, ...
                                                    flipSkeleton=flipSkeleton, ...
                                                    LineWidth= 0.5, ...
                                                    LineStyle= '-', ...
                                                    MarkerSize= 3);
        pointRest = skeletonResting.toe;
        annotationRest = annotation('textarrow', 'String', plotNameList{2}, ...
                                                'HeadStyle', 'none', ...
                                                'LineWidth', 1.5, ...
                                                'FontSize', 12, ...
                                                'TextMargin', 3);
        annotationRest.Parent = ax;
        annotationRest.X = [pointRest(1) + 0.7 pointRest(1)];
        annotationRest.Y = [pointRest(2) - 0.5 pointRest(2)];
    
    
        hleg = legend;
        set(hleg, 'FontSize', 12, 'visible', 'off', 'Location', 'NorthEast');
       
    
        xoffset = 1.25;
        yoffset = 10;
        xline = [xlimData(1) + xoffset, ylimData(1) + yoffset;...
                xlimData(1) + xoffset + 1, ylimData(1) + yoffset];
    
        plot(xline(:, 1), xline(:, 2), 'LineWidth', 1.5, ...
                                    'Color', [0 0 0], ...
                                    'HandleVisibility','off')
        text(xlimData(1) + xoffset + 1 - 0.1, ylimData(1) + yoffset + 0.2, '1 cm', 'HorizontalAlignment', 'right')
    
        yline = [xlimData(1) + xoffset, ylimData(1) + yoffset;...
                xlimData(1) + xoffset, ylimData(1) + yoffset - 1];
        plot(yline(:, 1), yline(:, 2), 'LineWidth', 1.5, ...
                                    'Color', [0 0 0], ...
                                    'HandleVisibility','off')
        text(xlimData(1) + xoffset - 0.5, ylimData(1) + yoffset - 0.5, '1 cm', 'HorizontalAlignment', 'center')
    
        xlabel('Vertical displacement (cm)', 'FontSize', 10)
        ylabel('Horizontal displacement (cm)', 'FontSize', 10)
        title(t, "Toe trajectory from rest to max, at channel " + num2str(numberChannel-1) + " and intensity = " + num2str(intensityLevel), 'FontSize', 15);
    
%         ylimData = ylim;
%         ylimData(1) = ylimData(1);
%         ylimData(2) = ylimData(2) + 0.5;
%         ylim(ylimData);
%     
%         xlimData = xlim;
%         xlimData(1) = xlimData(1);
%         xlimData(2) = xlimData(2) + 0.5;
%         xlim(xlimData)


    
        figName = sampleName + " " + plottingType;
        ax = gcf;
%         set(gca, 'XColor', 'none', 'YColor', 'none');
        exportName = startPath + "/" + figName + ".png";
        exportgraphics(ax, exportName, 'Resolution', 1000);
    
        exportName = startPath + "/" + figName + ".eps";
        exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');
    end
end
