function data = filterData(data, thresholdValue)
    variableNames = data.Properties.VariableNames;
    filteringIndex = zeros(height(data), 1);
    for variableIndex = 2:length(variableNames)
        variableName = variableNames{variableIndex};
        filteringIndex = filteringIndex | data.(variableName).P < thresholdValue;
    end

    data(filteringIndex, :) = [];
end