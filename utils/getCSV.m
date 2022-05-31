function [csvfiles, csvfolders] = getCSV(fileDIR)
    filenames = {fileDIR(:).name}';
    filefolders = {fileDIR(:).folder}';

    csvfiles = filenames(endsWith(filenames, '.csv'));
    csvfolders = filefolders(endsWith(filenames, '.csv'));
end