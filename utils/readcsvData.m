function rawData = readcsvData(csvPath)
    options = detectImportOptions(csvPath, 'Delimiter', ',');
    options.VariableNamesLine = 2;
    options.VariableUnitsLine = 3;
    rawData = readtable(csvPath, options);
    variableNames = rawData.Properties.VariableNames;
    bodyPartNames = variableNames(2:3:end);
    for indexBody = 1:length(bodyPartNames)
        currentBodyPart = bodyPartNames{indexBody};
        bodyPart_X = convertCharsToStrings(currentBodyPart);
        newName_X = "X";
        bodyPart_Y = convertCharsToStrings(append(currentBodyPart, '_1'));
        newName_Y = "Y";
        bodyPart_P = convertCharsToStrings(append(currentBodyPart, '_2'));
        newName_P = "P";
        rawData = renamevars(rawData, [bodyPart_X, bodyPart_Y ,bodyPart_P], ...
                                      [newName_X, newName_Y, newName_P]);
        rawData = mergevars(rawData, {'X', 'Y' , 'P'},...
                   'NewVariableName', currentBodyPart, 'MergeAsTable', true);
    end
end