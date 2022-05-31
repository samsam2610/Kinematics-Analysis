function data = filterData(data, thresholdValue, variableNames)
    arguments
        data table
        thresholdValue double
        variableNames cell = data.Properties.VariableNames;
    end
    removingColumn = setdiff(data.Properties.VariableNames, variableNames);
    data(:, removingColumn) = [];
    filteringIndex = zeros(height(data), 1);
    widthCell = width(data.(1)(1, :));
    for variableIndex = 2:length(variableNames)
        variableName = variableNames{variableIndex};
        filteringIndex = filteringIndex | (data.(variableName).P < thresholdValue);
        for indexDim = 1:widthCell-1
            checkNan = isnan(table2array(data.(variableName)(:, indexDim)));
            filteringIndex = filteringIndex | checkNan;
        end
    end
    data(filteringIndex, :) = [];
    
end