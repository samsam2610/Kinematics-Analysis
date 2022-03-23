function numberOfData = plotRecordingData(dataFiles, list_of_joints)
    numberOfJoints = length(list_of_joints);
    dataNames = fieldnames(dataFiles);
    numberOfData = length(dataNames);
    
    c = [1 0 0; 0 1 0; 0 0 1];
    for indexName = 1:numberOfData
        dataName = dataNames{indexName};
        figure
        

        currentResolution = dataFiles.(dataName).pixelResolution;
        currentInstantData = dataFiles.(dataName).angleInstantTable('ankle angles', :);
        dataAngleMaxIndex = currentInstantData.('Highest Angle Instant').Index;
        dataCoords = dataFiles.(dataName).data([1 dataAngleMaxIndex], :);
    
        tableWidth = width(dataCoords);
        legendList = cell(tableWidth - 1, 1);
        minList = zeros(tableWidth - 1, 2);
        maxList = zeros(tableWidth - 1, 2);

        for indexJointList = 2:tableWidth
            X_min = dataCoords{1, indexJointList}.X;
            Y_min = dataCoords{1, indexJointList}.Y;

            X_max = dataCoords{2, indexJointList}.X;
            Y_max = dataCoords{2, indexJointList}.Y;
            
            scatter([X_min, X_max], [Y_min, Y_max]);
            
            legendName = dataCoords.Properties.VariableNames{indexJointList};
            
            minList(indexJointList - 1, :) = [X_min, Y_min];
            maxList(indexJointList - 1, :) = [X_max, Y_max];

            set(gca, 'YDir','reverse')
            hold on
            % drawArrow([X_min, X_max], [Y_min, Y_max]);
        end
        plot(minList(1:3, 1), minList(1:3, 2), 'b');
        plot(minList(4:tableWidth-1, 1), minList(4:tableWidth-1, 2), 'b');
        plot(minList([2, 4], 1), minList([2, 4], 2), 'b');
        plot(maxList(1:3, 1), maxList(1:3, 2), 'r');
        plot(maxList(4:tableWidth-1, 1), maxList(4:tableWidth-1, 2), 'r');
        plot(maxList([2, 4], 1), maxList([2, 4], 2), 'r');
        legend({'inital position', 'highest position'});
        titleName = dataName;

        title(titleName);

    end

end