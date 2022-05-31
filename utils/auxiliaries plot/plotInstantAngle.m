function plottedPolar = plotInstantAngle(dataFiles, list_of_joints)
    numberOfJoints = length(list_of_joints);
    dataNames = fieldnames(dataFiles);
    numberOfData = length(dataNames);

    plottedPolar = figure;
    c = [1 0 0; 0 1 0; 0 0 1];
    for indexJointList = 1:numberOfJoints
        currentList = list_of_joints{indexJointList};
        currentJoint = currentList{4};
        subplot(2, 2, indexJointList);
        for indexName = 1:numberOfData
            dataName = dataNames{indexName};
            dataPower = split(dataName, 'P');
            dataPower = str2double(dataPower{2});
            currentData = dataFiles.(dataName).angleTable(currentJoint, :);
            tableWidth = width(currentData);
            currentPolar = zeros(3, 2);

            for indexWidth = 2:tableWidth
                currentPolar(indexWidth - 1, :) = [currentData.(indexWidth).theta, currentData.(indexWidth).rho];
            end

            polarscatter(deg2rad(currentData.('Highest Angle Instant').Value), dataPower/10, 75, 'filled');
            hold on
        end
        legend(dataNames);
        title(currentJoint);

    end

end