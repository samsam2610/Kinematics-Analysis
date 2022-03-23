function data = polarizeData(data, thresholdValue)
    tableWidth = width(data);
    for indexWidth = 2:tableWidth
        X = data.(indexWidth).X;
        Y = data.(indexWidth).Y;
        [rho, theta] = cart2pol(X, Y);
        data.(indexWidth).rho = rho;
        data.(indexWidth).theta = theta;
    end
end