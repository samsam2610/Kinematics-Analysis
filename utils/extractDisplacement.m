function displacementTable = extractDisplacement(data, indexInitSelect, useFilter)
    arguments
        data table
        indexInitSelect logical = true
        useFilter logical = false
    end
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

        if useFilter == false
            if indexInitSelect == true
                indexInit = 1;
            else
                indexInit = length(x);
            end
        
            displacementData = sqrt((x(2:end) - x(indexInit)).^2 + (y(2:end) - y(indexInit)).^2);
            [displacementMaximum, maxIndex] = max(displacementData);
            displacementTable(currentVarName, 'Displacement Data') = num2cell(displacementData, 1);
            displacementTable(currentVarName, 'Maximum Displacement') = {displacementMaximum};
            displacementTable(currentVarName, 'Maximum Displacement Index') = {maxIndex(1)};
        else
            thresholdLength = round(length(x)*0.1);
            x = x(thresholdLength:end-thresholdLength);
            y = y(thresholdLength:end-thresholdLength);
            displacementData = sqrt((x(2:end) - x(1)).^2 + (y(2:end) - y(1)).^2);
            try
                [pk, locs] = findpeaks(displacementData, 200, ...
                                       'MinPeakWidth', 0.01, ...
                                       'MinPeakDistance', 1, ...
                                       'MinPeakProminence', 6, ...
                                       'NPeaks', 1);
                locs = round(locs*200);
                pk = pk - displacementData(locs-50);
                displacementTable(currentVarName, 'Displacement Data') = num2cell(displacementData, 1);
                displacementTable(currentVarName, 'Maximum Displacement') = {pk};
                displacementTable(currentVarName, 'Maximum Displacement Index') = {locs*200};
            catch
                [displacementMaximum, maxIndex] = max(displacementData);
                displacementTable(currentVarName, 'Displacement Data') = num2cell(displacementData, 1);
                displacementTable(currentVarName, 'Maximum Displacement') = {displacementMaximum};
                displacementTable(currentVarName, 'Maximum Displacement Index') = {maxIndex(1)};
            end
        end

    end
end