function data = normalizeData(data, thresholdValue)
    tableWidth = width(data);
    coorNames = {'X', 'Y'};
    for indexCoor = 1:length(coorNames)
        coorName = coorNames{indexCoor};
        absoluteMin = Inf;
        for indexWidth = 2:tableWidth
            currentData = data.(indexWidth).(coorName);
            currentMin = min(currentData);
            if currentMin < absoluteMin
                absoluteMin = currentMin;
            end
            % thresholdBaseLine = meanData + thresholdValue*stdData;
            % baselineIndexes = abs(currentData) < thresholdBaseLine;
            % baselineValue = mean(currentData(baselineIndexes));

        end
        for indexWidth = 2:tableWidth
            currentData = data.(indexWidth).(coorName);
            normalizedData = currentData - absoluteMin;
            data.(indexWidth).(coorName) = normalizedData;
        end
    end
end