function [startPoint, stopPoint] = cropData(data, params)
    summationPoint = params.summationPoint;
    summationLength = length(summationPoint);

    coorNames = {'X', 'Y'};
    coorData = zeros(2, 2);
    for indexCoor = 1:length(coorNames)
        coorName = coorNames{indexCoor};

        currentChange = zeros(height(data), 1);
        for indexSummation = 1:summationLength
            pointName = summationPoint{indexSummation};
            currentData = data.(pointName).(coorName);
            currentChange = ischange(currentData) + currentChange;
        end
        currentChange = currentChange == summationLength;
        currentChangeIndex = find(currentChange);
        coorData(indexCoor, 1) = min(currentChangeIndex);
        coorData(indexCoor, 2) = max(currentChangeIndex);
    end
    
    startPoint = min(coorData, [], 1);
    startPoint = startPoint(1);
    stopPoint = max(coorData, [], 1);
    stopPoint = stopPoint(2);
end