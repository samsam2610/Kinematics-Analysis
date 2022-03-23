classdef SkeletonModel
    properties
        pelvisTop
        hip
        pelvisBottom
        knee
        ankle
        MTP
        toe
        originalPosition
        pointHip = [0, 0, 0];
        angle_TopHipY = 20;
        lengthDefault
    end
    properties (Dependent)
        directionRat
        angle_TopHipKnee
        angle_BottomHipKnee
        angle_HipKneeAnkle
        angle_KneeAnkleMTP
        angle_AnkleMTPToe
        angleList

    end
    methods 
        function obj = SkeletonModel(dataRow, options)
            arguments
                dataRow
                options.resolution (1, 1) double = 1
                options.lengthDefault (1, 1) double = 10
            end
            obj.pelvisTop = [dataRow{1, 'pelvisTop'}.X, dataRow{1, 'pelvisTop'}.Y, 0]./options.resolution;
            obj.hip = [dataRow{1, 'hip'}.X, dataRow{1, 'hip'}.Y, 0]./options.resolution;
            obj.pelvisBottom = [dataRow{1, 'pelvisBottom'}.X, dataRow{1, 'pelvisBottom'}.Y, 0]./options.resolution;
            obj.knee = [dataRow{1, 'knee'}.X, dataRow{1, 'knee'}.Y, 0]./options.resolution;
            obj.ankle = [dataRow{1, 'ankle'}.X, dataRow{1, 'ankle'}.Y, 0]./options.resolution;
            obj.MTP = [dataRow{1, 'MTP'}.X, dataRow{1, 'MTP'}.Y, 0]./options.resolution;
            obj.toe = [dataRow{1, 'toe'}.X, dataRow{1, 'toe'}.Y, 0]./options.resolution;
            obj.originalPosition = [obj.pelvisTop(1), obj.pelvisTop(2); ...
                                    obj.hip(1), obj.hip(2); ...
                                    obj.pelvisBottom(1), obj.pelvisBottom(2); ...
                                    obj.knee(1), obj.knee(2); ...
                                    obj.ankle(1), obj.ankle(2); ...
                                    obj.MTP(1), obj.MTP(2); ...
                                    obj.toe(1), obj.toe(2)];

            obj.lengthDefault = options.lengthDefault;

        end
        function directionRat = get.directionRat(obj)
            directionRat = (obj.pelvisTop(1, 1) - obj.pelvisBottom(1, 1))/abs((obj.pelvisTop(1, 1) - obj.pelvisBottom(1, 1)));
        end
        function angle_TopHipKnee = get.angle_TopHipKnee(obj)
            angle_TopHipKnee = calculateAngle(obj.pelvisTop, obj.hip, obj.knee);
        end
        function angle_BottomHipKnee = get.angle_BottomHipKnee(obj)
            angle_BottomHipKnee = calculateAngle(obj.pelvisBottom, obj.hip, obj.knee);
        end
        function angle_HipKneeAnkle = get.angle_HipKneeAnkle(obj)
            angle_HipKneeAnkle = calculateAngle(obj.hip, obj.knee, obj.ankle);
        end
        function angle_KneeAnkleMTP = get.angle_KneeAnkleMTP(obj)
            angle_KneeAnkleMTP = calculateAngle(obj.knee, obj.ankle, obj.MTP);
        end
        function angle_AnkleMTPToe = get.angle_AnkleMTPToe(obj)
            angle_AnkleMTPToe = calculateAngle(obj.ankle, obj.MTP, obj.toe);
        end
        function angleList = get.angleList(obj)
            angleList = [obj.angle_TopHipKnee, ...
                         obj.angle_BottomHipKnee, ...
                         obj.angle_HipKneeAnkle, ...
                         obj.angle_KneeAnkleMTP, ...
                         obj.angle_AnkleMTPToe];
        end
        function listCoords = calculatePosition(obj)
            pelvisTop_PointX = (-1) * obj.lengthDefault * cosd(obj.angle_TopHipY);
            pelvisTop_PointY = obj.lengthDefault * sind(obj.angle_TopHipY);

            angle_XHipKnee = obj.angle_TopHipKnee - obj.angle_TopHipY;
            angle_KneeHipX = 180 - angle_XHipKnee;
            angle_BottomHipX = angle_KneeHipX - obj.angle_BottomHipKnee;

            knee_PointX =  (-1) * obj.lengthDefault * cosd(angle_XHipKnee);
            knee_PointY = (-1) * obj.lengthDefault * sind(angle_XHipKnee);

            pelvisBottom_PointX = obj.lengthDefault * cosd(angle_BottomHipX);
            pelvisBottom_PointY = (-1)*obj.lengthDefault * sind(angle_BottomHipX);

            length_KneeAnkle = 1.5*obj.lengthDefault;
            length_HipAnkle = sqrt((obj.lengthDefault)^2 + (length_KneeAnkle)^2 - 2*obj.lengthDefault*length_KneeAnkle*cosd(obj.angle_HipKneeAnkle));

            [xout, yout] = circcirc(obj.pointHip(1), obj.pointHip(2), length_HipAnkle, ...
                                    knee_PointX, knee_PointY, length_KneeAnkle);

            if yout(1) < yout(2)
                index = 1;
            else
                index = 2;
            end
            ankle_PointX = xout(index);
            ankle_PointY = yout(index);

            length_AnkleMTP = 0.5*obj.lengthDefault;
            length_KneeMTP = sqrt((length_AnkleMTP)^2 + (length_KneeAnkle)^2 - 2*length_AnkleMTP*length_KneeAnkle*cosd(obj.angle_KneeAnkleMTP));

            [xout, yout] = circcirc(ankle_PointX, ankle_PointY, length_AnkleMTP, ...
                                    knee_PointX, knee_PointY, length_KneeMTP);

            if yout(1) < yout(2)
                index = 1;
            else
                index = 2;
            end
            MTP_PointX = xout(index);
            MTP_PointY = yout(index);

            length_MTPToe = 0.25*obj.lengthDefault;
            length_AnkleToe = sqrt((length_MTPToe)^2 + (length_AnkleMTP)^2 - 2*length_MTPToe*length_AnkleMTP*cosd(obj.angle_AnkleMTPToe));

            [xout, yout] = circcirc(ankle_PointX, ankle_PointY, length_AnkleToe, ...
                                    MTP_PointX, MTP_PointY, length_MTPToe);

            if yout(1) < yout(2)
                index = 1;
            else
                index = 2;
            end
            toe_PointX = xout(index);
            toe_PointY = yout(index);

            listCoords = [pelvisTop_PointX, pelvisTop_PointY; ...
                          obj.pointHip(1), obj.pointHip(2); ...
                          pelvisBottom_PointX, pelvisBottom_PointY; ...
                          knee_PointX, knee_PointY; ...
                          ankle_PointX, ankle_PointY; ...
                          MTP_PointX, MTP_PointY; ...
                          toe_PointX, toe_PointY];
        end

        function axes = plotFixedLength(obj, axes, colorPallete)
            listCoords = obj.calculatePosition;
            if ~exist('colorPallete', 'var')
                colorPallete = 'b';
            end
            plot(axes, listCoords(1:3, 1), listCoords(1:3, 2), 'Color', colorPallete);
            hold on
            plot(axes, listCoords(4:end, 1), listCoords(4:end, 2), 'Color', colorPallete);
            plot(axes, listCoords([2 4], 1), listCoords([2 4], 2), 'Color', colorPallete);
            hold on
            scatter(axes, listCoords(:, 1), listCoords(:, 2), 'MarkerFaceColor', colorPallete);
        end

        function outData = convertDataRow(obj, options)
            arguments
                obj
                options.dataType (1, 1) string = "original"
            end

            if options.dataType == "original"
                listCoords = obj.originalPosition;
            elseif options.dataType == "calculated"
                listCoords = obj.calculatePosition;
            end
            
            outData = table;
            variableNames = {'Pelvis Top X', 'Pelvis Top Y'; ...
                             'Hip X', 'Hip Y'; ...
                             'Pelvis Bottom X', 'Pelvis Bottom Y'; ...
                             'Knee X', 'Knee Y'; ...
                             'Ankle X', 'Ankle Y'; ...
                             'MTP X', 'MTP Y'; ...
                             'Toe X', 'Toe Y'};

            for indexPart = 1:length(variableNames)
                for indexAxis = 1:2
                    outData.(string(variableNames{indexPart, indexAxis})) = listCoords(indexPart, indexAxis);
                end
            end

        end

        function axes = plotPosition(obj, axes, colorPallete, plotName, flipSkeleton)
            listCoords = obj.originalPosition;
            if ~exist('colorPallete', 'var')
                colorPallete = 'b';
            end

            if exist('flipSkeleton', 'var')
                if flipSkeleton
                    set(gca, 'XDir', 'reverse')
                end
            end
            
            set(gca, 'YDir','reverse')
            plot(axes, listCoords(1:3, 1), listCoords(1:3, 2), 'Color', colorPallete, 'HandleVisibility','off');
            hold on
            plot(axes, listCoords(4:end, 1), listCoords(4:end, 2), 'Color', colorPallete, 'HandleVisibility','off');
            plot(axes, listCoords([2 4], 1), listCoords([2 4], 2), 'Color', colorPallete, 'HandleVisibility','off');
            hold on
            ax1 = scatter(axes, listCoords(:, 1), listCoords(:, 2), 'MarkerFaceColor', colorPallete, ...
                                                                    'MarkerEdgeColor', colorPallete);

            if exist('plotName', 'var')
                ax1(1).DisplayName = plotName;
            end
        end

        function axes = plotPositionUpdate(obj, axes, options)
            arguments
                obj
                axes
                options.dataType (1, 1) string = "original"
                options.colorPallete (1, 1) string = 'b'
                options.flipSkeleton (1, 1) logical = false
                options.plotName (1, 1) string = "Skeleton plot"
                options.plotNameDisplay (1, 1) logical = true
                options.LineStyle (1, 1) string = '-'
                options.LineWidth (1, 1) double = 0.5
                options.MarkerSize (1, 1) double = 36
            end

            if options.dataType == "original"
                listCoords = obj.originalPosition;
            elseif options.dataType == "calculated"
                listCoords = obj.calculatePosition;
            end

            if options.flipSkeleton
                set(gca, 'XDir', 'reverse')
            end

            
            set(gca, 'YDir','reverse')
            plot(axes, listCoords(1:3, 1), listCoords(1:3, 2), 'Color', options.colorPallete, ...
                                                               'LineStyle', options.LineStyle, ...
                                                               'LineWidth', options.LineWidth, ...
                                                               'HandleVisibility', 'off');
            hold on
            plot(axes, listCoords(4:end, 1), listCoords(4:end, 2), 'Color', options.colorPallete, ...
                                                                   'LineStyle', options.LineStyle, ...
                                                                   'LineWidth', options.LineWidth, ...
                                                                   'HandleVisibility','off');

            plot(axes, listCoords([2 4], 1), listCoords([2 4], 2), 'Color', options.colorPallete, ...
                                                                   'LineStyle', options.LineStyle, ...
                                                                   'LineWidth', options.LineWidth, ...
                                                                   'HandleVisibility','off');
            hold on
            ax1 = scatter(axes, listCoords(:, 1), listCoords(:, 2), 'SizeData', options.MarkerSize, 'MarkerFaceColor', options.colorPallete, ...
                                                                    'MarkerEdgeColor', options.colorPallete, ...
                                                                    'HandleVisibility','off');

            if options.plotNameDisplay == true
                ax1(1).DisplayName = options.plotName;
                ax1(1).HandleVisibility = 'on';
            end
        end
    end
end

function angleValue = calculateAngle(a, b, c)
    u = a - b;
    v = c - b;
    angleValue = rad2deg(atan2(norm(cross(u(:), v(:))),dot(u(:), v(:))));
end