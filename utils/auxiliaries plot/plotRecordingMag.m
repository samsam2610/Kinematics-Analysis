function numberOfData = plotRecordingMag(dataFiles, list_of_joints, plotAllData)
    currentList = list_of_joints{3};
    dataNames = fieldnames(dataFiles);
    numberOfData = length(dataNames);
    varName = cell(numberOfData, 1);
    for indexName = 1:numberOfData
        varName{indexName} = dataNames{indexName};
    end
    figure
    maxAxis = 0;
    minAxis = inf;
    for indexName = 1:numberOfData

        dataName = dataNames{indexName};

        if plotAllData
            dataCoords = dataFiles.(dataName).data(:, :);
        else
            currentInstantData = dataFiles.(dataName).angleInstantTable('ankle angles', :);
            dataAngleMaxIndex = currentInstantData.('Highest Angle Instant').Index;
            dataCoords = dataFiles.(dataName).data([1 dataAngleMaxIndex], :);
        end
        dataCoordsHeight = height(dataCoords);

        magnitudeList = zeros(dataCoordsHeight - 1, 3);
        X_pelvisTop = dataCoords{1, 'pelvisTop'}.X;
        X_pelvisBottom = dataCoords{1, 'pelvisBottom'}.X;

        directionRat = (X_pelvisTop - X_pelvisBottom)/(abs(X_pelvisTop - X_pelvisBottom));
        for indexPosition = 1:3
            currentPosition = currentList{indexPosition};

            X_min = dataCoords{1, currentPosition}.X;
            Y_min = dataCoords{1, currentPosition}.Y;

            X_max = dataCoords{2:end, currentPosition}.X;
            Y_max = dataCoords{2:end, currentPosition}.Y;
            u = [X_max - X_min, Y_max - Y_min];
            directionPosition = (X_max - X_min)./(abs(X_max - X_min));
            directionMovement = directionRat*directionPosition;
            magnitudeMovement = directionMovement.*vecnorm(u, 2, 2);
            if max(magnitudeMovement) > maxAxis
                maxAxis = max(magnitudeMovement);
            end
            if min(magnitudeMovement) < minAxis
                minAxis = min(magnitudeMovement);
            end
            magnitudeList(:, indexPosition) = magnitudeMovement;
            
        end

        subplot(2, 2, 1)
        if plotAllData
            plot3(magnitudeList(:, 2), magnitudeList(:, 3), magnitudeList(:, 1));
        else
            scatter3(magnitudeList(:, 2), magnitudeList(:, 3), magnitudeList(:, 1), 120, 'filled');
            hold on
            % text(magnitudeList(:, 2), magnitudeList(:, 3), magnitudeList(:, 1), dataName);
        end

        xlabel(currentList{2});
        ylabel(currentList{3});
        zlabel(currentList{1});
        hold on

        subplot(2, 2, 2)
        if plotAllData
            plot(magnitudeList(:, 1), magnitudeList(:, 2));
        else
            scatter(magnitudeList(:, 1), magnitudeList(:, 2), 120, 'filled');
            hold on
            % text(magnitudeList(:, 1), magnitudeList(:, 2), dataName);
        end
        xlabel(currentList{1});
        ylabel(currentList{2});
        hold on

        subplot(2, 2, 3)
        if plotAllData
            plot(magnitudeList(:, 1), magnitudeList(:, 3));
        else
            scatter(magnitudeList(:, 1), magnitudeList(:, 3), 120, 'filled');
            hold on
            % text(magnitudeList(:, 1), magnitudeList(:, 3), dataName);
        end
        
        xlabel(currentList{1});
        ylabel(currentList{3});
        hold on

        subplot(2, 2, 4)
        if plotAllData
            plot(magnitudeList(:, 2), magnitudeList(:, 3));
        else
            scatter(magnitudeList(:, 2), magnitudeList(:, 3), 120, 'filled');
            hold on
            % text(magnitudeList(:, 2), magnitudeList(:, 3), dataName);
        end
        xlabel(currentList{2});
        ylabel(currentList{3});
        hold on

    end
    
    if abs(minAxis) > abs(maxAxis)
        axisScale = abs(minAxis) + abs(minAxis)*0.05;
    else
        axisScale = abs(maxAxis) + abs(maxAxis)*0.05;
    end


    for indexPlot = 1:4
        subplot(2, 2, indexPlot);
        xlim([-axisScale axisScale])
        ylim([-axisScale axisScale])
        zlim([-axisScale axisScale])
        legend(varName, 'Location','southeast');
        grid on
        % axis equal
    end


end