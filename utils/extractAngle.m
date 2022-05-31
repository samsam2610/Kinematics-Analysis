function angleTable = extractAngle(data, list_of_joints, options)
    arguments
        data
        list_of_joints
        options.dimensions double = 2
        options.methods double = 1
    end

    zeroColumn = zeros(length(data.('pelvisTop').('X')), 1);
    numberOfData = length(list_of_joints);
    varName = cell(numberOfData, 1);
    for indexJointList = 1:length(list_of_joints)
        currentList = list_of_joints{indexJointList};
        varName{indexJointList} = currentList{4};
    end
    varTypes = {'cell','cell','cell'};
    angleTable = table('Size', [numberOfData, 3], ...
                       'VariableTypes',varTypes, ...
                       'VariableNames', {'Angle List', 'Angular Velocity', 'Angular Acceleration'}, ...
                       'RowNames', varName);
    frameList = data.bodyparts;
    for indexJointList = 1:length(list_of_joints)
        currentList = list_of_joints{indexJointList};
        currentVarName = currentList{4};
        if options.dimensions == 2
            a = [data.(currentList{1}).('X'), data.(currentList{1}).('Y'), zeroColumn];
            b = [data.(currentList{2}).('X'), data.(currentList{2}).('Y'), zeroColumn];
            c = [data.(currentList{3}).('X'), data.(currentList{3}).('Y'), zeroColumn];
        elseif options.dimensions == 3
            a = [data.(currentList{1}).('X'), data.(currentList{1}).('Y'), data.(currentList{1}).('Z')];
            b = [data.(currentList{2}).('X'), data.(currentList{2}).('Y'), data.(currentList{2}).('Z')];
            c = [data.(currentList{3}).('X'), data.(currentList{3}).('Y'), data.(currentList{3}).('Z')];
        end
        [angleList, angleVelocity, angleAcc] = getAngle(a, b, c, frameList, options.methods);
        angleTable(currentVarName, 'Angle List') = num2cell(angleList, 1);
        angleTable(currentVarName, 'Angular Velocity') = num2cell(angleVelocity, 1);
        angleTable(currentVarName, 'Angular Acceleration') = num2cell(angleAcc, 1);
    end
    

end