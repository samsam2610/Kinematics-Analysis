function [distanceData, distanceVelocity, distanceAcceleration] = getDistance(x, y, frameList, pixelResolution)

    distanceData = sqrt((x(2:end) - x(1:end-1)).^2 + (y(2:end) - y(1:end-1)).^2)./pixelResolution;
    
    frameVelocity = diff(frameList);
    distanceVelocity = distanceData./frameVelocity;
    
    frameAcceleration = frameVelocity(2:end);
    distanceAcceleration = diff(distanceVelocity)./frameAcceleration;
end