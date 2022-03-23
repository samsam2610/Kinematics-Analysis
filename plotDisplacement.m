function plottedDisplacement = plotDisplacement(dataFiles, list_of_joints)
    numberOfJoints = length(list_of_joints);
    dataNames = fieldnames(dataFiles);
    numberOfData = length(dataNames);

    plottedDisplacement = figure;
    c = [1 0 0; 0 1 0; 0 0 1];
    for indexJointList = 1:numberOfJoints
        currentList = list_of_joints{indexJointList};
        currentJoint = currentList{4};
        currentPosition = currentList{2};
        subplot(2, 2, indexJointList);
        for indexName = 1:numberOfData
            dataName = dataNames{indexName};
            currentResolution = dataFiles.(dataName).pixelResolution;
            currentInstantData = dataFiles.(dataName).angleInstantTable(currentJoint, :);
            currentCoorData = dataFiles.(dataName).data(:, currentPosition);

            dataAngleMaxIndex = currentInstantData.('Highest Angle Instant').Index;
            X_min = currentCoorData{1, currentPosition}.X;
            Y_min = currentCoorData{1, currentPosition}.Y;

            X_max = currentCoorData{dataAngleMaxIndex, currentPosition}.X - X_min;
            Y_max = currentCoorData{dataAngleMaxIndex, currentPosition}.Y - Y_min;

            [theta, rho] = cart2pol(X_max, Y_max);
            % polarscatter(theta, rho);
            quiver(0, 0, X_max, Y_max);
            hold on
        end
        stringList = convertCharsToStrings(currentList);
        titleName = stringList(2) + " of " + stringList(4);
        legend(dataNames);
        title(titleName);

    end

end