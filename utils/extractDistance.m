function distanceTable = extractDistance(data, pixelResolution)
    variableNames = data.Properties.VariableNames;
    bodyPartNames = variableNames(2:end);
    varTypes = {'cell','cell','cell', 'table'};
    distanceTable = table('Size', [length(bodyPartNames), 4], ...
                       'VariableTypes',varTypes, ...
                       'VariableNames', {'Distance', 'Velocity', 'Acceleration', 'Maximum distance'}, ...
                       'RowNames', bodyPartNames);

    frameList = data.bodyparts;
    for indexBodyPart = 1:length(bodyPartNames)
        currentVarName = bodyPartNames{indexBodyPart};
        x = data.(currentVarName).('X');
        y = data.(currentVarName).('Y');
        [distanceData, distanceVelocity, distanceAcceleration] = getDistance(x, y, frameList, pixelResolution);
        [distanceMaxValue, distanceMaxIndex] = max(distanceData);
        
        distanceTable(currentVarName, 'Distance') = num2cell(distanceData, 1);
        distanceTable(currentVarName, 'Velocity') = num2cell(distanceVelocity, 1);
        distanceTable(currentVarName, 'Acceleration') = num2cell(distanceAcceleration, 1);
        distanceTable.('Maximum distance').X(indexBodyPart) = x(distanceMaxIndex + 1);
        distanceTable.('Maximum distance').Y(indexBodyPart) = y(distanceMaxIndex + 1);
        distanceTable.('Maximum distance').Value(indexBodyPart) = distanceMaxValue;
        distanceTable.('Maximum distance').Index(indexBodyPart) = distanceMaxIndex;
    end
end