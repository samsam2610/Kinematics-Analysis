function plottedData = plotPolar(data)
    plottedData = figure;
    tableWidth = width(data);
    for indexWidth = 2:tableWidth
        polarplot(data.(indexWidth).theta, data.(indexWidth).rho);
        hold on
    end
end
