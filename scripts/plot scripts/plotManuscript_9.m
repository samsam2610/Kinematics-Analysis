addpath(genpath(pwd))
clear all
close all
load David_Data.mat
load lookupAmpTable.mat

% startPath = 'C:\Users\Zhong\OneDrive - Northwestern University\Wireless Interface Kinematics';
% startPath = 'C:\Users\Zhong\OneDrive - Northwestern University\Northwestern\Spinal Wireless Interface\Figures\Repository';
startPath = 'C:\Users\Zhong\OneDrive - Northwestern University\Wireless Interface Kinematics';
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


fitList = table;
indexFit = 1;
plotFit = false;

familyChannels = {[2, 5]; [0, 1, 3, 4, 6, 7]};
familyNames = ["Muscle"; "Spinal"];
intialData = [15, 15, 65, 10, 0, 50, 5, 10];
%% By channels
close all
lineNames = ["1st week", "2nd week", "SCI One week", "4th week", "5th week", "6th week"];
subjectList = unique(dataFull.DavidStability.name(:, 1));
converseData = @converseADC;
convertValueList = [0, 1];
for indexSubject = 1:length(subjectList)
    currentSubject = subjectList{indexSubject};
    currentSubjectIndex = strcmp(dataFull.DavidStability.name(:, 1), currentSubject);
    convertValue = 1;
    currentData = dataFull.DavidStability.data(currentSubjectIndex, :);
    
    listDate = unique(currentData.('Date')(:));
    
    xlimDataMax = [0, 0];
    for indexDate = 1:length(listDate)
        currentDate = listDate(indexDate);


        currentDateData = currentData(currentData.('Date')(:) == currentDate, :);
        for indexFamily = 1:length(familyNames)
            t = tiledlayout('flow', 'Padding', 'loose');
            set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 1.96 1.58])
            ax1 = nexttile;
            
            currentFamilyName = familyNames(indexFamily);
            currentFamilyChannels = familyChannels{indexFamily} + 1;
            listChannelFull = unique(currentDateData.('Channel')(:));
            listChannel = intersect(listChannelFull, currentFamilyChannels);

            for indexChannel = 1:length(listChannel)
                currentChannel = listChannel(indexChannel);
                currentDateChannelData = currentDateData(currentDateData.('Channel')(:) == currentChannel, :);
                dataChannelCount = size(currentDateChannelData, 1);
                currentResolution = currentDateChannelData.('Resolution');
        
                if dataChannelCount < 3
                   xRaw = zeros(3, 1);
                   yRaw = zeros(3, 1);
                   hideAx = true;
                else
                    xRaw = currentDateChannelData.('Amplitude')(:);
                    yRaw = currentDateChannelData.('Displacement Toe Max')(:)./currentDateChannelData.('Resolution')(:);
                    hideAx = false;
                end
                
                x = unique(xRaw);
                y = zeros(length(x), 1);
                for xIndex = 1:length(x)
                    currentY = yRaw(xRaw==x(xIndex));
                    y(xIndex) = max(currentY);
                end
        
                [x, xIndex] = sort(x);
                x = [intialData(currentChannel); x];
                
                y = y(xIndex);
                
                x = converseData(x, convertValue, lookupAmpTable);
                y = [0; y];
                
                ax1 = plot(x, y, '-o');
   
                hold on
                set([ax1(1)], 'Color', colorLineUnique{indexChannel}, ...
                                     'MarkerFaceColor', colorLineUnique{indexChannel}, ...
                                     'MarkerEdgeColor', colorLineUnique{indexChannel}, ...
                                     'MarkerSize', 3, ...
                                     'LineWidth', 1, ...
                                     'DisplayName', num2str(currentChannel-1));
                if hideAx && (indexChannel ~= length(indexChannel))
                    set(ax1, 'visible', 'off')
                end
            end
            ylimData = ylim;
            ylimData(1) = 0;
            ylimData(2) = 4.2;
            ylim(ylimData);
            
            xlimData = xlim;
            xlimData(1) = 1.5;
            xlimData(2) = xlimData(2);
            xlim(xlimData)
            
            xlabel('current (mA)', 'FontSize', 10)
            ylabel('Toe displacement (cm)', 'FontSize', 10)
    
            hleg = legend;
            set(hleg, 'FontSize', 10, 'visible', 'on', 'Location', 'bestoutside');
            title(hleg, 'Channel');
            title(t, "Toe displacement for " + lineNames(indexDate) + " by channel, from " +  currentSubject + " - " + currentFamilyName, 'FontSize', 15);
            set(gca, 'box','off', 'TickDir', 'out', 'fontweigh', 'bold', 'fontsize', 12, 'FontName', 'Arial');
           
            figName = currentSubject + " toe displacement at " + lineNames(indexDate) + " - " + currentFamilyName;
            ax = gcf;
            exportName = startPath + "/" + figName + ".png";
            exportgraphics(ax, exportName, 'Resolution', 1000);
    
            exportName = startPath + "/" + figName + ".eps";
            exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');
        end
    end
    

end

function y = converseADC(x, z, lookupAmpTable)
    if z == 0
       y = 0.0127.*x + 0.0069;
    elseif z == 1
       y = lookupAmpTable(x-1, 2);
    end
end