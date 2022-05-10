clear all
close all

colorLineUnique = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#A2142F', ...
             '#4DBEEE', '#77AC30', '#40E0D0', '#6495ED', '#88A096', ...
             '#F8D210', '#94d2bd'};

% startPath = 'C:\Users\Zhong\OneDrive - Northwestern University\Wireless Interface Kinematics';
startPath = '/Users/sam/Library/CloudStorage/OneDrive-NorthwesternUniversity/Documents/Wireless Interface Kinematics';
load lookupAmpTable.mat
%% section1 - Survival plot
close all
data = readtable('Survival Plot.xlsx');
steriMethodList= unique(data.('Sterilization'));
t = tiledlayout('flow', 'Padding', 'loose');
set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 1.96 1.58])
ax1 = nexttile;

for indexMethod = 1:length(steriMethodList)
    steriMethod = steriMethodList{indexMethod};
    dataDays = table2array(data(strcmp(data.('Sterilization'), steriMethod), 'Days'));
    dataDays = [0; sort(dataDays)];
    dataEffect = ones(length(dataDays), 1);
    dataSurvival = cumsum(dataEffect, 'reverse') - 1;

    nameDisplay = string(steriMethod);
    h1 = plot(dataDays, dataSurvival, '-o');
    hold on
    set(h1, 'Color', colorLineUnique{indexMethod}, ...
                'MarkerFaceColor',  colorLineUnique{indexMethod}, ...
                'MarkerEdgeColor', colorLineUnique{indexMethod}, ...
                'MarkerSize', 5, ...
                'LineWidth', 1.5, ...
                'DisplayName', nameDisplay);
end

xlabel('Days', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');
ylabel('Surviving device counts', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');

hleg = legend;
set(hleg, 'FontSize', 10, 'visible', 'on', 'Location', 'northeast', 'FontName', 'Arial');

title('Device survival curve', 'FontSize', 15);
set(gca, 'box','off', 'TickDir', 'out', 'fontweigh', 'bold', 'fontsize', 12, 'FontName', 'Arial');

figName = 'Device survival curve';
ax = gcf;
exportName = startPath + "/" + figName + ".png";
exportgraphics(ax, exportName, 'Resolution', 1000);

exportName = startPath + "/" + figName + ".eps";
exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');

%% section 2 - Survival histogram
close all
data = readtable('Survival Plot.xlsx');
steriMethodList= unique(data.('Sterilization'));
t = tiledlayout('flow', 'Padding', 'loose');
set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 1.96 1.58])
ax1 = nexttile;
numberOfBins = 7; % change here to change the histogram bins count

dataDays = table2array(data(:, 'Days'));
edges = [0:10:60];
histogram(dataDays, edges)

ylimData = ylim;
ylimData(2) = ylimData(2) + 1;
ylim(ylimData);

xticks(edges);

xlabel('Days', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');
ylabel('Surviving device counts', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');


title('Device survival histogram', 'FontSize', 15);
set(gca, 'box','off', 'TickDir', 'out', 'fontweigh', 'bold', 'fontsize', 12, 'FontName', 'Arial');

figName = 'Device survival histogram';
ax = gcf;
exportName = startPath + "/" + figName + ".png";
exportgraphics(ax, exportName, 'Resolution', 1000);

exportName = startPath + "/" + figName + ".eps";
exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');

%% section 3 - Recruitment threshold - By Channel
close all
converseData = @converseADC;
figure
t = tiledlayout('flow', 'Padding', 'loose');
set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 1.96 1.58])

dayList = [1:6];
opts = detectImportOptions('Recruitment Threshold.xlsx');
opts.DataRange = 'A1';
opts.VariableNamesRange = '';
data = readtable('Recruitment Threshold.xlsx', opts);
dataName = fillmissing(data.('Rat1'), 'previous');
data(:, 'Rat1') = dataName;
nameList = unique(dataName);

dataChannel = data.('Channel');
dataChannel = dataChannel(~isnan(dataChannel));
dataChannel = unique(dataChannel);

for indexChannel = 1:length(dataChannel)
    ax1 = nexttile;
    currentChannel = dataChannel(indexChannel);
    currentChannelData = data(data.('Channel') == currentChannel, :);
    ratList = currentChannelData.('Rat1');
    for indexRat = 1:length(ratList)
        currentRat = ratList{indexRat};
        currentRat_Data = table2array(currentChannelData(strcmp(currentChannelData.('Rat1'), currentRat), 3:8));
        currentRat_DataCheck = isnan(currentRat_Data);

        currentRat_Data = currentRat_Data(~currentRat_DataCheck);
        currentDayList = dayList(~currentRat_DataCheck);

        currentRat_Data = converseData(currentRat_Data);
        nameDisplay = string(currentRat); 
        h1 = plot(currentDayList, currentRat_Data, '-o');
        hold on
        indexRatColor = find(strcmp(nameList, currentRat), 1);
        set(h1, 'Color', colorLineUnique{indexRatColor}, ...
                'MarkerFaceColor',  colorLineUnique{indexRatColor}, ...
                'MarkerEdgeColor', colorLineUnique{indexRatColor}, ...
                'MarkerSize', 5, ...
                'LineWidth', 1.5, ...
                'DisplayName', nameDisplay);
    end
    
    ylimData = ylim;
    ylimData(1) = 0;
    ylimData(2) = 1.6;
    ylim(ylimData);

    titleString = "Channel " + num2str(currentChannel);
    xlabel('Weeks', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');
    ylabel('Current (mA)', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');

    hleg = legend;
    set(hleg, 'FontSize', 10, 'visible', 'on', 'Location', 'northeast', 'FontName', 'Arial');

    title(titleString, 'FontSize', 15);
    set(gca, 'box','off', 'TickDir', 'out', 'fontweigh', 'bold', 'fontsize', 12, 'FontName', 'Arial');
end

figName = 'Recruitment Threshold';
ax = gcf;
exportName = startPath + "/" + figName + ".png";
exportgraphics(ax, exportName, 'Resolution', 1000);

exportName = startPath + "/" + figName + ".eps";
exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');


%% section 4 - Recruitment threshold - By Rats
close all
converseData = @converseADC;


opts = detectImportOptions('Recruitment Threshold.xlsx');
opts.DataRange = 'A1';
opts.VariableNamesRange = '';
data = readtable('Recruitment Threshold.xlsx', opts);
dataName = fillmissing(data.('Rat1'), 'previous');
data(:, 'Rat1') = dataName;
nameList = unique(dataName);

dataChannel = data.('Channel');
dataChannel = dataChannel(~isnan(dataChannel));
dataChannel = unique(dataChannel);

convertList = [0, 0, 1];
limitWeek = [8, 6, 8];
ylimList = [0.05, 0.1, 0.5];

for indexRat = 1:length(nameList)
    close all
    
    t = tiledlayout('flow', 'Padding', 'loose');
    set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 1.96 1.58])
    ax1 = nexttile;

    currentRat = nameList{indexRat};
    convertValue = convertList(indexRat);
    currentYLimOffset = ylimList(indexRat);

    currentWeekLimit = limitWeek(indexRat);
    weekList = [1:currentWeekLimit-2];
    weekName = cell(length(weekList), 1);
    for indexWeek = 1:length(weekList)
        weekName{indexWeek} = char("Week " + num2str(weekList(indexWeek)));
    end

    currentRatData = data(strcmp(data.('Rat1'), currentRat), :);
    
    dataChannel = currentRatData.('Channel');
    dataChannel = dataChannel(~isnan(dataChannel));
    dataChannel = unique(dataChannel);

    dataToPlot = zeros(length(dataChannel), length(weekList));
    nameChannel = cell(length(dataChannel), 1);
    for indexChannel = 1:length(dataChannel)
        currentChannel = dataChannel(indexChannel);
        nameChannel{indexChannel} = char("Channel " + string(currentChannel));
        currentRatData_Channel = table2array(currentRatData(currentRatData.('Channel')==currentChannel, 3:currentWeekLimit));
        currentRat_DataCheck = isnan(currentRatData_Channel);

        currentRatData_Channel(currentRat_DataCheck) = 0;
        
        currentRatData_Channel = converseData(currentRatData_Channel, convertValue, lookupAmpTable);

        dataToPlot(indexChannel, 1:length(currentRatData_Channel)) = currentRatData_Channel;

    end

    x = categorical(nameChannel);
    h1 = bar(x, dataToPlot);
    
    ylimData = ylim;
    ylimData(2) = ylimData(2) + currentYLimOffset;
    ylim(ylimData);

    titleString = string(currentRat);
    xlabel('Channels', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');
    ylabel('Current (mA)', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');

    title(titleString, 'FontSize', 15);
    set(gca, 'box','off', 'TickDir', 'out', 'fontweigh', 'bold', 'fontsize', 12, 'FontName', 'Arial');

    leg = legend(weekName, 'Orientation', 'Horizontal');
    set(leg, 'FontSize', 10, 'FontName', 'Arial');
    leg.Layout.Tile = 'north';
    figName = "Recruitment Threshold of " + string(currentRat);
    ax = gcf;
    exportName = startPath + "/" + figName + ".png";
    exportgraphics(ax, exportName, 'Resolution', 1000);
    
    exportName = startPath + "/" + figName + ".eps";
    exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');
end



%% section 5 - X-ray
close all
weekList = [1, 2, 4];
weekName = ["One Week", "Two Week", "One Month"];
opts = detectImportOptions('X-ray Measurements.xlsx');
opts.DataRange = 'A1';
opts.VariableNamesRange = '';
data = readtable('X-ray Measurements.xlsx', opts);
dataType = data.('Var2');
dataType = dataType(~cellfun('isempty', dataType));
dataType = unique(dataType);
dataName = fillmissing(data.('Var1'), 'previous');
data(:, 'Var1') = dataName;

ylimList = [0.25, 0.5];
yNameList = ["Distance (cm)", "Angle (degree)"];

for indexType = 1:length(dataType)
    close all
    
    t = tiledlayout('flow', 'Padding', 'loose');
    set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 1.96 1.58])
    ax1 = nexttile;
    currentYLimOffset = ylimList(indexType);
    yName = yNameList(indexType);

    currentType = dataType{indexType};
    currentData_Type = data(strcmp(data.('Var2'), currentType), :);
    listRat = unique(currentData_Type.('Var1'));
    
    dataToPlot = zeros(length(listRat), length(weekList));

    for indexRat = 1:length(listRat)
        currentRat = listRat{indexRat};
        currentData_TypeRat = table2array(currentData_Type(strcmp(currentData_Type.('Var1'), currentRat), 3:5));
        currentRat_DataCheck = isnan(currentData_TypeRat);

        currentData_TypeRat(currentRat_DataCheck) = 0;
        
        dataToPlot(indexRat, :) = currentData_TypeRat;
    end
    x = categorical(listRat);
    h1 = bar(x, dataToPlot);

    ylimData = ylim;
    ylimData(2) = ylimData(2) + currentYLimOffset;
    ylim(ylimData);
    
    titleString = string(currentType);
    xlabel('Rat name', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');
    ylabel(yName, 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');

    title(titleString, 'FontSize', 15);
    set(gca, 'box','off', 'TickDir', 'out', 'fontweigh', 'bold', 'fontsize', 12, 'FontName', 'Arial');

    leg = legend(weekName, 'Orientation', 'Horizontal');
    set(leg, 'FontSize', 10, 'FontName', 'Arial');
    leg.Layout.Tile = 'north';
    figName = "X-Ray of " + string(titleString);
    ax = gcf;
    exportName = startPath + "/" + figName + ".png";
    exportgraphics(ax, exportName, 'Resolution', 1000);
    
    exportName = startPath + "/" + figName + ".eps";
    exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');
end

function y = converseADC(x, z, lookupAmpTable)
    if z == 0
        y = 0.0127.*x + 0.0069;
    elseif z == 1
        y = lookupAmpTable(x-1, 2);
    end
end


