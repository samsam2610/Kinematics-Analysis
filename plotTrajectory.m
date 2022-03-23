function plottedData = plotTrajectory(data)
    plottedData = figure;
    hold on
    tableHeight = height(data);
    tableWidth = width(data);
    for indexWidth = 2:tableWidth
        plot(data.(indexWidth).X, data.(indexWidth).Y, 'LineWidth', 5);
    end

    for indexHeight = 1:tableHeight
        X = zeros(tableWidth - 1, 1);
        Y = zeros(tableWidth - 1, 1);
        for indexWidth = 2:tableWidth
            X(indexWidth - 1) = data.(indexWidth).X(indexHeight);
            Y(indexWidth - 1) = data.(indexWidth).Y(indexHeight);
        end
        plot(X, Y, 'black', 'linestyle','--', 'LineWidth', 0.00001);
    end
    legend(data.Properties.VariableNames{2:end});
    set(gca, 'YDir','reverse')
    hold off
end
