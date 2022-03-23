function [PIXELRESOLUTION, sampleName, sampleDate] = getPixelResolution(csvPath, skipResolution, resFilePath)
    resolutionHead = {'capture-frames', 'video-data.csv'};
    if ispc
        splitter = "\";
    elseif ismac
        splitter = "/";
    end
    resolutionHead = join(resolutionHead, splitter);
    partSplit = split(csvPath, splitter);
    fileName = partSplit(end);
    partName = split(fileName, '_');
    recordingName = partName(1:3);
    recordingName = cell2mat(join(recordingName, '_'));
    if exist('skipResolution', 'var')
        if skipResolution
            sampleName = partName(1:2);
            sampleName = cell2mat(join(sampleName, '_'));
            sampleDate = partName(3);
            PIXELRESOLUTION = 30;
            return
        end
    else
        if exist('resFilePath', 'string')
            resolutionPath = resFilePath;
        else
            resolutionPath = partSplit;
            resolutionPath(end) = resolutionHead;
            resolutionPath = cell2mat(join(resolutionPath, splitter)); 
        end   
    end
   
    options = detectImportOptions(resolutionPath);
    options.Delimiter = {','};
    options.VariableTypes{1, 2} = 'double';
    
    pixelResTable = readtable(resolutionPath, options);

    PIXELRESOLUTION = 0;
    for indexTable = 1:height(pixelResTable)    
        currentSample = cell2mat(pixelResTable{indexTable, 1});
        currentSampleSplit = split(currentSample, '_');
        currentSampleSplit = currentSampleSplit(1:3);
        sampleNameDate = cell2mat(join(currentSampleSplit, '_'));
        if strcmp(sampleNameDate, recordingName)
            PIXELRESOLUTION = pixelResTable{indexTable, 2};
            sampleName = currentSampleSplit(1:2);
            sampleName = cell2mat(join(sampleName, '_'));
            sampleDate = currentSampleSplit(3);
        end

    end
    
    if PIXELRESOLUTION == 0
        print('no matching file name for the current data to retrieve the resolution value');
        print('setting pixel resolution to 30 pixels per centimeter');
        PIXELRESOLUTION = 30;
    end

end