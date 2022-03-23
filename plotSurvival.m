load dateTimeTable.mat
startPath = '/Volumes/GoogleDrive/My Drive/Rat/SCI tests';
targetTypeNames = {'single pulse'; 'tetanic'};
targetTypeVariables = {'SAM', 'TAM'};
targetAngles = {'hip angles'; 'knee angles'; 'ankle angles'; 'lower limb angles'};

dateLength = size(dateTimeTable, 2);

for indexAngle = 1:length(targetAngles)
    targetAngle = targetAngles(indexAngle);
    figure

    for indexChannel = 1:8
        currentDataIndex = 1;
        currentData = zeros(2, 2);
        for indexDate = 1:dateLength
            currentSlot = dateTimeTable{indexChannel, indexDate};
            if isempty(currentSlot)
                continue
            end
            currentData(currentDataIndex, :) = [indexDate - 1, currentSlot(1, indexAngle)];
            currentDataIndex = currentDataIndex + 1;
        end
        legendName = "Channel " + string(indexChannel - 1);
        plot(currentData(:, 1), currentData(:, 2), 'DisplayName', legendName);
        hold on
    end
    figName = "Max angles survival plot of " + string(targetAngles{indexAngle});
    title(figName);
    xlabel('Days after inital result');
    ylabel('Angles (degree)');
    legend
    ax = gcf;
    exportName = startPath + "/" + figName + ".png";
    exportgraphics(ax, exportName, 'Resolution', 400);
end
