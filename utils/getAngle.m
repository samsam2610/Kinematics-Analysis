function [angleList, angleVelocity, angleAcc] = getAngle(a, b, c, frameList, methods) 
    arguments
        a
        b
        c
        frameList
        methods double = 1
    end

    u = a - b;
    v = c - b;
    dataLength = length(u);
    angleList = zeros(dataLength, 1);
    for index = 1:length(u)
        if methods == 1
            angleList(index) = rad2deg(atan2(norm(cross(u(index, :), v(index, :))),dot(u(index, :), v(index, :))));
        elseif methods == 2
            angleList(index) = rad2deg(subspace(u(index, :)', v(index, :)'));
        end
    end
    frameVelocity = diff(frameList);
    angleVelocity = diff(angleList)./frameVelocity;
    
    frameAcc = frameVelocity(2:end);
    angleAcc = diff(angleVelocity)./frameAcc;
end