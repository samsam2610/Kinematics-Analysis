%% Plot diverge response
close all
clear all
colorLineUnique = {'#0072BD', '#D95319', '#FF2F15', '#7E2F8E', '#35F6FF', ...
                   '#4DBEEE', '#77AC30', '#40E0D0', '#6495ED', '#88A096', ...
                   '#F8D210', '#94d2bd'};

expressionChannel = '(?<=C)[0-9]+';
expressionAmplitude = '(?<=(AMP))[0-9]+';
expressionFrequency = '(?<=([0-9]P))[0-9]+';
expressionPulseWidth = '(?<=(PW))[0-9]+';
expressionResponse = {'(flex|flexision|flextion|Flex)', '(ext|extension|extend)'};

parameterTable = readtable('video-data.csv', 'DatetimeType','text', 'TextType', 'string');
parameterTable.('RecordedDate') = datetime(parameterTable.('RecordedDate'), 'InputFormat', 'MM/dd/yy');

startPath = '/Users/sam/Library/CloudStorage/OneDrive-NorthwesternUniversity/Documents/Wireless Interface Kinematics/Freddy For Diverse Responses';
folderPath = '';

parameterTable = readtable('video-data.csv', 'DatetimeType','text', 'TextType', 'string');
parameterTable.('RecordedDate') = datetime(parameterTable.('RecordedDate'), 'InputFormat', 'MM/dd/yy');

% startPath = 'C:\Users\Zhong\OneDrive - Northwestern University\Wireless Interface Kinematics\Freddy For Diverse Responses';

csvPaths = {
            'Right side channels', ...
            'Left side channels'
            };

displayName = {'Right side', 'Left side'};

t = tiledlayout('flow', 'Padding', 'loose');
set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 1.96 1.58])
ax1 = nexttile;

numberFiles = length(csvPaths);
dataTable = table;
indexTable = 1;

for indexPath = 1:numberFiles
    rawCSVPath = csvPaths{indexPath};
    folderPath = composePath(rawCSVPath, startPath);
    myfiles = dir(folderPath);

    filenames={myfiles(:).name}';
    filefolders={myfiles(:).folder}';

    csvfiles=filenames(endsWith(filenames,'.csv'));
    csvfolders = filefolders(endsWith(filenames,'.csv'));

    files = fullfile(csvfolders,csvfiles);
    turnOnLegend = true;
    for indexCSV = 1:length(files)

        currentFile = files{indexCSV};
        sampleName = csvfiles{indexCSV};

        if contains(currentFile, 'analysis-status')
            continue
        end
        
        [numberChannel, intensityLevel, pulseWidth, frequencyValue, currentDate, resolution] = getVideoData(sampleName, parameterTable, 1);

        currentTitle = split(sampleName, '_');
        disp("Current type: " + currentTitle(1));
        disp("Sample code: " + currentTitle(3));
        
        for indexResponse = 1:2
            expression = expressionResponse{indexResponse};
            matchExp = regexp(currentTitle(1), expression, 'match');
            responseType = (cell2mat(matchExp{1}));

            if ~isempty(responseType)
                disp("Response type: " + responseType);
                responseType = indexResponse;
                x_axis = 0;
                if indexResponse == 1 % flexion
                    u = [0 -1];
                elseif indexResponse == 2 % extension
                    u = [0 1];
                end
                break
            end
        end
        
        rawData = readcsvData(currentFile);
        % Filter raw data base on threshold P
        THRESHOLDVALUE = 0.7;
        filteredData = filterData(rawData, THRESHOLDVALUE);

        if size(filteredData, 1) <= size(rawData, 1)*0.2
            continue
        end
        displacementTable = extractDisplacement(filteredData);
        
        currentData = filteredData;
        displacementToeMax = displacementTable{'toe', 'Maximum Displacement Index'};
        displacementToeMaxIndex = displacementTable{'toe', 'Maximum Displacement Index'};

        dataCoord_Max = currentData(displacementToeMaxIndex, :);
        dataCoord_Initial = currentData(1, :);
        dataTable.('data_X')(indexTable) = (dataCoord_Max{:, 'toe'}.X - dataCoord_Initial{:, 'toe'}.X);
        dataTable.('data_Y')(indexTable) = ((dataCoord_Max{:, 'toe'}.Y - dataCoord_Initial{:, 'toe'}.Y)) * -1;
        dataTable.('Response')(indexTable) = (responseType);
        dataTable.('Resolution')(indexTable) = resolution;

        % align the direction
        v = [dataTable.('data_X')(indexTable) dataTable.('data_Y')(indexTable)];
        angleRad = max(min(dot(u, v)/(norm(u)*norm(v)), 1), -1);
        angleDeg = real(acosd(angleRad));
        magnitudeValue = sqrt(dataTable.('data_X')(indexTable)^2 + dataTable.('data_Y')(indexTable)^2);
        if angleDeg > 90
            angleDeg = 180 - angleDeg;
        end

        sign_X = dataTable.('data_X')(indexTable)/abs(dataTable.('data_X')(indexTable));
        signCheck = sign_X * u(2);
        if signCheck == -1
            dataTable.('data_X')(indexTable) = dataTable.('data_X')(indexTable)*-1;
        end
        dataTable.('Angle')(indexTable) = angleDeg;
        dataTable.('Magnitude')(indexTable) = magnitudeValue;
        
        x = [0 dataTable.('data_X')(indexTable)];
        y = [0 dataTable.('data_Y')(indexTable)];
        
        h = quiver(0, 0, x(2), y(2), ...
                 'LineWidth', 1.5, ...
                 'Color', colorLineUnique{indexTable}, ...
                 'AutoScale', 'off', ...
                 'MaxHeadSize', 0.1, ...
                 'DisplayName', string(currentTitle(3)));

        hold on
        dataTable.('Object')(indexTable) = h;
        indexTable = indexTable + 1;
    end
end
axis equal

xlimData = xlim;
xlimData(2) = 120;
xlimData(1) = -1*xlimData(2);
xlim(xlimData);

ylimData = ylim;
ylimData(2) = 120;
ylimData(1) = -1*ylimData(2);
ylim(ylimData);

xticks([xlimData(1):20:xlimData(2)]);
yticks([ylimData(1):20:ylimData(2)]);

text(xlimData(1)/2, ylimData(2)/2, 'Flexion', 'HorizontalAlignment', 'center', 'fontweight', 'bold', 'FontName', 'Arial')
text(xlimData(2)/2, ylimData(2)/2, 'Extension', 'HorizontalAlignment', 'center', 'fontweight', 'bold', 'FontName', 'Arial')

xlabel('x (pixel)', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');
ylabel('y (pixel)', 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial');
title('Diversity of responses', 'FontSize', 15, 'fontweight', 'bold', 'FontName', 'Arial')

set(gca, ...
    'box', 'off',...
    'TickDir', 'out',...
    'fontweigh', 'bold',...
    'fontsize', 12, ...
    'XAxisLocation', 'origin', ...
    'YAxisLocation', 'origin');


flexionObjects = table2array(dataTable(dataTable.Response == 1, 'Object'));
hleg = legend(ax1, flexionObjects);
set(hleg, 'FontSize', 12, 'fontweight', 'bold', 'FontName', 'Arial', ...
          'visible', 'on', 'Location', 'southwest');
hold off

ax2 = axes('position',get(gca,'position'),'visible','off');
extensionObjects = table2array(dataTable(dataTable.Response == 2, 'Object'));
hleg = legend(ax2, extensionObjects);
set(hleg, 'FontSize', 10, 'fontweight', 'bold', 'FontName', 'Arial', ...
          'visible', 'on', 'Location', 'southeast');


figName = "Diversity of response";
ax = gcf;
exportName = startPath + "/" + figName + ".png";
exportgraphics(ax, exportName, 'Resolution', 1000);

exportName = startPath + "/" + figName + ".eps";
exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none', 'Resolution', 1000);
