addpath(genpath(pwd))
load dataFull.mat
startPath = '/Volumes/GoogleDrive/My Drive/Rat/SCI tests';
targetTypeNames = {'single pulse'; 'tetanic'};
targetTypeVariables = {'SAM', 'TAM'};
targetAngles = {'hip angles'; 'knee angles'; 'ankle angles'; 'lower limb angles'};

dateLength = size(dateTimeTable, 2);

dataFull_small = dataFull.SAM.data;

dataDate = dataFull_small(:, end);
dataDate(dataDate == 0) = [];

powerUnique = unique(dataFull_small(:, 1));

for indexAngle = 1:length(targetAngles)
    figure
    uniqueDate_length = 1;
    dataSummary = zeros(uniqueDate_length, 5);
    for indexPower = 1:length(powerUnique)
        currentPower = powerUnique(indexPower);
        if currentPower == 0
            continue
        end
        dataPower = dataFull_small(dataFull_small(:, 1) == currentPower, :);
        uniqueDate = unique(dataPower(:, end));
        if length(uniqueDate) > uniqueDate_length
            uniqueDate_length = length(uniqueDate);
            dataSummary = zeros(uniqueDate_length, 5);
        else
            continue
        end
        for indexDate = 1:uniqueDate_length
            currentDate = uniqueDate(indexDate);
            currentDate_data = dataPower(dataPower(:, end) == currentDate, indexAngle+2);
            currentMean = mean(currentDate_data);
            currentStd = std(currentDate_data);
            dataSummary(indexDate, 1:4) = [currentDate, currentMean, currentStd, length(currentDate_data)];
        end
        dataSummary(1, 5) = currentPower;

    end
    errorbar(dataSummary(:, 1), dataSummary(:, 2), dataSummary(:, 3));
    hold on
    bar(dataSummary(:, 1), dataSummary(:, 4));
    figName = "Max angles with intensity = " + string(dataSummary(1, 5)) + ...
               " survival plot of " + string(targetAngles{indexAngle});
    title(figName);
    xlabel('Days after inital result');
    ylabel('Angles (degree)');
    legend
    ax = gcf;
    exportName = startPath + "/" + figName + ".png";
    exportgraphics(ax, exportName, 'Resolution', 400);
end

