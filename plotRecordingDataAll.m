function numberOfData = plotRecordingDataAll(dataFiles, list_of_joints, targetAngle)
    numberOfJoints = length(list_of_joints);
    dataNames = fieldnames(dataFiles);
    numberOfData = length(dataNames);
    dataSample = dataFiles.(dataNames{1}).data(1, :);
    dataWidth = width(dataSample) - 1;

    minList = zeros(dataWidth, 2, numberOfData);
    maxList = zeros(dataWidth, 2, numberOfData);
    diffList = zeros(dataWidth, 2, numberOfData);

    hipPosList = zeros(numberOfData, 3);
    %% Get average hip position
    for indexName = 1:numberOfData
        dataName = dataNames{indexName};

        currentInstantData = dataFiles.(dataName).angleInstantTable(targetAngle, :);
        dataAngleMaxIndex = currentInstantData.('Highest Angle Instant').Index;
        dataCoords = dataFiles.(dataName).data([1 dataAngleMaxIndex], :);

        % Get direction
        X_pelvisTop = dataCoords{1, 'pelvisTop'}.X;
        X_pelvisBottom = dataCoords{1, 'pelvisBottom'}.X;

        directionRat = (X_pelvisTop - X_pelvisBottom)/(abs(X_pelvisTop - X_pelvisBottom));
        
        %%
        X_mean = mean(dataCoords.('hip').X * directionRat);
        Y_mean = mean(dataCoords.('hip').Y);

        if directionRat == -1
            X_shift = 2*abs(X_mean);
            X_mean = X_mean + 2*abs(X_mean);
        else
            X_shift = 0;
        end

        hipPosList(indexName, :) = [X_mean, Y_mean, X_shift];
    end
    meanHipPos = [mean(hipPosList(:, 1)), mean(hipPosList(:, 2))];

    for indexName = 1:numberOfData
        dataName = dataNames{indexName};

        currentInstantData = dataFiles.(dataName).angleInstantTable(targetAngle, :);
        dataAngleMaxIndex = currentInstantData.('Highest Angle Instant').Index;
        dataCoords = dataFiles.(dataName).data([1 dataAngleMaxIndex], :);

        % Get direction
        X_pelvisTop = dataCoords{1, 'pelvisTop'}.X;
        X_pelvisBottom = dataCoords{1, 'pelvisBottom'}.X;

        directionRat = (X_pelvisTop - X_pelvisBottom)/(abs(X_pelvisTop - X_pelvisBottom));

        X_shift = hipPosList(indexName, 3); % shift amount
        X_diff = dataCoords.('hip').X * directionRat + X_shift - meanHipPos(1);
        Y_diff = dataCoords.('hip').Y - meanHipPos(2);
        
        for indexJointList = 2:dataWidth+1
            X_min = dataCoords{1, indexJointList}.X*directionRat + X_shift;
            Y_min = dataCoords{1, indexJointList}.Y;

            X_max = dataCoords{2, indexJointList}.X*directionRat + X_shift;
            Y_max = dataCoords{2, indexJointList}.Y;

            minList(indexJointList - 1, :, indexName) = [X_min, Y_min];
            maxList(indexJointList - 1, :, indexName) = [X_max, Y_max];
            diffList(indexJointList - 1, :, indexName) = [X_max - X_min, Y_max - Y_min];

        end

    end

    figure
    minList_Mean = mean(minList, 3); % mean initial X and Y positions across all samples 
    for indexName = 1:numberOfData
        dataName = dataNames{indexName};

        for indexJointList = 2:dataWidth+1
            X_max = minList_Mean(indexJointList - 1, 1) + diffList(indexJointList - 1, 1, indexName);
            Y_max = minList_Mean(indexJointList - 1, 2) + diffList(indexJointList - 1, 2, indexName);

            maxList(indexJointList - 1, :, indexName) = [X_max, Y_max];
        end

        scatter([minList_Mean(:, 1); maxList(:, 1, indexName)], [minList_Mean(:, 2); maxList(:, 2, indexName)]);
        set(gca, 'YDir','reverse')
        hold on

        h1 = plot(minList_Mean(1:3, 1), minList_Mean(1:3, 2), 'b');
        plot(minList_Mean(4:dataWidth, 1), minList_Mean(4:dataWidth, 2), 'b');
        plot(minList_Mean([2, 4], 1), minList_Mean([2, 4], 2), 'b');
        h2 = plot(maxList(1:3, 1, indexName), maxList(1:3, 2, indexName), 'r');
        plot(maxList(4:dataWidth, 1, indexName), maxList(4:dataWidth, 2, indexName), 'r');
        plot(maxList([2, 4], 1, indexName), maxList([2, 4], 2, indexName), 'r');
        legend([h1(1), h2(1)], {'inital position', 'highest position'});

    end
    
    figure
    hold on
    h1 = axes;
    for indexName = 1:numberOfData
        dataName = dataNames{indexName};

        currentInstantData = dataFiles.(dataName).angleInstantTable(targetAngle, :);
        dataAngleMaxIndex = currentInstantData.('Highest Angle Instant').Index;
        dataCoords = dataFiles.(dataName).data([1 dataAngleMaxIndex], :);

        dataInitial = dataCoords(1, :);
        dataFinal = dataCoords(2, :);

        dataInitialSkeleton = SkeletonModel(dataInitial, 20);

        dataFinalSkeleton = SkeletonModel(dataFinal, 20);
        dataInitialSkeleton.plot(h1, 'b');
        dataFinalSkeleton.plot(h1, 'r');
    end