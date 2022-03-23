function displacementTable = extractDisplacement(data)
    variableNames = data.Properties.VariableNames;
    bodyPartNames = variableNames(2:end);
    varTypes = {'cell','double'};
    displacementTable = table('Size', [length(bodyPartNames), 2], ...
                       'VariableTypes',varTypes, ...
                       'VariableNames', {'Displacement Data', 'Maximum Displacement'}, ...
                       'RowNames', bodyPartNames);

    for indexBodyPart = 1:length(bodyPartNames)
        currentVarName = bodyPartNames{indexBodyPart};
        x = data.(currentVarName).('X');
        y = data.(currentVarName).('Y');
        displacementData = sqrt((x(2:end) - x(1)).^2 + (y(2:end) - y(1)).^2);
        [displacementMaximum, maxIndex] = max(displacementData);
        displacementTable(currentVarName, 'Displacement Data') = num2cell(displacementData, 1);
        displacementTable(currentVarName, 'Maximum Displacement') = {displacementMaximum};
        displacementTable(currentVarName, 'Maximum Displacement Index') = {maxIndex(1)};

    end
end