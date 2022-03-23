clear all
close all
load Freq_Modul.mat
load lookupAmpTable.mat
% startPath = 'C:\Users\Zhong\OneDrive - Northwestern University\WSI Videos for Manuscript\Recruitment Curve\Medusa\Amp modulation\Spinal';
startPath = 'C:\Users\Zhong\OneDrive - Northwestern University\WSI Videos for Manuscript\Frequency Modulation';

colorLineUnique = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#A2142F', ...
             '#4DBEEE', '#77AC30', '#40E0D0', '#6495ED', '#88A096', ...
             '#F8D210', '#94d2bd'};

colorLine = {'#cddafd',	'#dfe7fd',	'#80FFDB',	'#72EFDD', ...
             '#64DFDF',	'#56CFE1',	'#48BFE3',	'#4EA8DE', ...
         	 '#5390D9',	'#5E60CE',	'#6930c3',	'#7400B8'};

% Frequency modulation plot
close all
currentData = dataFull.Freq_Modul.data;

pixelResolution = 33; % pixels/cm

frameCount = 1.5*200;


% Sort the data by frequency
frequencyData = currentData.("Frequency");

[frequencyData, frequencyIndex] = sort(frequencyData);
currentData = currentData(frequencyIndex, :);

% Stack frequency plots
y_offset = 0;
additional_offset = 1;

toeTable = zeros(1000, height(currentData));
nameList = cell(height(currentData), 1);

windowSizeList = zeros(height(currentData), 2);
% syncronize the starting and ending position
for indexTable = 1:height(currentData)
    currentDataTables = currentData.("Data table")(indexTable);
    currentFrequency = currentData.("Frequency")(indexTable);
    dataDisplacement = currentDataTables.dataDisplacement;
    toeDisplacement = cell2mat(dataDisplacement.("Displacement Data")("toe"));
    toeDisplacement_Index = dataDisplacement.("Maximum Displacement Index")("toe");

    toeDisplacement_Diff = diff(toeDisplacement);
    [windowStart, windowEnd] = calculateWindowPos(toeDisplacement_Diff, 4, 50);
    windowSizeList(indexTable, :) = [windowStart, windowEnd];
end
windowLength = windowSizeList(:, 2) - windowSizeList(:, 1);
windowLength = frameCount;

windowStart = min(windowSizeList(:, 1));
% windowEnd = max(windowSizeList(:, 2));
windowEnd = windowStart + frameCount;

%
t = tiledlayout('flow', 'Padding', 'loose');
set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 1.96 1.58])
ax1 = nexttile;

for indexTable = 1:height(currentData)
    currentDataTables = currentData.("Data table")(indexTable);
    currentFrequency = currentData.("Frequency")(indexTable);
    dataDisplacement = currentDataTables.dataDisplacement;
    toeDisplacement = cell2mat(dataDisplacement.("Displacement Data")("toe"));
    toeDisplacement_Index = dataDisplacement.("Maximum Displacement Index")("toe");


    
    [windowStart, windowEnd] = calculateWindowPos(toeDisplacement, 5.2, 50, windowLength);
    disp("window start " + num2str(windowStart));
    dataToPlot = (toeDisplacement(windowStart:windowEnd, :))./pixelResolution;
    toeTable(1:length(dataToPlot), indexTable) = dataToPlot;
    disp("Max toe displacement is " + num2str(max(toeDisplacement)) + ...
         " and offset is " +  num2str(y_offset));
    
    nameDisplay = "Frequency = " + num2str(currentFrequency) + " ms";
    nameList{indexTable} = "f = " + num2str(currentFrequency) + " ms";
    x = [1:length(dataToPlot)]./200;
    y = dataToPlot + y_offset;
    h1 = plot(x, y);
    set(h1, 'Color', colorLineUnique{indexTable}, ...
            'MarkerFaceColor',  colorLineUnique{indexTable}, ...
            'MarkerEdgeColor', colorLineUnique{indexTable}, ...
            'MarkerSize', 2, ...
            'LineWidth', 1.5, ...
            'DisplayName', nameDisplay);
    hold on
    y_offset = y_offset + (max(toeDisplacement)/pixelResolution) + additional_offset;
end
hleg = legend;
% hleg.String = flip(hleg.String);
set(hleg, 'FontSize', 10, 'visible', 'on', 'Location', 'southeastoutside', 'FontName', 'Arial');

ax = gca;
ax.XAxis.FontSize = 8;
ax.YAxis.FontSize = 8;

ylimData = ylim;
ylimData(1) = ylimData(1);
ylimData(2) = ylimData(2) -3;
ylim(ylimData);

xlimData = xlim;
xlimData(1) = xlimData(1);
xlimData(2) = xlimData(2) - 0.1;
xlim(xlimData)

xoffset = 0.25;
yoffset = 8;

yline = [xlimData(1) + xoffset, ylimData(1) + yoffset;...
        xlimData(1) + xoffset, ylimData(1) + yoffset - 1];
plot(yline(:, 1), yline(:, 2), 'LineWidth', 1.5, ...
                            'Color', [0 0 0], ...
                            'HandleVisibility','off')
text(xlimData(1) + xoffset - 0.08, ylimData(1) + yoffset - 0.5, '1 cm', 'HorizontalAlignment', 'center')
    
xlabel('Time (s)', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial')
ylabel('Toe displacement from rest (cm)', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');
set(gca, 'YColor', 'none', 'box','off', 'TickDir', 'out', 'fontweigh', 'bold', 'fontsize', 12);
title('Frequency modulation', 'FontSize', 15, 'fontweight', 'bold');


figName = 'Frequency modulation';
ax = gcf;
exportName = startPath + "/" + figName + ".png";
exportgraphics(ax, exportName, 'Resolution', 1000);

exportName = startPath + "/" + figName + ".eps";
exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');

toeTable( ~any(toeTable,2), : ) = [];
x = [1:size(toeTable, 1)];


function [startIndex, endIndex] = calculateWindowPos(displacement, threshold, offset, windowLength)
    
    arguments
        displacement
        threshold
        offset
        windowLength (1, 1) double = 10
    end
    displacementDiff = diff(displacement);
    diffThreshold = find(displacementDiff > threshold);
    startIndex = diffThreshold(1) - offset;
    if startIndex < 1
        startIndex = 1;
    end

    endIndex_prop = startIndex + windowLength;
    displacementDiff_Rate = diff(displacementDiff);
    diffThreshold = find(displacementDiff_Rate > threshold);
    endIndex = diffThreshold(end) + offset;
    if endIndex > length(displacement) + 1
        endIndex = length(displacement) + 1;
    else
        if endIndex < endIndex_prop
            endIndex = endIndex_prop;
        end
    end
end

