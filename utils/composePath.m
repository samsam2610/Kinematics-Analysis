function csvPath = composePath(rawCSVPath, startPath)
    if ispc
        splitter = "\";
        replacing = "/";
    elseif ismac
        splitter = "/";
        replacing = "\";
    end

    checkedCSVPath = strrep(rawCSVPath, replacing, splitter);
    checkedStartPath = strrep(startPath, replacing, splitter);

    csvPath = join([checkedStartPath, checkedCSVPath], splitter);
end