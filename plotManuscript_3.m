load dataFull_Displacement_1.mat
startPath = '/Users/sam/Library/CloudStorage/OneDrive-NorthwesternUniversity/Documents/Wireless Interface Kinematics';
targetTypeNames = {'single pulse'; 'tetanic'};
targetTypeVariables = {'SAM', 'TAM'};

dataFull_small = dataFull.SAM.data;
dataFull_name = dataFull.SAM.name;

dataDate = dataFull_small(:, end);
dataFull_name(dataDate == 0) = [];
dataDate(dataDate == 0) = [];

powerUnique = unique(dataFull_small(:, 1));
channelMax = max(dataFull_small(:, 2));
subjectUnique = unique(dataFull_name);

% figure
uniqueDate_length = 1;
dataSummary = zeros(uniqueDate_length, 5);

dataPlotAndExport = false;

for indexSubject = 1:length(subjectUnique)
    currentSubject = subjectUnique{indexSubject};
    currentSubjectDataIndex = find(ismember(dataFull_name, currentSubject));
    currentSubjectData = dataFull_small(currentSubjectDataIndex, :);
    for indexChannel = 1:channelMax
        currentChannelData = currentSubjectData(currentSubjectData(:, 2) == indexChannel, :);

        if size(currentChannelData, 1) == 0
            continue
        end

        listDate = unique(currentChannelData(:, 4));
        for indexDate = 1:length(listDate)
            currentDate = listDate(indexDate);
            currentDateChannelData = currentChannelData(currentChannelData(:, 4) == currentDate, :);

            currentIntensityList = currentDateChannelData(:, 1);
            thresholdIntensity = min(currentIntensityList);
            currentIntensityNorm = currentIntensityList/thresholdIntensity;

            % indexingList = and(currentSubjectData(:, 2) == indexChannel, currentChannelData(:, 4) == currentDate);
            currentChannelData(currentChannelData(:, 4) == currentDate, 5) =  currentIntensityNorm;
        end

        currentSubjectData(currentSubjectData(:, 2) == indexChannel, 5) = currentChannelData(:, 5);
    end
    dataFull_small(currentSubjectDataIndex, 5) = currentSubjectData(:, 5);
end
dataIntensityMulti = dataFull_small(:, 5);
dataIntensityMulti(dataIntensityMulti == 0) = [];
% currentSubjectData(:, 4) = currentSubjectData(:, 4) - min(currentSubjectData(:, 4));
% dataFull_small = currentSubjectData;
%% Plot change in threshold as baseline from 1st date intensity multiplier
close all

indexSubject = 4;
for indexSubject = 4:4%length(subjectUnique)
    currentSubject = subjectUnique{indexSubject};
    currentSubjectDataIndex = find(ismember(dataFull_name, currentSubject));
    currentSubjectData = dataFull_small(currentSubjectDataIndex, :);

    t = tiledlayout('flow', 'Padding', 'loose');
    
    colorLine = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#A2142F', '#4DBEEE', '#77AC30', '#40E0D0', '#6495ED'};
    listChannel = unique(currentSubjectData(:, 2));
    
    for indexChannel = 1:length(listChannel)
        nexttile
        currentChannel = listChannel(indexChannel);
        currentChannelData = currentSubjectData(currentSubjectData(:, 2) == currentChannel, :);
        if isempty(currentChannelData)
            continue
        end
    
        currentChannelData_ThresholdIndex = and(currentChannelData(:, 5) == 1, currentChannelData(:, 4) == 1);
        currentChannel_BaseIntensity = unique(currentChannelData(currentChannelData_ThresholdIndex, 1));
    
        currentChannelData(:, 6) = currentChannelData(:, 1)/currentChannel_BaseIntensity;
        currentChannelData = currentChannelData(currentChannelData(:, 5) == 1, :);
        combinedData = [currentChannelData(:, 4), currentChannelData(:, 6)];
        combinedDataUnique = unique(combinedData, 'rows');
        x = combinedDataUnique(:, 1);
        y = combinedDataUnique(:, 2);
        [f, gof] = fit(x, y, 'poly1');
        ax1 = plot(x, y, '-o');
        hold on
        set([ax1(1)], 'Color', colorLine{currentChannel}, ...
                             'MarkerFaceColor', colorLine{currentChannel}, ...
                             'MarkerEdgeColor', colorLine{currentChannel}, ...
                             'MarkerSize', 5, ...
                             'LineWidth', 1);
%         ax1(1).DisplayName = "Channel " + num2str(currentChannel - 1);
        ylimData = ylim;
        ylimData(1) = 0;
        ylimData(2) = ylimData(2) + 0.3;
        ylim(ylimData);
        ylabel('Multiples of threshold', 'FontSize', 10);
        
        xlimData = xlim;
        xlimData(1) = 0;
        xlimData(2) = xlimData(2);
        xlim(xlimData)
        xlabel('Days', 'FontSize', 10)
        title("Channel " + num2str(currentChannel - 1));
    end

%     hleg = legend;
% 
%     set(hleg,'Location', 'bestoutside','FontSize', 10, 'visible', 'on');

    title(t, "Threshold changes compared against first day value - " + currentSubject + " data", 'FontSize', 15);
    
    figName = "Threshold comparison - " + currentSubject + " data";
    ax = gcf;
    exportName = startPath + "/" + figName + ".png";
    exportgraphics(ax, exportName, 'Resolution', 1000); 
end


%%
t = tiledlayout(1,1,'Padding','tight');
t.Units = 'inches';
t.OuterPosition = [0 0 10 10];
t.InnerPosition = [1 1 4 3];
nexttile
listMultiplier = [1:4];
colorLine = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E'}; 
for indexMult = 1:length(listMultiplier)
    multiplier = listMultiplier(indexMult);
    dataFull_threshold = dataFull_small(dataFull_small(:, 5) == multiplier, :);
    dataFull_thresholdFit = [dataFull_threshold(:, 1), dataFull_threshold(:, 4)];
    [f, gof, output] = fit(dataFull_thresholdFit(:, 2), dataFull_thresholdFit(:, 1), 'poly1');

    ax1 = plot(f, dataFull_thresholdFit(:, 2), dataFull_thresholdFit(:, 1));
    hold on
    set([ax1(1) ax1(2)], 'Color', colorLine{indexMult}, ...
                         'MarkerFaceColor', colorLine{indexMult}, ...
                         'MarkerEdgeColor', colorLine{indexMult}, ...
                         'MarkerSize', 15, ...
                         'LineWidth', 1);
    ax1(1).DisplayName = "Intensity values of " + num2str(indexMult) + " time(s) base intensity";
    ax1(2).DisplayName = "Fitted line with rmse = " + num2str(gof.rmse);
    disp(gof)
end
ylimData = ylim;
ylimData(1) = 0;
ylimData(2) = ylimData(2) + 5;
ylim(ylimData);

xlimData = xlim;
xlimData(1) = 0;
xlimData(2) = xlimData(2) + 1;
xlim(xlimData)

xlabel('Days after intial data')
ylabel('Intensity level')

[hleg, hobj] = legend;
set(hleg,'Location', 'bestoutside','FontSize',7);
title('Intensity multiplier' );

figName = "Intensity multiplier";
ax = gcf;
exportName = startPath + "/" + figName + ".png";
exportgraphics(ax, exportName, 'Resolution', 400);

%% Plot toe displacement
close all
colorLine = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#A2142F', '#4DBEEE', '#77AC30', '#40E0D0', '#6495ED'};
% select subject
indexSubject = 4;
valueResolution = 30;
for indexSubject = 4:4 %length(subjectUnique)
    currentSubject = subjectUnique{indexSubject};
    currentSubjectDataIndex = find(ismember(dataFull_name, currentSubject));
    currentSubjectData = dataFull_small(currentSubjectDataIndex, :);
    
    uniqueDate = unique(currentSubjectData(currentSubjectData(:, 4), 1));
    if size(uniqueDate, 1) < 3
        continue
    end

    numRow = 2;
    listChannel = unique(currentSubjectData(:, 2));
    numChannel = round(length(listChannel)/(numRow));
    h = gobjects(length(numChannel), 1); 
%     t = tiledlayout(numRow, numChannel, 'Padding', 'loose');
    t = tiledlayout('flow', 'Padding', 'loose');
    
%   listChannel = [1:8];
    listDate = unique(currentSubjectData(:, 4));
    axList = zeros(length(numChannel), 1);
    xlimDataMax = [0, 0];
    for indexChannel = 2:length(listChannel)
        currentChannel = listChannel(indexChannel);
        ax = nexttile;
        axList(currentChannel, 1) = ax;
        currentChannelData = currentSubjectData(currentSubjectData(:, 2) == currentChannel, :);
        
        for indexDate = 1:length(listDate)
            currentDate = listDate(indexDate);
            currentDateChannelData = currentChannelData(currentChannelData(:, 4) == currentDate, :);
            dataChannelCount = size(currentDateChannelData, 1);

            if dataChannelCount < 3
               xRaw = zeros(3, 1);
               yRaw = zeros(3, 1);
               hideAx = true;
            else
                xRaw = currentDateChannelData(:, 5);
                yRaw = currentDateChannelData(:, 3);
                hideAx = false;
            end
           x = unique(xRaw);
           y = zeros(length(x), 1);
           for xIndex = 1:length(x)
               currentY = yRaw(xRaw==x(xIndex));
               y(xIndex) = max(currentY);
           end

            [x, xIndex] = sort(x);
            y = y(xIndex)/valueResolution;

            [f, gof] = fit(x, y, 'poly2');
            ax1 = plot(x, y, '-o');
            hold on
            set([ax1(1)], 'Color', colorLine{indexDate}, ...
                                 'MarkerFaceColor', colorLine{indexDate}, ...
                                 'MarkerEdgeColor', colorLine{indexDate}, ...
                                 'MarkerSize', 5, ...
                                 'LineWidth', 1);
            ax1(1).DisplayName = "Day " + num2str(currentDate);
%             ax1(2).DisplayName = "Fitted line";
            if hideAx && (indexDate ~= length(listDate))
                set(ax1, 'visible', 'off')
            end
        end
        disp(gof)
        ylimData = ylim;
        ylimData(1) = 0;
        ylimData(2) = ylimData(2);
        ylim(ylimData);
        
        xlimData = xlim;
        xlimData(1) = 0;
        xlimData(2) = xlimData(2);
        xlim(xlimData)
        %     xticks([xlimData(1):2:xlimData(2)]);
        
        xlabel('Base intensity multiplier', 'FontSize', 10)
        ylabel('Toe displacement (cm)', 'FontSize', 10)
        title("Channel " + num2str(currentChannel - 1), 'FontSize', 12);
%         h(indexDate, 1) = legend;
%         set(hleg,'Location', 'bestoutside','FontSize', 10, 'visible', 'on');
        legend("hide");
    end

    hleg = legend;
    set(hleg, 'FontSize', 10, 'visible', 'on');
    hleg.Layout.Tile = 'east';
    linkaxes(axList,'y')
    title(t, "Toe displacement, for each channel, by dates, from " +  currentSubject, 'FontSize', 15);
    figName = currentSubject + " toe displacement";
    ax = gcf;
    exportName = startPath + "/" + figName + ".png";
    exportgraphics(ax, exportName, 'Resolution', 1000);
end

%% Plot recruitment curve - Day 22 - Channel 7
close all
colorLine = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#A2142F', '#4DBEEE', '#77AC30', '#40E0D0', '#6495ED'};
% select subject
indexSubject = 4;
chosenDay = 22;
chosenChannel = 8;
valueResolution = 30; %pixel/cm
for indexSubject = 4:4 %length(subjectUnique)
    currentSubject = subjectUnique{indexSubject};
    currentSubjectDataIndex = find(ismember(dataFull_name, currentSubject));
    currentSubjectData = dataFull_small(currentSubjectDataIndex, :);
    
    currentChannelData = currentSubjectData(currentSubjectData(:, 2) == chosenChannel, :);
    currentDateChannelData = currentChannelData(currentChannelData(:, 4) == chosenDay, :);
    t = tiledlayout('flow', 'Padding', 'loose');
    x = currentDateChannelData(:, 1) * 14;
    y = currentDateChannelData(:, 3)/valueResolution;
    ax1 = plot(x, y, '-o');
    hold on
    set([ax1(1)], 'Color', colorLine{indexSubject}, ...
                         'MarkerFaceColor', colorLine{indexSubject}, ...
                         'MarkerEdgeColor', colorLine{indexSubject}, ...
                         'MarkerSize', 15, ...
                         'LineWidth', 2);
    ax1(1).DisplayName = "Day " + num2str(chosenDay);

    disp(gof)
    ylimData = ylim;
    ylimData(1) = 0;
    ylimData(2) = ylimData(2);
    ylim(ylimData);
    
    xlimData = xlim;
    xlimData(1) = 0;
    xlimData(2) = xlimData(2) + 1;
    xlim(xlimData)
    
    xlabel('Current (µA)', 'FontSize', 15)
    ylabel('Toe displacement (cm)', 'FontSize', 15)

    hleg = legend;
    
    set(hleg, 'FontSize', 10, 'visible', 'off');
    title(t, "Recruitment curve of " +  currentSubject + ...
             " at days " + num2str(chosenDay) + ...
             " of channel " + num2str(chosenChannel - 1), 'FontSize', 20);

    figName = currentSubject + " recruitment curve";
    ax = gcf;
    exportName = startPath + "/" + figName + ".png";
    exportgraphics(ax, exportName, 'Resolution', 1000);
end
%% Plot match current with intensity value
close all
indexSubject = 4;
currentSubject = subjectUnique{indexSubject};
currentSubjectDataIndex = find(ismember(dataFull_name, currentSubject));
currentSubjectData = dataFull_small(currentSubjectDataIndex, :);
    
listDate = unique(currentSubjectData(:, 4));

t = tiledlayout(1,1,'Padding','tight');
t.Units = 'inches';
t.OuterPosition = [0 0 10 10];
t.InnerPosition = [1 1 4 3];
nexttile
% figure
colorLine = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#A2142F', ...
             '#4DBEEE', '#77AC30', '#40E0D0', '#6495ED', '#88A096', ...
             '#F8D210'}; 

tableData = tabulate(currentSubjectData(:, 1));
frequencyData = tableData(any(tableData(:, 2), 2), :);
frequencyData = sortrows(frequencyData, 2, 'descend');
for indexIntensity = 1:6
    currentIntensity = frequencyData(indexIntensity, 1);
    currentIntensityData = currentSubjectData(currentSubjectData(:, 1) == currentIntensity, :);
    x = currentIntensityData(:, 4);
    y = currentIntensityData(:, 5);
    [f, gof] = fit(x, y, 'poly1');
    ax1 = plot(x, y);
    hold on
    set([ax1(1) ax1(2)], 'Color', colorLine{indexIntensity}, ...
                         'MarkerFaceColor', colorLine{indexIntensity}, ...
                         'MarkerEdgeColor', colorLine{indexIntensity}, ...
                         'MarkerSize', 15, ...
                         'LineWidth', 1);
%     ax1(1).DisplayName = "Intensity = " + num2str(currentIntensity) + " with frequency = " + num2str(frequencyData(indexIntensity, 2));
    delete(ax1(1))
    ax1(2).DisplayName = "Fitted line with rmse = " + num2str(gof.rmse);
    disp(gof)
    s = swarmchart(x, y, 'MarkerFaceColor', colorLine{indexIntensity}, ...
                         'MarkerEdgeColor', colorLine{indexIntensity});
    s.XJitter = 'rand';
    s.XJitterWidth = 0.75;
    
    s.YJitter = 'rand';
    s.YJitterWidth = 0.15;
    s.SizeData = 20;
    s.DisplayName = "Intensity = " + num2str(currentIntensity) + " with frequency = " + num2str(frequencyData(indexIntensity, 2));
end
ylimData = ylim;
ylimData(1) = 0;
ylimData(2) = ylimData(2) + 1;
ylim(ylimData);

xlimData = xlim;
xlimData(1) = 0;
xlimData(2) = xlimData(2) + 1;
xlim(xlimData)

xlabel('Days after intial data')
ylabel('Multiplier of base intensity')

title('Match intensity with multipliers of six most frequent values - J2 Data');
[hleg, hobj] = legend;
set(hleg,'Location', 'bestoutside','FontSize',7);

figName = "Match intensity";
ax = gcf;
exportName = startPath + "/" + figName + ".png";
exportgraphics(ax, exportName, 'Resolution', 400);

%% Old
thresholdMultiplier = 2;
for indexChannel = 1:channelMax
    
    currentChannelData = dataFull_small(dataFull_small(:, 2) == indexChannel, :);
    uniqueDate = unique(currentChannelData(:, 4));

    dateData_Channel = zeros(length(uniqueDate), 8);
    for indexDate = 1:length(uniqueDate)
        currentDate = uniqueDate(indexDate);
        currentDateChannelData = currentChannelData(currentChannelData(:, 4) == currentDate, :);
        % 2 times the threshold, with round up
        currentDateChannelData_filter = currentDateChannelData(round(currentDateChannelData(:, 5)) == thresholdMultiplier, :);

        dataCount = size(currentDateChannelData_filter, 1);
        meanIntensity = mean(currentDateChannelData_filter(:, 1));
        stdIntensity = std(currentDateChannelData_filter(:, 1));

        meanDisplacement = mean(currentDateChannelData_filter(:, 3));
        stdDisplacement = std(currentDateChannelData_filter(:, 3));

        currentDateChannelData_Threshold = currentDateChannelData(currentDateChannelData(:, 5) == 1, :);
        meanIntensityThreshold = mean(currentDateChannelData_Threshold(:, 1));
        stdIntensityThreshold = std(currentDateChannelData_Threshold(:, 1));

        dateData_Channel(indexDate, :) = [currentDate, dataCount, meanIntensity, stdIntensity, meanDisplacement, stdDisplacement, meanIntensityThreshold, stdIntensityThreshold];
    end


    figure
    subplot(2, 1, 1)
    errorbar(dateData_Channel(:, 1), dateData_Channel(:, 5), dateData_Channel(:, 6));
    ylimData = ylim;
    ylimData(1) = 0;
    ylimData(2) = ylimData(2) + 10;

    xlimData = xlim;
    xlimData(1) = 0;
    xlimData(2) = xlimData(2) + 1;
    figName = "Max toe displacement at channel = " + num2str(indexChannel - 1) + " across dates at 2 times threshold intensity";
    title(figName);
    xlabel('Days after inital result');
    xlim(xlimData)
    ylim(ylimData)
    ylabel('Displacement (pixels*pixels)');
    % legend


    subplot(2, 1, 2)
    errorbar(dateData_Channel(:, 1), dateData_Channel(:, 7), dateData_Channel(:, 8));
    ylimData = ylim;
    ylimData(1) = 0;
    ylimData(2) = ylimData(2) + 10;

    xlimData = xlim;
    xlimData(1) = 0;
    xlimData(2) = xlimData(2) + 1;

    figName = "Threshold intensity as function of dates at channel = " + num2str(indexChannel - 1);
    title(figName);
    xlabel('Days after inital result');
    xlim(xlimData)
    ylim(ylimData)
    ylabel('Threshold intensity');

    if ~dataPlotAndExport
        continue
    end

    figName = "Channell " + num2str(indexChannel - 1);
    ax = gcf;
    exportName = startPath + "/" + figName + ".png";
    exportgraphics(ax, exportName, 'Resolution', 400);
end
close all
%%
listMultiplier = [1:4];
for indexChannel = 1:channelMax
    
    currentChannelData = dataFull_small(dataFull_small(:, 2) == indexChannel, :);
    uniqueDate = unique(currentChannelData(:, 4));
    figure
    for indexMultiplier = 1:length(listMultiplier)
        currentMultiplier = listMultiplier(indexMultiplier);
        currentMultiplierData = currentChannelData(currentChannelData(:, 5) == currentMultiplier, :);
        listDate = unique(currentMultiplierData(:, 4));
        
        multiplierData = zeros(size(listDate, 1), 4);
        for indexDate = 1:length(listDate)
            currentDate = listDate(indexDate);
            currentDateChannelData = currentMultiplierData(currentMultiplierData(:, 4) == currentDate, :);
            meanIntensity = mean(currentDateChannelData(:, 1));
            stdIntensity = std(currentDateChannelData(:, 1));
            multiplierData(indexDate, :) = [currentDate, ...
                                            currentMultiplier, ...
                                            meanIntensity, ...
                                            stdIntensity];
        end
        
        subplot(2, 2, indexMultiplier)
        errorbar(multiplierData(:, 1), multiplierData(:, 3), multiplierData(:, 4));
        ylimData = ylim;
        ylimData(1) = 0;
        ylimData(2) = ylimData(2) + 10;

        xlimData = xlim;
        xlimData(1) = 0;
        xlimData(2) = xlimData(2) + 1;

        figName = "Channel = " + num2str(indexChannel - 1) + " threshold multiplier = " + num2str(currentMultiplier);
        title(figName);
        xlabel('Days after inital result');
        xlim(xlimData)
        ylim(ylimData)
        ylabel('Intensity');
    end
    
    figName = "Channell " + num2str(indexChannel - 1) + " with different threshold multiplier";
    ax = gcf;
    exportName = startPath + "/" + figName + ".png";
    exportgraphics(ax, exportName, 'Resolution', 400);
    dateData_Channel = zeros(length(uniqueDate), 8);
    
end
