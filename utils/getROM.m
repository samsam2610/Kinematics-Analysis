function ROM = getROM(angleData)

    time = round(linspace(0, length(angleData), length(angleData)));
    
    angleData_filtered = lowpass(angleData, 15, 200);
    angleData_filtered = medfilt1(angleData_filtered, 15);
    angleData_filtered_Inverted = -1*(angleData_filtered);
    
    % Find peaks
    [peaks_b , locs_b] = findpeaks(angleData_filtered, 'MinPeakWidth', 2, 'MinPeakDistance', 20);
    [peaks_b_inv, locs_b_inv] = findpeaks(angleData_filtered_Inverted, 'MinPeakWidth', 2, 'MinPeakDistance', 20);
    [peaks_raw, locs_raw] = findpeaks(angleData_filtered, 'MinPeakHeight', 40);
    
    % Extract cycles
    currentCycle = zeros(length(locs_b_inv), 2);
    indexCycle = 1;
    for indexValley = 1:length(locs_b_inv)
    currentValley = locs_b_inv(indexValley);
    if indexValley < length(locs_b_inv)
        nextValley = locs_b_inv(indexValley + 1);
    else
        nextValley = length(angleData_filtered);
    end
        
    currentPeakList = locs_b(and(locs_b > currentValley, locs_b < nextValley));
    if isempty(currentPeakList)
        continue
    end
    currentPeakIndex = 1;
    while (1)
        currentPeak = currentPeakList(currentPeakIndex);
        currentPeakValleyDistance = currentPeak - currentValley;
        currentPeakValleyDifference = angleData_filtered(currentPeak) - angleData_filtered(currentValley);
        if (currentPeakValleyDistance < 5) || (currentPeakValleyDifference < 10)
            if currentPeakIndex < length(currentPeakList)
                currentPeakIndex = currentPeakIndex + 1;
            else
                currentPeak = [];
                break
            end
        else
            break
        end
    end
    if isempty(currentPeak)
        continue
    end
    currentSlope = and(locs_raw > currentValley, locs_raw < currentPeak);
    if sum(currentSlope) == 0
        currentCycle(indexCycle, :) = [currentValley, currentPeak];
        indexCycle = indexCycle + 1;
    end
    end
    currentCycle(~any(currentCycle, 2), : ) = [];
    peakList = currentCycle(1:end, 2);
    valleyList = currentCycle(1:end, 1);
    
    peakAngleList = angleData_filtered(peakList);
    valleyAnglelist = angleData_filtered(valleyList);
    
    % Calculate ROM
    
    ROM = peakAngleList - valleyAnglelist;
    stdROM = std(ROM);
    meanROM = mean(ROM);
    medianROM = median(ROM);
    thresholdROMValue_Lower = ROM < (medianROM - stdROM);
    thresholdROMValue_Upper = ROM > (medianROM + stdROM);
    ROM_Filter = ROM;
    ROM_Filter(thresholdROMValue_Lower) = 0;
    ROM_Filter(thresholdROMValue_Upper) = 0;
    ROM_Filter(ROM_Filter == 0) = [];
end

