function data = filterData(data, thresholdValue, variableNames)
    arguments
        data table
        thresholdValue double
        variableNames cell = data.Properties.VariableNames;
    end
    removingColumn = setdiff(data.Properties.VariableNames, variableNames);
    data(:, removingColumn) = [];
    filteringIndex = zeros(height(data), 1);
    for variableIndex = 2:length(variableNames)
        variableName = variableNames{variableIndex};
        filteringIndex = filteringIndex | (data.(variableName).P < thresholdValue);
    end
    data(filteringIndex, :) = [];
    
end