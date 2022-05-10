clear all
close all
load Victor_Chronic.mat
load lookupAmpTable.mat

% startPath = 'C:\Users\Zhong\OneDrive - Northwestern University\Wireless Interface Kinematics';
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

lineNames = ["1st week", "2nd week", "3rd week", "4th week", "5th week", "6th week", "7th week"];
fitList = table;
indexFit = 1;
plotFit = false;
%%
subjectList = unique(dataFull.VictorChronic.name(:, 1));
converseData = @converseADC;
convertValueList = 0;
for indexSubject = 1:length(subjectList)
    currentSubject = subjectList{indexSubject};
    currentSubjectIndex = strcmp(dataFull.VictorChronic.name(:, 1), currentSubject);
    convertValue = 1;
    currentData = dataFull.VictorChronic.data(currentSubjectIndex, :);
    currentNameWeek = dataFull.VictorChronic.name(currentSubjectIndex, 2);
    listChannel = unique(currentData.('Channel')(:));
    
    xlimDataMax = [0, 0];
    for indexChannel = 1:length(listChannel)
        currentChannel = listChannel(indexChannel);
        t = tiledlayout('flow', 'Padding', 'loose');
        set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 1.96 1.58])
        ax1 = nexttile;

        currentChannelIndex = currentData.('Channel')(:) == currentChannel;
        currentChannelData = currentData(currentChannelIndex, :);
        currentNameWeekData = currentNameWeek(currentChannelIndex, :);
        listDate = unique(currentNameWeekData);

        for indexDate = 1:length(listDate)
            currentDate = listDate(indexDate);
            currentDateIndex = strcmp(currentNameWeekData, currentDate);
            currentDateChannelData = currentChannelData(currentDateIndex, :);
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

            y = y(xIndex);
            x = converseData(x, convertValue, lookupAmpTable);
            
            ax1 = plot(x, y, '-o'); 
            hold on
            set([ax1(1)], 'Color', colorLineUnique{indexDate}, ...
                                 'MarkerFaceColor', colorLineUnique{indexDate}, ...
                                 'MarkerEdgeColor', colorLineUnique{indexDate}, ...
                                 'MarkerSize', 5, ...
                                 'LineWidth', 1, ...
                                 'DisplayName', lineNames(indexDate));

        end
     
        ylimData = ylim;
        ylimData(1) = 0;
        ylimData(2) = 5;
        ylim(ylimData);
        
        xlimData = xlim;
        xlimData(1) = 1.5;
        xlimData(2) = xlimData(2);
        xlim(xlimData)
        
        xlabel('current (mA)', 'FontSize', 10)
        ylabel('Toe displacement (cm)', 'FontSize', 10)

        hleg = legend;
        set(hleg, 'FontSize', 10, 'visible', 'on', 'Location', 'bestoutside');
        title(t, "Toe displacement for channel " + num2str(currentChannel -1) + " by dates, from " +  currentSubject, 'FontSize', 15);
        set(gca, 'box','off', 'TickDir', 'out', 'fontweigh', 'bold', 'fontsize', 12, 'FontName', 'Arial');
        
        figName = currentSubject + " toe displacement at channel " + num2str(currentChannel -1);
        ax = gcf;

        exportName = startPath + "/" + figName + ".png";
        exportgraphics(ax, exportName, 'Resolution', 1000);

        exportName = startPath + "/" + figName  + ".eps";
        exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');
    end
    

end

function y = converseADC(x, z, lookupAmpTable)
    if z == 0
       y = 0.0127.*x + 0.0069;
    elseif z == 1
       y = lookupAmpTable(x-1, 2);
    end
end