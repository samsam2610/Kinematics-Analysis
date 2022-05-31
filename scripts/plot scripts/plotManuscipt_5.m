addpath(genpath(pwd))
clear all
load dataFull_Amp_Modul_2.mat
load lookupAmpTable.mat
% startPath = 'C:\Users\Zhong\OneDrive - Northwestern University\WSI Videos for Manuscript\Recruitment Curve\Medusa\Amp modulation\Old Old Spinal';
startPath = 'C:\Users\Zhong\OneDrive - Northwestern University\WSI Videos for Manuscript\Recruitment Curve\Medusa\Amp modulation\Old Old Spinal';
targetTypeNames = {'single pulse'; 'tetanic'};
targetTypeVariables = {'SAM', 'TAM'};
list_of_joints = {{'pelvisTop', 'hip', 'knee', 'hip angles'}, ...
                 {'hip', 'knee', 'ankle', 'knee angles'}, ... 
                 {'knee', 'ankle', 'MTP', 'ankle angles'}, ...
                 {'pelvisTop', 'hip', 'MTP', 'lower limb angles'}};

dataFull_small = dataFull.SAM.data;
dataFull_name = dataFull.SAM.name;
dataFull_skeletonMax = dataFull.SAM.skeletonMax;
dataFull_skeletonMin = dataFull.SAM.skeletonMin;

dataDate = dataFull_small(:, end);
dataFull_name(dataDate == 0, :) = [];
dataDate(dataDate == 0) = [];

powerUnique = unique(dataFull_small(:, 2));
channelMax = max(dataFull_small(:, 3));
intensityUnique = unique(dataFull_small(:, 1));
[subjectUnique, ~, subjectUniqueIndex] = unique(dataFull_name(:, 1));
[groupUnique, ~, groupUniqueIndex] = unique(dataFull_name(:, 2));
colorLineUnique = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#A2142F', ...
             '#4DBEEE', '#77AC30', '#40E0D0', '#6495ED', '#88A096', ...
             '#F8D210', '#94d2bd', '#0072BD', '#D95319', '#EDB120'};

colorLine = {'#cddafd',	'#dfe7fd',	'#80FFDB',	'#72EFDD', ...
             '#64DFDF',	'#56CFE1',	'#48BFE3',	'#4EA8DE', ...
         	 '#5390D9',	'#5E60CE',	'#6930c3',	'#7400B8'};

%% section 1 - Plot amp modulation data - spinal
close all
subjectIndex = 1;
groupIndex = 3;
currentSubject = subjectUnique{subjectIndex};
currentGroup = groupUnique{groupIndex};

indexData = and((subjectUniqueIndex(:) == subjectIndex), (groupUniqueIndex(:) == groupIndex));
currentData = dataFull_small(indexData, :);

x = currentData(:, 1);
y = currentData(:, 4);

[x, xIndex] = sort(x);
y = y(xIndex);

x_secondary = x;
x = lookupAmpTable(x-1, 2)*1000;

t = tiledlayout('flow', 'Padding', 'loose');
set(gcf, 'Position',  [100, 100, 1800, 900])
ax1 = nexttile;
box(ax1);
h1 = plot(x, y, '-o');
set(h1, 'Color', colorLineUnique{2}, ...
                     'MarkerFaceColor', colorLineUnique{2}, ...
                     'MarkerEdgeColor', colorLineUnique{2}, ...
                     'MarkerSize', 5, ...
                     'LineWidth', 1);

xlabel('Amplitude (µA)', 'FontSize', 10)
ylabel('Toe displacement (pixel)', 'FontSize', 10);

title('Spinal - Amp modulation - recruitment curve', 'FontSize', 15);
figName = 'Amp modulation - Spinal';
ax = gcf;
exportName = startPath + "/" + figName + ".png";
exportgraphics(ax, exportName, 'Resolution', 1000);

exportName = startPath + "/" + figName + ".eps";
exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');

%% section 2 - Plot PW modulation data - spinal
close all
subjectIndex = 2;
groupIndex = 3;
currentSubject = subjectUnique{subjectIndex};
currentGroup = groupUnique{groupIndex};

indexData = and((subjectUniqueIndex(:) == subjectIndex), (groupUniqueIndex(:) == groupIndex));
currentData = dataFull_small(indexData, :);

x = currentData(:, 2);
y = currentData(:, 4);

[x, xIndex] = sort(x);
y = y(xIndex);

ax1 = plot(x, y, '-o');
set(ax1(1), 'Color', colorLineUnique{2}, ...
                     'MarkerFaceColor', colorLineUnique{2}, ...
                     'MarkerEdgeColor', colorLineUnique{2}, ...
                     'MarkerSize', 5, ...
                     'LineWidth', 1);
ylimData = ylim;
ylimData(1) = 0;
ylimData(2) = ylimData(2) + 20;
ylim(ylimData);

xlimData = xlim;
xlimData(1) = 0;
xlimData(2) = xlimData(2) + 1;
xlim(xlimData)

xticks([xlimData(1):10:xlimData(2)]);
xlabel('Pulse width', 'FontSize', 10)
ylabel('Toe displacement (pixel)', 'FontSize', 10)
title('Spinal - Pulse width modulation - recruitment curve', 'FontSize', 20);
figName = 'Pulse width modulation - Spinal';
ax = gcf;
exportName = startPath + "/" + figName + ".png";
exportgraphics(ax, exportName, 'Resolution', 1000);

exportName = startPath + "/" + figName + ".eps";
exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');

%% section 3 - Plot amp modulation - Muscle
close all
subjectIndex = 1;
groupIndex = 1;
currentSubject = subjectUnique{subjectIndex};
currentGroup = groupUnique{groupIndex};

indexData = and((subjectUniqueIndex(:) == subjectIndex), (groupUniqueIndex(:) == groupIndex));
currentData = dataFull_small(indexData, :);

x = currentData(:, 1);
y = currentData(:, 4)./currentData(:, 5);

x(end+1) = 0;
y(end+1) = 0;

[x, xIndex] = sort(x);
y = y(xIndex);

x_secondary = x;
% x = lookupAmpTable(x-1, 2)*1000;

t = tiledlayout('flow', 'Padding', 'loose');
set(gcf, 'PaperUnits','inches','PaperPosition', [0 0 1.96 1.58]);
ax1 = nexttile;
box(ax1);
h1 = plot(x, y, '-o');
set(h1, 'Color', colorLineUnique{2}, ...
                     'MarkerFaceColor',  colorLineUnique{2}, ...
                     'MarkerEdgeColor', colorLineUnique{2}, ...
                     'MarkerSize', 3, ...
                     'LineWidth', 1.5);

xlabel('Amplitude (µA)', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial')
ylabel('Toe displacement (cm)', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');

title('Muscle - Amp modulation - recruitment curve', 'FontSize', 15, 'FontName', 'Arial');
figName = 'Amp modulation - Muscle';
ax = gcf;
exportName = startPath + "/" + figName + ".png";
exportgraphics(ax, exportName, 'Resolution', 1000);

exportName = startPath + "/" + figName + ".eps";
exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');

%% section 4 - Plot pulse width modulation - Muscle
close all
subjectIndex = 2;
groupIndex = 1;
currentSubject = subjectUnique{subjectIndex};
currentGroup = groupUnique{groupIndex};

indexData = and((subjectUniqueIndex(:) == subjectIndex), (groupUniqueIndex(:) == groupIndex));
currentData = dataFull_small(indexData, :);

listChannel = unique(currentData(:, 3));

t = tiledlayout('flow', 'Padding', 'loose');
ax = nexttile;
hold on
set(gcf, 'Position',  [100, 100, 1300, 600])

for indexChannel = 1:length(listChannel)
    currentChannel = listChannel(indexChannel);

    axList(currentChannel, 1) = ax;
    currentChannelData = currentData(currentData(:, 3) == currentChannel, :);
    currentIntensity = lookupAmpTable(currentChannelData(1, 1), 2)*1000;

    x = currentChannelData(:, 2);
    y = currentChannelData(:, 4);

    [x, xIndex] = sort(x);
    y = y(xIndex);

    ax1 = plot(x, y, '-o');
    set(ax1(1), 'Color', colorLineUnique{indexChannel}, ...
                        'MarkerFaceColor', colorLineUnique{indexChannel}, ...
                        'MarkerEdgeColor', colorLineUnique{indexChannel}, ...
                        'MarkerSize', 6, ...
                        'LineWidth', 2);
    ylimData = ylim;
    ylimData(1) = 0;
    ylimData(2) = ylimData(2) + 20;
    ylim(ylimData);

    xlimData = xlim;
    xlimData(1) = 0;
    xlimData(2) = xlimData(2) + 1;
    xlim(xlimData)

    ax1(1).DisplayName = "Intensity = " + num2str(currentIntensity) + " µA of channel " + num2str(currentChannel - 1);
end
xlabel('Pulse width', 'FontSize', 15);
ylabel('Toe displacement (pixel)', 'FontSize', 15);
title('Muscle - Pulse width modulation - recruitment curve', 'FontSize', 20);
hleg = legend;
set(hleg,'FontSize', 15, 'visible', 'on');

figName = "Pulse width modulation - Muscle";
ax = gcf;
exportName = startPath + "/" + figName + ".png";
exportgraphics(ax, exportName, 'Resolution', 400);

exportName = startPath + "/" + figName + ".eps";
exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');

%% section 5 - Plot amp modulation skeleton - spinal
close all
subjectIndex = 1;
groupIndex = 3;
currentSubject = subjectUnique{subjectIndex};
currentGroup = groupUnique{groupIndex};

indexData = and((subjectUniqueIndex(:) == subjectIndex), (groupUniqueIndex(:) == groupIndex));
currentData_Max = dataFull_skeletonMax(indexData, :);
currentData_Min = dataFull_skeletonMin(indexData, :);

currentValueData = dataFull_small(indexData, :);
currentAmp = lookupAmpTable(currentValueData(:, 1), 2);


x = currentAmp;
channelData = currentValueData(1, 3) - 1;
[x, xIndex] = sort(x);
currentData_Max = currentData_Max(xIndex, :);
currentData_Min = currentData_Min(xIndex, :);
currentAmp = currentAmp(xIndex, :);
currentValueData = currentValueData(xIndex, :);

t = tiledlayout('flow', 'Padding', 'loose');
set(gcf, 'Position',  [100, 100, 800, 800])
ax = nexttile;
flipSkeleton = true;

dataExport = table;
skeletonInitial = SkeletonModel(currentData_Min(1, :));
skeletonRow = skeletonInitial.convertDataRow;
rowName = 'ADC';
dataExport.(rowName) = -1;
dataExport = [dataExport, skeletonRow];
plotName =  " Resting position ";
% ax = skeletonInitial.plotPosition(ax, colorLineUnique{5}, plotName, flipSkeleton);
ax = skeletonInitial.plotPositionUpdate(ax, colorPallete=colorLineUnique{5}, ...
                                            plotName=plotName, ...
                                            flipSkeleton=flipSkeleton, ...
                                            LineWidth=3, ...
                                            LineStyle='--', ...
                                            MarkerSize=50);

for indexTable = 1:height(currentData_Max)
    skeletonInitial = SkeletonModel(currentData_Max(indexTable, :));
    plotName =  " ADC = " + num2str(currentValueData(indexTable, 1)) + "";
%     ax = skeletonInitial.plotPosition(ax, colorLine{indexTable}, plotName, flipSkeleton);
    ax = skeletonInitial.plotPositionUpdate(ax, colorPallete=colorLineUnique{1}, ...
                                                plotName=plotName, ...
                                                flipSkeleton=flipSkeleton, ...
                                                LineWidth=3, ...
                                                MarkerSize=50);

    currentRow = table;
    skeletonRow = skeletonInitial.convertDataRow;
    currentRow.(rowName) = currentValueData(indexTable, 1);
    currentRow = [currentRow, skeletonRow];
    dataExport = [dataExport; currentRow];
end

hleg = legend;
set(hleg, 'FontSize', 12, 'visible', 'on', 'Location', 'NorthEast');
axis equal;
xlabel('Horizontal displacement (pixel)', 'FontSize', 12);
ylabel('Vertical displacement (pixel)', 'FontSize', 12);
ylimData = ylim;
ylimData(1) = ylimData(1) - 10;
ylimData(2) = ylimData(2) + 10;
ylim(ylimData);

xlimData = xlim;
xlimData(1) = xlimData(1) - 10;
xlimData(2) = xlimData(2) + 10;
xlim(xlimData)
title(t, "Toe skeleton at maximum position for amp modulation for channel " + num2str(channelData), 'FontSize', 16);

figName = 'Amp modulation skeleton - Spinal';
ax = gcf;
exportName = startPath + "/" + figName + ".tiff";
exportgraphics(ax, exportName, 'Resolution', 1000);

exportName = startPath + "/" + figName + ".eps";
exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');

tableName = startPath + "/" + figName + ".xlsx";
writetable(dataExport, tableName);

%% section 6 - Plot pulse width modulation skeleton - spinal
close all
subjectIndex = 2;
groupIndex = 3;
currentSubject = subjectUnique{subjectIndex};
currentGroup = groupUnique{groupIndex};

indexData = and((subjectUniqueIndex(:) == subjectIndex), (groupUniqueIndex(:) == groupIndex));
currentData_Max = dataFull_skeletonMax(indexData, :);
currentData_Min = dataFull_skeletonMin(indexData, :);

currentValueData = dataFull_small(indexData, :);

x = currentValueData(:, 2);
channelData = currentValueData(1, 3) - 1;
[x, xIndex] = sort(x);
currentData_Max = currentData_Max(xIndex, :);
currentData_Min = currentData_Min(xIndex, :);

t = tiledlayout('flow', 'Padding', 'loose');
set(gcf, 'Position',  [100, 100, 800, 800])
ax = nexttile;
flipSkeleton = true;

dataExport = table;
skeletonInitial = SkeletonModel(currentData_Min(1, :));
skeletonRow = skeletonInitial.convertDataRow;
rowName = 'Pulse width (µs)';
dataExport.(rowName) = -1;
dataExport = [dataExport, skeletonRow];
plotName =  " Resting position ";
% ax = skeletonInitial.plotPosition(ax, colorLineUnique{5}, plotName, flipSkeleton);
ax = skeletonInitial.plotPositionUpdate(ax, colorPallete=colorLineUnique{5}, ...
                                            plotName=plotName, ...
                                            flipSkeleton=flipSkeleton, ...
                                            LineWidth=3, ...
                                            LineStyle='--', ...
                                            MarkerSize=50);

for indexTable = 1:height(currentData_Max)
    skeletonInitial = SkeletonModel(currentData_Max(indexTable, :));
    plotName =  " Pulse width = " + num2str(x(indexTable, 1)) + " µs";
%     ax = skeletonInitial.plotPosition(ax, colorLine{indexTable}, plotName, flipSkeleton);
    ax = skeletonInitial.plotPositionUpdate(ax, colorPallete=colorLine{indexTable}, ...
                                                plotName=plotName, ...
                                                flipSkeleton=flipSkeleton, ...
                                                LineWidth=3, ...
                                                MarkerSize=50);

    currentRow = table;
    skeletonRow = skeletonInitial.convertDataRow;
    currentRow.(rowName) = x(indexTable, 1);
    currentRow = [currentRow, skeletonRow];
    dataExport = [dataExport; currentRow];
end

hleg = legend;
set(hleg, 'FontSize', 12, 'visible', 'on', 'Location', 'NorthEast');
axis equal;
xlabel('Horizontal displacement (pixel)', 'FontSize', 12);
ylabel('Vertical displacement (pixel)', 'FontSize', 12);
set(gca, 'YColor', 'none', 'box','off', 'TickDir', 'out', 'fontweigh', 'bold', 'fontsize', 12);
ylimData = ylim;
ylimData(1) = ylimData(1) - 10;
ylimData(2) = ylimData(2) + 10;
ylim(ylimData);

xlimData = xlim;
xlimData(1) = xlimData(1) - 10;
xlimData(2) = xlimData(2) + 10;
xlim(xlimData)
title(t, "Toe skeleton at maximum position for pulse width modulation for channel " + num2str(channelData), 'FontSize', 16);

figName = 'Pulse width modulation skeleton - Spinal';
ax = gcf;
exportName = startPath + "/" + figName + ".tiff";
exportgraphics(ax, exportName, 'Resolution', 1000);

exportName = startPath + "/" + figName + ".eps";
exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');

tableName = startPath + "/" + figName + ".xlsx";
writetable(dataExport, tableName);

%% section 7 - Plot pulse width modulation skeleton - muscle
close all
subjectIndex = 2;
groupIndex = 1;
currentSubject = subjectUnique{subjectIndex};
currentGroup = groupUnique{groupIndex};

indexData = and((subjectUniqueIndex(:) == subjectIndex), (groupUniqueIndex(:) == groupIndex));
currentData_Max = dataFull_skeletonMax(indexData, :);
currentData_Min = dataFull_skeletonMin(indexData, :);

currentValueData = dataFull_small(indexData, :);

x = currentValueData(:, 2);
channelData = currentValueData(1, 3) - 1;
[x, xIndex] = sort(x);
currentData_Max = currentData_Max(xIndex, :);
currentData_Min = currentData_Min(xIndex, :);

t = tiledlayout('flow', 'Padding', 'loose');
set(gcf, 'Position',  [100, 100, 800, 800])
ax = nexttile;
flipSkeleton = false;

dataExport = table;
skeletonInitial = SkeletonModel(currentData_Min(1, :));
skeletonRow = skeletonInitial.convertDataRow;
rowName = 'Pulse width (µs)';
dataExport.(rowName) = -1;
dataExport = [dataExport, skeletonRow];
plotName =  " Resting position ";
ax = skeletonInitial.plotPositionUpdate(ax, colorPallete=colorLineUnique{5}, ...
                                            plotName=plotName, ...
                                            flipSkeleton=flipSkeleton, ...
                                            LineWidth=3, ...
                                            LineStyle='--', ...
                                            MarkerSize=50);

for indexTable = 1:height(currentData_Max)
    currentRow = table;
    skeletonInitial = SkeletonModel(currentData_Max(indexTable, :));

    plotName =  " Pulse width = " + num2str(x(indexTable, 1)) + " µs";

    ax = skeletonInitial.plotPositionUpdate(ax, colorPallete=colorLine{indexTable}, ...
                                                plotName=plotName, ...
                                                flipSkeleton=flipSkeleton, ...
                                                LineWidth=3, ...
                                                MarkerSize=50);

    currentRow = table;
    skeletonRow = skeletonInitial.convertDataRow;
    currentRow.(rowName) = x(indexTable, 1);
    currentRow = [currentRow, skeletonRow];
    dataExport = [dataExport; currentRow];
end

hleg = legend;
set(hleg, 'FontSize', 12, 'visible', 'on', 'Location', 'NorthEast');
axis equal;
xlabel('Horizontal displacement (pixel)', 'FontSize', 12);
ylabel('Vertical displacement (pixel)', 'FontSize', 12);
ylimData = ylim;
ylimData(1) = ylimData(1) - 10;
ylimData(2) = ylimData(2) + 10;
ylim(ylimData);

xlimData = xlim;
xlimData(1) = xlimData(1) - 10;
xlimData(2) = xlimData(2) + 10;
xlim(xlimData)
title(t, "Toe skeleton at maximum position for pulse width modulation for channel " + num2str(channelData) +  " - Muscle", 'FontSize', 16);

figName = 'Pulse width modulation skeleton - Muscle';
ax = gcf;
exportName = startPath + "/" + figName + ".tiff";
exportgraphics(ax, exportName, 'Resolution', 1000);

exportName = startPath + "/" + figName + ".eps";
exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');

tableName = startPath + "/" + figName + ".xlsx";
writetable(dataExport, tableName);

%% section 8 - Plot amp modulation skeleton - Muscle
close all
subjectIndex = 1;
groupIndex = 1;
currentSubject = subjectUnique{subjectIndex};
currentGroup = groupUnique{groupIndex};
dataFull_small(~any(dataFull_small,2), : ) = [];

channelNumber = 6; % channel 2 or 5, input 3 or 6 

indexData = and((subjectUniqueIndex(:) == subjectIndex), (groupUniqueIndex(:) == groupIndex));
indexData = and(indexData, dataFull_small(:, 3) == channelNumber);
currentData_Max = dataFull_skeletonMax(indexData, :);
currentData_Min = dataFull_skeletonMin(indexData, :);

currentValueData = dataFull_small(indexData, :);
currentAmp = lookupAmpTable(currentValueData(:, 1), 2);

x = currentAmp;
channelData = currentValueData(1, 3) - 1;
[x, xIndex] = sort(x);
currentData_Max = currentData_Max(xIndex, :);
currentData_Min = currentData_Min(xIndex, :);
currentValueData = currentValueData(xIndex, :);

t = tiledlayout('flow', 'Padding', 'loose');
set(gcf, 'Position',  [100, 100, 800, 800])
ax = nexttile;
flipSkeleton = false;

dataExport = table;
skeletonInitial = SkeletonModel(currentData_Min(1, :));
skeletonRow = skeletonInitial.convertDataRow;
rowName = 'ADC';
dataExport.(rowName) = -1;
dataExport = [dataExport, skeletonRow];
plotName =  " Resting position ";
% ax = skeletonInitial.plotPosition(ax, colorLineUnique{5}, plotName, flipSkeleton);
ax = skeletonInitial.plotPositionUpdate(ax, colorPallete='#FF0000', ...
                                            plotName=plotName, ...
                                            flipSkeleton=flipSkeleton, ...
                                            LineWidth=1, ...
                                            MarkerSize=50);

for indexTable = 1:height(currentData_Max)
    skeletonInitial = SkeletonModel(currentData_Max(indexTable, :));
    plotName =  " ADC = " + num2str(currentValueData(indexTable, 1));
%     ax = skeletonInitial.plotPosition(ax, colorLine{indexTable}, plotName);
    ax = skeletonInitial.plotPositionUpdate(ax, colorPallete='#00FFFF', ...
                                                plotName=plotName, ...
                                                flipSkeleton=flipSkeleton, ...
                                                LineWidth=1, ...
                                                MarkerSize=50);

    currentRow = table;
    skeletonRow = skeletonInitial.convertDataRow;
    currentRow.(rowName) = currentValueData(indexTable, 1);
    currentRow = [currentRow, skeletonRow];
    dataExport = [dataExport; currentRow];
end

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

hleg = legend;
set(hleg, 'FontSize', 12, 'visible', 'on', 'Location', 'NorthEast');
axis equal;
xlabel('Horizontal displacement (pixel)', 'FontSize', 12);
ylabel('Vertical displacement (pixel)', 'FontSize', 12);
ylimData = ylim;
ylimData(1) = ylimData(1) - 10;
ylimData(2) = ylimData(2) + 10;
ylim(ylimData);

xlimData = xlim;
xlimData(1) = xlimData(1) - 10;
xlimData(2) = xlimData(2) + 10;
xlim(xlimData)
title(t, "Toe skeleton at maximum position for amp modulation for channel " + num2str(channelData), 'FontSize', 16);

figName = 'Amp modulation skeleton - Muscle';
ax = gcf;
exportName = startPath + "/" + figName + ".tiff";
exportgraphics(ax, exportName, 'Resolution', 1000);

exportName = startPath + "/" + figName + ".eps";
exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');

tableName = startPath + "/" + figName + ".xlsx";
writetable(dataExport, tableName);

%% section 9 - Plot amp modulation - both muscle and spinal
close all
subjectIndex = 1;
groupIndex = 1;
t = tiledlayout('flow', 'Padding', 'loose');
set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 1.96 1.58])
ax1 = nexttile;

dataExport = table;

for groupIndex = 1:2:3
    currentSubject = subjectUnique{subjectIndex};
    currentGroup = groupUnique{groupIndex};

    indexData = and((subjectUniqueIndex(:) == subjectIndex), (groupUniqueIndex(:) == groupIndex));
    currentData = dataFull_small(indexData, :);
%     listChannel = unique(currentData(:, 3));
    listChannel = [2, 6];

    for indexChannel = 1:length(listChannel)
        currentChannel = listChannel(indexChannel);
        currentData_Channel = currentData(currentData(:, 3) == currentChannel, :);
        x = currentData_Channel(:, 1);
        y = currentData_Channel(:, 4)./currentData_Channel(:, 5);
    
        xName = "x " + currentGroup;
        xName_Secondary = "x ADC" + currentGroup; 
        yName = "y " + currentGroup;

        [x, xIndex] = sort(x);
        y = y(xIndex);

        x_secondary = x;
        x = lookupAmpTable(x-1, 2)*1000;

        nameDisplay = string(string(groupUnique{groupIndex}) + " at channel " + num2str(currentChannel - 1));
        % box(ax1);
        h1 = plot(x, y, '-o');
        hold on
        set(h1, 'Color', colorLineUnique{indexChannel}, ...
                'MarkerFaceColor',  colorLineUnique{indexChannel}, ...
                'MarkerEdgeColor', colorLineUnique{indexChannel}, ...
                'MarkerSize', 2, ...
                'LineWidth', 1.5, ...
                'DisplayName', nameDisplay);
    
    end
        
end


ylimData = ylim;
ylimData(1) = 0;
ylimData(2) = 7;
ylim(ylimData);

ax = gca;

ax.YAxis.FontSize = 14;
xlabel('Amplitude (µA)', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial')
ylabel('Toe displacement (pixel)', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');

% Plot the compliance voltage
compVoltage = readtable('Compliance Voltage.xlsx');
for indexComp = 1:3:4
    x = table2array(compVoltage(:, indexComp));
    x = x(~isnan(x));
    y = table2array(compVoltage(:, indexComp + 1));
    y = y(~isnan(y));
    [x, xIndex] = sort(x);
    y = y(xIndex);
    x = lookupAmpTable(x-1, 2)*1000;

    nameDisplay = "compliance voltage";
    yyaxis right
    h1 = plot(x, y, '--o');
    hold on
    set(h1, 'Color', colorLineUnique{indexComp+3}, ...
                'MarkerFaceColor',  colorLineUnique{indexComp+3}, ...
                'MarkerEdgeColor', colorLineUnique{indexComp+3}, ...
                'MarkerSize', 2, ...
                'LineWidth', 1.5, ...
                'DisplayName', nameDisplay);
end

ylimData = ylim;
ylimData(1) = 5;
ylimData(2) = 9;
ylim(ylimData);
ylabel('Compliance Voltage (V)', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');

hleg = legend;
set(hleg, 'FontSize', 10, 'visible', 'on', 'Location', 'southeast', 'FontName', 'Arial');

ax.XAxis.FontSize = 14;

xlimData = xlim;
xlimData(1) = 0;
xlimData(2) = 5000;
xlim(xlimData)

title('Amp modulation - recruitment curve', 'FontSize', 15);
set(gca, 'box','off', 'TickDir', 'out', 'fontweigh', 'bold', 'fontsize', 12);

figName = 'Amp modulation - Both';
ax = gcf;
exportName = startPath + "/" + figName + ".png";
exportgraphics(ax, exportName, 'Resolution', 1000);

exportName = startPath + "/" + figName + ".eps";
exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');

%% section 10 - Plot pulse width modulation - both muscle and spinal
close all
subjectIndex = 2;
groupIndex = 1;
t = tiledlayout('flow', 'Padding', 'loose');
set(gcf, 'Position',  [100, 100, 1800, 900])
ax1 = nexttile;

dataExport = table;

for groupIndex = 1:2:3
    currentSubject = subjectUnique{subjectIndex};
    currentGroup = groupUnique{groupIndex};

    indexData = and((subjectUniqueIndex(:) == subjectIndex), (groupUniqueIndex(:) == groupIndex));
    currentData = dataFull_small(indexData, :);
    listChannel = unique(currentData(:, 3));

    for indexChannel = 1:length(listChannel)
        currentChannel = listChannel(indexChannel);
        currentData_Channel = currentData(currentData(:, 3) == currentChannel, :);
        x = currentData_Channel(:, 2);
        y = currentData_Channel(:, 4);
        
        xName = "x " + currentGroup + " (µs)";
        yName = "y " + currentGroup;

        [x, xIndex] = sort(x);
        y = y(xIndex);

        nameDisplay = string(subjectUnique{subjectIndex}) + " of " + string(groupUnique{groupIndex} + " at channel " + num2str(currentChannel - 1));
        h1 = plot(x, y, '-o');
        hold on
        set(h1, 'Color', colorLineUnique{groupIndex}, ...
                'MarkerFaceColor',  colorLineUnique{groupIndex}, ...
                'MarkerEdgeColor', colorLineUnique{groupIndex}, ...
                'MarkerSize', 8, ...
                'LineWidth', 4, ...
                'DisplayName', nameDisplay);
    end
        
end
hleg = legend;
set(hleg, 'FontSize', 14, 'visible', 'on', 'Location', 'SouthEast');

ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;

xlabel('Pulse width (µs)', 'FontSize', 14)
ylabel('Toe displacement (pixel)', 'FontSize', 14);
ylimData = ylim;
ylimData(1) = 0;
ylimData(2) = ylimData(2) + 20;
ylim(ylimData);

xlimData = xlim;
xlimData(1) = 0;
xlimData(2) = xlimData(2) + 20;
xlim(xlimData)

title('Pulse width modulation - recruitment curve', 'FontSize', 17);
figName = 'Pulse width modulation - Both';
ax = gcf;
exportName = startPath + "/" + figName + ".png";
exportgraphics(ax, exportName, 'Resolution', 1000);

exportName = startPath + "/" + figName + ".eps";
exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none', 'Resolution', 1000);

tableName = startPath + "/" + figName + ".xlsx";
writetable(dataExport, tableName);

%% section 11 - Plot pulse width modulation - Muscle flat
close all
subjectIndex = 2;
groupIndex = 2;
currentSubject = subjectUnique{subjectIndex};
currentGroup = groupUnique{groupIndex};

indexData = and((subjectUniqueIndex(:) == subjectIndex), (groupUniqueIndex(:) == groupIndex));
currentData = dataFull_small(indexData, :);

listChannel = unique(currentData(:, 3));

t = tiledlayout('flow', 'Padding', 'loose');
ax = nexttile;
hold on
set(gcf, 'Position',  [100, 100, 1300, 600])

dataExport = table;

for indexChannel = 1:length(listChannel)
    currentChannel = listChannel(indexChannel);

    axList(currentChannel, 1) = ax;
    currentChannelData = currentData(currentData(:, 3) == currentChannel, :);
    currentIntensity = lookupAmpTable(currentChannelData(1, 1), 2)*1000;

    x = currentChannelData(:, 2);
    y = currentChannelData(:, 4);

    xName = "x channel " + num2str(currentChannel - 1);
    yName = "y channel " + num2str(currentChannel - 1);

    [x, xIndex] = sort(x);
    y = y(xIndex);

    dataExport.(xName)(1:length(x)) = x;
    dataExport.(yName)(1:length(y)) = y;

    ax1 = plot(x, y, '-o');
    set(ax1(1), 'Color', colorLineUnique{indexChannel}, ...
                        'MarkerFaceColor', colorLineUnique{indexChannel}, ...
                        'MarkerEdgeColor', colorLineUnique{indexChannel}, ...
                        'MarkerSize', 6, ...
                        'LineWidth', 2);
    ylimData = ylim;
    ylimData(1) = 0;
    ylimData(2) = ylimData(2) + 20;
    ylim(ylimData);

    xlimData = xlim;
    xlimData(1) = 0;
    xlimData(2) = xlimData(2) + 1;
    xlim(xlimData)

    ax1(1).DisplayName = "Intensity = " + num2str(currentIntensity) + " µA of channel " + num2str(currentChannel - 1);
end
xlabel('Pulse width (µs)', 'FontSize', 15);
ylabel('Toe displacement (pixel)', 'FontSize', 15);
title('Muscle - Pulse width modulation - recruitment curve', 'FontSize', 20);
hleg = legend;
set(hleg,'FontSize', 15, 'visible', 'on');

figName = "Pulse width modulation - Muscle flat";
ax = gcf;
exportName = startPath + "/" + figName + ".png";
exportgraphics(ax, exportName, 'Resolution', 400);

exportName = startPath + "/" + figName + ".eps";
exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none', 'Resolution', 1000);

tableName = startPath + "/" + figName + ".xlsx";
writetable(dataExport, tableName);

%% section 12 - Plot amp modulation spinal multiple channel
close all
subjectIndex = 1;
groupIndex = 3;
currentSubject = subjectUnique{subjectIndex};
currentGroup = groupUnique{groupIndex};

indexData = and((subjectUniqueIndex(:) == subjectIndex), (groupUniqueIndex(:) == groupIndex));
currentData = dataFull_small(indexData, :);

listChannel = unique(currentData(:, 3));

t = tiledlayout('flow', 'Padding', 'loose');
ax = nexttile;
hold on
% set(gcf, 'Position',  [100, 100, 600, 600])
set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 1.96 1.58]);
channelSupplementData = [8; 15; 3; 3; 3];

for indexChannel = 1:length(listChannel)
    currentChannel = listChannel(indexChannel);
    currentData_Channel = currentData(currentData(:, 3) == currentChannel, :);
    currentPW = currentData_Channel(1, 2);
    x = currentData_Channel(:, 1);

    currentAmp = lookupAmpTable(x, 2);
    x = currentAmp * 1000;
    y = currentData_Channel(:, 4)./currentData_Channel(:, 5);

    [x, xIndex] = sort(x);
    y = y(xIndex);

    x0 = lookupAmpTable(channelSupplementData(indexChannel), 2)*1000;
    y0 = 0;

    x = [x0; x];
    y = [y0; y];
    
    ax1 = plot(x, y, '-o');
    set(ax1(1), 'Color', colorLineUnique{indexChannel}, ...
                        'MarkerFaceColor', colorLineUnique{indexChannel}, ...
                        'MarkerEdgeColor', colorLineUnique{indexChannel}, ...
                        'MarkerSize', 3, ...
                        'LineWidth', 1.5);

    ax1(1).DisplayName = "PW = " + num2str(currentPW) + " µs of channel " + num2str(currentChannel - 1);
    annotationChannel = annotation('textbox', 'String', "Channel " + num2str(currentChannel - 1), ...
                                            'LineWidth', 1.5, ...
                                            'FontSize', 12, ...
                                            'FitBoxToText', 'on', ...
                                            'Margin', 5, ...
                                            'HorizontalAlignment', 'center', ...
                                            'EdgeColor', 'none');
    annotationChannel.Parent = ax;
    x_point = x(end) - 120;
    w = 220;
    y_point = y(end) + 0.09;
    h = 0.3;
    annotationChannel.Position = [x_point y_point w h];

end
xlabel('Amplitude (µA)', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');
ylabel('Toe displacement (cm)', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');
title('Spinal - Amp modulation - recruitment curve', 'FontSize', 15, 'fontweight', 'bold', 'FontName', 'Arial');
hleg = legend;
set(hleg,'FontSize', 10, 'visible', 'off', 'Location', 'southeast');
set(gca, 'TickDir', 'out', 'fontweigh', 'bold', 'fontsize', 10);

figName = "Amp modulation - Spinal - New";
ax = gcf;
exportName = startPath + "/" + figName + ".png";
exportgraphics(ax, exportName, 'Resolution', 1000);

exportName = startPath + "/" + figName + ".eps";
exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none', 'Resolution', 1000);

%% section 13 - Plot amp modulation muscle multiple channel
close all
subjectIndex = 1;
groupIndex = 1;
currentSubject = subjectUnique{subjectIndex};
currentGroup = groupUnique{groupIndex};

indexData = and((subjectUniqueIndex(:) == subjectIndex), (groupUniqueIndex(:) == groupIndex));
currentData = dataFull_small(indexData, :);

listChannel = unique(currentData(:, 3));

t = tiledlayout('flow', 'Padding', 'loose');
ax = nexttile;
hold on
% set(gcf, 'Position',  [100, 100, 600, 600])
set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 1.96 1.58]);
channelSupplementData = [50; 50];
for indexChannel = 1:length(listChannel)
    currentChannel = listChannel(indexChannel);
    currentData_Channel = currentData(currentData(:, 3) == currentChannel, :);
    currentPW = currentData_Channel(1, 2);
    x = currentData_Channel(:, 1);

    currentAmp = lookupAmpTable(x, 2);
    x = currentAmp * 1000;
    y = currentData_Channel(:, 4)./currentData_Channel(:, 5);

    x0 = lookupAmpTable(channelSupplementData(indexChannel), 2)*1000;
    y0 = 0;

    x = [x0; x];
    y = [y0; y];

    [x, xIndex] = sort(x);
    y = y(xIndex);
    ax1 = plot(x, y, '-o');
    set(ax1(1), 'Color', colorLineUnique{indexChannel}, ...
                        'MarkerFaceColor', colorLineUnique{indexChannel}, ...
                        'MarkerEdgeColor', colorLineUnique{indexChannel}, ...
                        'MarkerSize', 3, ...
                        'LineWidth', 1.5);

    ax1(1).DisplayName = "PW = " + num2str(currentPW) + " µs of channel " + num2str(currentChannel - 1);
    annotationChannel = annotation('textbox', 'String', "Channel " + num2str(currentChannel - 1), ...
                                            'LineWidth', 1.5, ...
                                            'FontSize', 12, ...
                                            'FitBoxToText', 'on', ...
                                            'Margin', 5, ...
                                            'HorizontalAlignment', 'center', ...
                                            'EdgeColor', 'none');
    annotationChannel.Parent = ax;
    x_point = x(end) - 120;
    w = 650;
    y_point = y(end) + 0.12;
    h = 0.1;
    annotationChannel.Position = [x_point y_point w h];

end

ylimData = ylim;
ylimData(1) = 0;
ylimData(2) = 7;
ylim(ylimData);

xlimData = xlim;
xlimData(2) = xlimData(2) + 200;
xlim(xlimData)

xlabel('Amplitude (µA)', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');
ylabel('Toe displacement (cm)', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');
title('Muscle - Amp modulation - recruitment curve', 'FontSize', 15, 'fontweight', 'bold', 'FontName', 'Arial');
hleg = legend;
set(hleg,'FontSize', 10, 'visible', 'off', 'Location', 'southeast');

set(gca, 'TickDir', 'out', 'fontweigh', 'bold', 'fontsize', 10);

figName = "Amp modulation - Muscle - New";
ax = gcf;
exportName = startPath + "/" + figName + ".png";
exportgraphics(ax, exportName, 'Resolution', 1000);

exportName = startPath + "/" + figName + ".eps";
exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor', 'none');

%% section 14 - Plot PW modulation spinal multiple channel
close all
subjectIndex = 2;
groupIndex = 3;
currentSubject = subjectUnique{subjectIndex};
currentGroup = groupUnique{groupIndex};

indexData = and((subjectUniqueIndex(:) == subjectIndex), (groupUniqueIndex(:) == groupIndex));
currentData = dataFull_small(indexData, :);

listChannel = unique(currentData(:, 3));

t = tiledlayout('flow', 'Padding', 'loose');
ax = nexttile;
hold on
% set(gcf, 'Position',  [100, 100, 600, 600])
set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 1.96 1.58]);
channelSupplementData = [8; 15; 3; 3; 3];

for indexChannel = 1:length(listChannel)
    currentChannel = listChannel(indexChannel);
    currentData_Channel = currentData(currentData(:, 3) == currentChannel, :);
    currentPW = currentData_Channel(1, 2);
    x = currentData_Channel(:, 2)+ 170;
    xlim([170 320])
    y = currentData_Channel(:, 4)./currentData_Channel(:, 5);

    [x, xIndex] = sort(x);
    y = y(xIndex);
    
    ax1 = plot(x, y, '-o');
    set(ax1(1), 'Color', colorLineUnique{indexChannel}, ...
                        'MarkerFaceColor', colorLineUnique{indexChannel}, ...
                        'MarkerEdgeColor', colorLineUnique{indexChannel}, ...
                        'MarkerSize', 3, ...
                        'LineWidth', 1.5);

    ax1(1).DisplayName = "PW = " + num2str(currentPW) + " µs of channel " + num2str(currentChannel - 1);

end
ylimData = ylim;
ylimData(1) = 0;
ylimData(2) = 7;
ylim(ylimData);

xlimData = xlim;
xlimData(1) = 170;
xlimData(2) = xlimData(2) + 20;
xticks([xlimData(1):20:xlimData(2)]);
xlim(xlimData)


xlabel('Pulse width (µs)', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');
ylabel('Toe displacement (cm)', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');
title('Spinal - Amp modulation - recruitment curve', 'FontSize', 15, 'fontweight', 'bold', 'FontName', 'Arial');
hleg = legend;
set(hleg,'FontSize', 10, 'visible', 'off', 'Location', 'southeast');
set(gca, 'TickDir', 'out', 'fontweigh', 'bold', 'fontsize', 10);

figName = "PW modulation - Spinal - New";
ax = gcf;
exportName = startPath + "/" + figName + ".png";
exportgraphics(ax, exportName, 'Resolution', 1000);

exportName = startPath + "/" + figName + ".eps";
exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none', 'Resolution', 1000);