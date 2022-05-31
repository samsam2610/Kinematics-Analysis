close all
clear all

colorLineUnique = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#A2142F', ...
             '#4DBEEE', '#77AC30', '#40E0D0', '#6495ED', '#88A096', ...
             '#F8D210', '#94d2bd'};

startPath = '/Users/sam/Library/CloudStorage/OneDrive-NorthwesternUniversity/Documents/Wireless Interface Kinematics';
folderPath = '/Users/sam/Library/CloudStorage/OneDrive-NorthwesternUniversity/Incage Monitoring pre and post';

myfiles = dir(folderPath);
folderPath = '/Users/sam/Library/CloudStorage/OneDrive-NorthwesternUniversity/Incage Monitoring pre and post';

filenames={myfiles(:).name}';
filefolders={myfiles(:).folder}';

csvfiles = filenames(endsWith(filenames,'.csv'));
csvfolders = filefolders(endsWith(filenames,'.csv'));
csvfiles_list = fullfile(csvfolders, csvfiles);

avifiles = filenames(endsWith(filenames, '.avi'));
avifolders = filefolders(endsWith(filenames,'.avi'));
avifiles_list = fullfile(avifolders, avifiles);

% get frame data


pathFrame = fullfile(folderPath, 'capture-frames');
frameFolderFiles = dir(pathFrame);

filenames={frameFolderFiles(:).name}';
filefolders={frameFolderFiles(:).folder}';
framefiles = filenames(endsWith(filenames, '.bmp'));
framefolders = filefolders(endsWith(filenames,'.bmp'));

framefiles_list = fullfile(framefolders, framefiles);

for indexCSV = 1:length(avifiles_list)
    t = tiledlayout('flow', 'Padding', 'loose');
    set(gcf, 'PaperUnits','inches','PaperPosition',[0 0 1.96 1.58])
    ax1 = nexttile;

    currentFile = csvfiles_list{indexCSV};
    csvnames = csvfiles{indexCSV};
    for indexFRAME = 1:length(framefiles_list)
        currentFrame = framefiles_list(indexFRAME);

        splitCSVPath = split(csvnames, '_');
        currentMatch = contains(currentFrame, splitCSVPath{1});
        if currentMatch
            currentFrame = currentFrame{1};

            break
        end
    end
    currentFrame = imread(currentFrame);
    imshow(currentFrame);
    hold on
    rawData = readcsvData(currentFile);
    rawData_Back = rawData(:, {'bodyparts', 'Back'});
    THRESHOLDVALUE = 0.7;
    filteredData = filterData(rawData_Back, THRESHOLDVALUE);
    x = table2array(filteredData.Back(:, 'X'));
    y = table2array(filteredData.Back(:, 'Y'));
    plot(x, y, ...
        'LineWidth', 1.5, ...
        'Color', colorLineUnique{2});

    figName = "Cage movement of " + splitCSVPath{1} + " " + splitCSVPath{2};
    ax = gcf;
    exportName = startPath + "/" + figName + ".png";
    exportgraphics(ax, exportName, 'Resolution', 1000);
    
    exportName = startPath + "/" + figName + ".eps";
    exportgraphics(ax, exportName, 'ContentType', 'vector', 'BackgroundColor','none');
end
