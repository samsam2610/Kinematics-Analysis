addpath(genpath(pwd))
clear all
close all
load Treadmill_Data_D2.mat
set(groot, 'defaultFigureUnits', 'inches', 'defaultFigurePosition', [0 0 15 14]);
% startPath = 'C:\Users\Zhong\OneDrive - Northwestern University\Wireless Interface Kinematics';
startPath = 'C:\Users\Zhong\OneDrive - Northwestern University\Wireless Interface Kinematics'
startPath = '/Users/sam/Library/CloudStorage/OneDrive-NorthwesternUniversity/Documents/Wireless Interface Kinematics/Treadmill data';
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

offset = 0;
duration = 30; %second
%%
close all
dateList = dataFull.Treadmill.data.Date;


for indexDate = 1:5

    dataStruct = dataFull.Treadmill.data.('Data table')(indexDate);
    currentFrameRate = dataFull.Treadmill.data.('FrameRate')(indexDate);
    currentDate = dataFull.Treadmill.data.('Date')(indexDate);
    filteredData = dataStruct.dataCoords;
    rawData = dataStruct.dataRaws;
    angleData = dataStruct.angleData;
    
    x = filteredData.bodyparts./currentFrameRate;
    angleName = 'lower limb angles';
    angleDataType = 'Angle List';
    y = angleData.(angleDataType){angleName};

    ROM = getROM(y);
    infoROM = "Mean ROM is " + num2str(mean(ROM)) + " deg" ...
               + newline + newline + "Stdev ROM is " + num2str(std(ROM)) + " deg.";
    angleName = 'lower limb angles';
    angleDataType = 'Angular Velocity';
    y_secondary = angleData.(angleDataType){angleName};

    y_norm = y - mean (y);

    figure
    t = tiledlayout('flow', 'Padding', 'loose');
    set(gcf, 'PaperUnits', 'inches', 'PaperPosition',[0 0 1.96 1.58])
    ax1 = nexttile;

    ax1 = plot(x, y, '-o'); 

    set([ax1(1)], 'Color', colorLineUnique{indexDate}, ...
                         'MarkerFaceColor', colorLineUnique{indexDate}, ...
                         'MarkerEdgeColor', colorLineUnique{indexDate}, ...
                         'MarkerSize', 1, ...
                         'LineWidth', 2);

    xlabel('Time (s)', 'FontSize', 10)
    ylabel('Angle (deg)', 'FontSize', 10)
    
    ylimData = ylim;
    ylim(ylimData);
    
    xlimData = xlim;
    xlimData(1) = 0;
    xlimData(2) = xlimData(2);
    xlim(xlimData)

    hleg = legend;
    set(hleg, 'FontSize', 10, 'visible', 'on', 'Location', 'bestoutside');
    title(t, string(angleName) + " on date " + string(currentDate), 'FontSize', 15);
    set(gca, 'box','off', 'TickDir', 'out', 'fontweigh', 'bold', 'fontsize', 12, 'FontName', 'Arial');
    legendPosition = hleg.Position;
    annotation('textbox', [legendPosition(1), 0.1, legendPosition(3), 0.25], ...
               'String', infoROM);
%                'FitBoxToText', 'on');
    hold on
    figName = "D2 " + string(angleName) + " on date " + string(currentDate);
    ax = gcf;
    exportName = startPath + "/" + figName + ".png";
    exportgraphics(ax, exportName, 'Resolution', 1000);
    
    exportName = startPath + "/" + figName + ".eps";
    exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');
end




