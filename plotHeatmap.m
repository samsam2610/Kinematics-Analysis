load dataFull.mat
startPath = '/Volumes/GoogleDrive/My Drive/Rat/SCI tests';
targetTypeNames = {'single pulse'; 'tetanic'};
targetTypeVariables = {'SAM', 'TAM'};
targetAngles = {'hip angles'; 'knee angles'; 'ankle angles'; 'lower limb angles'};
targetTypes = {'(?<=C).*(?=S)'; '(?<=C).*(?=T)'};
for indexType = 1:length(targetTypes) 
    targetTypeVariable = targetTypeVariables{indexType};
    targetName = targetTypeNames{indexType};
    dataIndex = dataFull.(targetTypeVariable).index;
    dataTable = dataFull.(targetTypeVariable).data;

    dataTable(~any(dataTable, 2), : ) = [];
    % Process data table
    dataTable_lite = dataTable(:, 1:2);
    [C, ia, ic] = unique(dataTable_lite, 'rows');
    dataTableClean = zeros(size(ia, 1), size(dataTable, 2));
    for indexTable = 1:length(ia)
        currentData = dataTable(ic == indexTable, :);
        dataTableClean(indexTable, :) = mean(currentData, 1);
    end

    x = min(dataTableClean(:, 2)):1:max(dataTableClean(:, 2));
    y = min(dataTableClean(:, 1)):5:max(dataTableClean(:, 1));
    [X, Y] = meshgrid(x, y);
    Z = [Y(:) X(:)];
    angleMatrix = zeros(size(y, 2), size(x, 2));
    clear indexDataTable
    [~, indexDataTable] = ismember(dataTableClean(:, 1:2), Z, 'rows' );

    for indexAngle = 1:length(targetAngles)
        figure
        angleMatrix(indexDataTable) = dataTableClean(:, indexAngle+2);

        imagesc(x, y, angleMatrix);
        xlabel('Channel number -1');
        ylabel('Power level (step of 5)');
        figName = string(targetAngles{indexAngle}) + " - " + string(targetName);
        title(figName);
        set(gca,'YDir','normal', 'XTick', x);
        colormap jet
        colorBar = colorbar;
        colorBar.Label.String = 'Angles (degree)';
        ax = gcf;
        exportName = startPath + "/" + figName + ".png";
        exportgraphics(ax, exportName, 'Resolution', 400);
    end
end