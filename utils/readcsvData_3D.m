function rawData = readcsvData_3D(csvPath)
    options = detectImportOptions(csvPath);
    variableNames = options.VariableNames;
    bodyParts = cellfun(@(name) regexp(name, '.*(?=_+([xyz]|(score)))', 'match'), variableNames, 'UniformOutput', false);
    nonBodyParts = variableNames(cellfun('isempty', bodyParts));
    bodyParts = bodyParts(~cellfun('isempty', bodyParts));
    bodyParts = unique(cellfun(@string, bodyParts));
    rawData = readtable(csvPath);
    rawData = removevars(rawData, nonBodyParts);
    for indexPart = 1:length(bodyParts)
        currentBodyPart = bodyParts(indexPart);
        bodyPart_X = currentBodyPart + "_x";
        newName_X = "X";
        bodyPart_Y = currentBodyPart + "_y";
        newName_Y = "Y";
        bodyPart_Z = currentBodyPart + "_z";
        newName_Z = "Z";
        bodyPart_P = currentBodyPart + "_score";
        newName_P = "P";
        rawData = renamevars(rawData, [bodyPart_X, bodyPart_Y ,bodyPart_Z, bodyPart_P], ...
                                      [newName_X, newName_Y, newName_Z, newName_P]);
        rawData = mergevars(rawData, {'X', 'Y' , 'Z', 'P'},...
                   'NewVariableName', currentBodyPart, 'MergeAsTable', true);
    end
    rawData.('bodyparts') = linspace(1, height(rawData), height(rawData))';
    rawData = movevars(rawData, 'bodyparts', 'Before', 1);
end