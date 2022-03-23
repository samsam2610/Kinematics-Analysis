function [angleList, angleVelocity, angleAcc] = getAngle(a, b, c, frameList) 
    u = a - b;
    v = c - b;
    dataLength = length(u);
    angleList = zeros(dataLength, 1);
    for index = 1:length(u)
        angleList(index) = rad2deg(atan2(norm(cross(u(index, :), v(index, :))),dot(u(index, :), v(index, :))));
    end
    frameVelocity = diff(frameList);
    angleVelocity = diff(angleList)./frameVelocity;
    
    frameAcc = frameVelocity(2:end);
    angleAcc = diff(angleVelocity)./frameAcc;
end