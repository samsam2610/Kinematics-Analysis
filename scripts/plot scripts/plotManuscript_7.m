addpath(genpath(pwd))
clear all
close all
load SCI.mat
load lookupAmpTable.mat

% startPath = 'C:\Users\Zhong\OneDrive - Northwestern University\Wireless Interface Kinematics';
% startPath = 'C:\Users\Zhong\OneDrive - Northwestern University\Desktop\Stability J2';
startPath = '/Users/sam/Library/CloudStorage/OneDrive-NorthwesternUniversity/Documents/Wireless Interface Kinematics';

targetTypeNames = {'single pulse'; 'tetanic'};
targetTypeVariables = {'SAM', 'TAM'};

list_of_joints = {{'pelvisTop', 'hip', 'knee', 'hip angles'}, ...
                 {'hip', 'knee', 'ankle', 'knee angles'}, ... 
                 {'knee', 'ankle', 'MTP', 'ankle angles'}, ...
                 {'pelvisTop', 'hip', 'MTP', 'lower limb angles'}};

colorLineUnique = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#A2142F', ...
             '#4DBEEE', '#77AC30', '#40E0D0', '#6495ED', '#88A096', ...
             '#F8D210', '#94d2bd'};

colorLine = {'#cddafd',	'#dfe7fd',	'#80FFDB',	'#72EFDD', ...
             '#64DFDF',	'#56CFE1',	'#48BFE3',	'#4EA8DE', ...
         	 '#5390D9',	'#5E60CE',	'#6930c3',	'#7400B8'};

lineNames = ["1st week", "2nd week", "3rd week", "4th week", "5th week", "6th week"];
fitList = table;
indexFit = 1;
%%
close all
subjectList = unique(dataFull.Chronic_Stab.name(:, 1));
converseData = @converseADC;
convertValueList = [0, 1];
for indexSubject = 1:length(subjectList)
    currentSubject = subjectList{indexSubject};
    currentSubjectIndex = strcmp(dataFull.Chronic_Stab.name(:, 1), currentSubject);
    convertValue = convertValueList(indexSubject);
    currentData = dataFull.Chronic_Stab.data(currentSubjectIndex, :);
    
    listChannel = unique(currentData.('Channel')(:));
    
    xlimDataMax = [0, 0];
    for indexChannel = 1:length(listChannel)
        currentChannel = listChannel(indexChannel);
        t = tiledlayout('flow', 'Padding', 'loose');
        set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 1.96 1.58])
        ax1 = nexttile;

        currentChannelData = currentData(currentData.('Channel')(:) == currentChannel, :);
        listDate = unique(currentChannelData.('Date')(:));

        for indexDate = 1:length(listDate)
            currentDate = listDate(indexDate);
            currentDateChannelData = currentChannelData(currentChannelData.('Date')(:) == currentDate, :);
            dataChannelCount = size(currentDateChannelData, 1);
            currentResolution = currentDateChannelData.('Resolution');
    
            if dataChannelCount < 3
               xRaw = zeros(3, 1);
               yRaw = zeros(3, 1);
               hideAx = true;
            else
                xRaw = currentDateChannelData.('Amplitude')(:);
                yRaw = currentDateChannelData.('Displacement Toe Max')(:);
                hideAx = false;
            end
            
            x = unique(xRaw);
            y = zeros(length(x), 1);
            for xIndex = 1:length(x)
                currentY = yRaw(xRaw==x(xIndex));
                y(xIndex) = max(currentY);
            end
    
            [x, xIndex] = sort(x);

            y = y(xIndex);
            x = x;
            %x = converseData(x, convertValue, lookupAmpTable);

%             [f, gof] = fit(x, y, 'poly2');
% %             fitList(indexFit, :) = [indexSubject, currentChannel, currentDate, f.p1, f.p2, f.p3];
%             fitList.('Subject')(indexFit) = string(currentSubject);
%             fitList.('Channel')(indexFit) = currentChannel - 1;
%             fitList.('Date')(indexFit) = currentDate;
%             fitList.('p1')(indexFit) = f.p1;
%             fitList.('p2')(indexFit) = f.p2;
%             fitList.('p3')(indexFit) = f.p3;
%             fitList.('R2')(indexFit) = gof.rsquare;
%             fitList.('p function')(indexFit) = string("p1*x^2 + p2*x + p3");
%             indexFit = indexFit + 1;
            ax1 = plot(x, y, '-o');
%             ax1 = plot(f, x, y);
            hold on
            set([ax1(1)], 'Color', colorLineUnique{indexDate}, ...
                                 'MarkerFaceColor', colorLineUnique{indexDate}, ...
                                 'MarkerEdgeColor', colorLineUnique{indexDate}, ...
                                 'MarkerSize', 5, ...
                                 'LineWidth', 1, ...
                                 'DisplayName', lineNames(indexDate));
            if hideAx && (indexDate ~= length(listDate))
                set(ax1, 'visible', 'off')
            end
        end
        disp(gof)
        ylimData = ylim;
        ylimData(1) = 0;
        ylimData(2) = 11;
        ylim(ylimData);
        
        xlimData = xlim;
        xlimData(1) = xlimData(1);
        xlimData(2) = xlimData(2);
        xlim(xlimData)
        
        xlabel('current (mA)', 'FontSize', 10)
        ylabel('Toe displacement (cm)', 'FontSize', 10)

        hleg = legend;
        set(hleg, 'FontSize', 10, 'visible', 'on', 'Location', 'bestoutside');
        title(t, "Toe displacement for channel " + num2str(currentChannel -1) + " by dates, from " +  currentSubject, 'FontSize', 15);
        set(gca, 'box','off', 'TickDir', 'out', 'fontweigh', 'bold', 'fontsize', 12, 'FontName', 'Arial');
        
        figName = currentSubject + " toe displacement at channel" + num2str(currentChannel -1);
        ax = gcf;
        exportName = startPath + "/" + figName + ".png";
        exportgraphics(ax, exportName, 'Resolution', 1000);

        exportName = startPath + "/" + figName + ".eps";
        exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');
    end
    

end
% tableName = startPath + "/" + figName + ".xlsx";
% writetable(fitList, tableName);

%% section 2 - Plot amp modulation spinal multiple channel from SCI data
close all

indexData = 1:height(dataFull.SCI.data);
currentData = table2array(dataFull.SCI.data(indexData, [1, 2, 3, 4, 6]));

listChannel = unique(currentData(:, 2));

t = tiledlayout('flow', 'Padding', 'loose');
ax = nexttile;
hold on
% set(gcf, 'Position',  [100, 100, 600, 600])
set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 1.96 1.58]);
% channelSupplementData = [8; 15; 3; 3; 3];
converseData = @converseADC;
convertValueList = [0, 1];

for indexChannel = 1:length(listChannel)
    currentChannel = listChannel(indexChannel);
    currentData_Channel = currentData(currentData(:, 2) == currentChannel, :);
    currentPW = currentData_Channel(1, 3);
    x = 0.0127.* currentData_Channel(:, 1)+ 0.0069;

    %currentAmp = lookupAmpTable(x, 2);
    %x = currentAmp;
    y = currentData_Channel(:, 5);
    
    [x, xIndex] = sort(x);
    y = y(xIndex)./36.4;
    x = x./14;
%     x0 = lookupAmpTable(channelSupplementData(indexChannel), 2)*1000;
%     y0 = 0;

%     x = [x0; x];
%     y = [y0; y];
    
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
ylimData = ylim;
ylimData(1) = 0;
ylimData(2) = ylimData(2) + 1;
ylim(ylimData);

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


%%
function y = converseADC(x, z, lookupAmpTable)
    if z == 0
       y = 0.0127.*x + 0.0069;
    elseif z == 1
       y = lookupAmpTable(x-1, 2);
    end
end