function angleInstantTable = getInstantAngle(angleTable, data, list_of_joints)
    zeroColumn = zeros(length(data.('pelvisTop').('X')), 1);
    numberOfData = length(list_of_joints);
    varName = cell(numberOfData, 1);
    for indexJointList = 1:length(list_of_joints)
        currentList = list_of_joints{indexJointList};
        varName{indexJointList} = currentList{4};
    end

    varTypes = {'table', 'table', 'table', 'table'};
    angleInstantTable = table('Size', [numberOfData, 4], ...
        'VariableTypes',varTypes, ...
        'VariableNames', {'Highest Angle Instant', '1st point', '2nd point', '3rd point'}, ...
        'RowNames', varName);

    pointCoords = cell(3, 1);
    angleMaxData = cell(1, 1);

    for indexJointList = 1:length(list_of_joints)
        currentList = list_of_joints{indexJointList};
        currentVarName = currentList{4};
        angleData = angleTable.('Angle List'){currentVarName};
        angleData_Normalized = abs(angleData - angleData(1));
        [angleDataMax, angleDataMaxIndex] = max(angleData_Normalized);
        
        % angleInstantTable.('Highest Angle Instant')(currentVarName) = angleDataMax;
        angleMaxData{1, 1}(indexJointList, :) = [angleDataMax, angleDataMaxIndex];
        pointCoords{1, 1}(indexJointList, :) = [data.(currentList{1}).X(angleDataMaxIndex), data.(currentList{1}).Y(angleDataMaxIndex)];
        pointCoords{2, 1}(indexJointList, :) = [data.(currentList{2}).X(angleDataMaxIndex), data.(currentList{2}).Y(angleDataMaxIndex)];
        pointCoords{3, 1}(indexJointList, :) = [data.(currentList{3}).X(angleDataMaxIndex), data.(currentList{3}).Y(angleDataMaxIndex)];
    end
    angleInstantTable.(1).Value = angleMaxData{1, 1}(:, 1);
    angleInstantTable.(1).Index = angleMaxData{1, 1}(:, 2);

    for indexPoint = 1:3
        angleInstantTable.(indexPoint+1).X = pointCoords{indexPoint, 1}(:, 1);
        angleInstantTable.(indexPoint+1).Y = pointCoords{indexPoint, 1}(:, 2);
    end
end