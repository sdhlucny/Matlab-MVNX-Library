function out = extractTrialFeatures(trial, varargin)
% EXTRACTTRIALFEATURES Extracts desired features from all the frames of a
% trial and returns the data as a timetable.
%
% NOTE: This function was designed to work with data from mvnx version 4
% files.
%
%   out = extractTrialFeatures(trial, F) extracts the feature and
%   associated properties specified in cell array F.
%   
%   o trial is an MVNX structure returned by the load_mvnx function.
%
%   o F is a cell array containing the feature and properties of interest.
%   Features and properties must be enumeration objects from one or more of
%   the following classes: Feature (for features), Sensor, Segment, Joint,
%   FootContact, ErgonomicJointAngle. The order matters for the cell array.
%   The first element must be the desired feature and only one feature can
%   be listed in the array. The order of the remaining properties
%   determines the order in which the properties will be listed in the
%   output timetable. Note that if no properties are specified, all
%   possible properties will be returned.
%
%   out = extractTrialFeatures(trial, F1, ...) extracts additionally
%   specified features. This allows the user to specify many
%   feature/property combos.
%
% Examples:
% A = extractTrialFeatures(trial, {Feature.position}) -> Returns a
% timetable containing all properties of the position feature.
%
% B = extractTrialFeatures(trial, {Feature.velocity, Segment.leftFoot,
% Segment.rightFoot}) -> Returns a timetable containing velocities of the
% left foot and right foot.
%
% C = extractTrialFeatures(trial, {Feature.position, Segment.head},
% {Feature.jointAngle, Joint.jRightShoulder}) -> Returns a timetable
% containing position of the head segment and joint angle of the right
% shoulder.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Get the frame structure from the trial
    frame = trial.subject.frames.frame;
    
    % Create table for extracted features
    output = table;
    
    % Lookup table to match property types with features
    lut = {'orientation', 'Segment', 4;
           'position', 'Segment', 3;
           'velocity', 'Segment', 3;
           'acceleration', 'Segment', 3;
           'angularVelocity', 'Segment', 3;
           'angularAcceleration', 'Segment', 3;
           'footContacts', 'FootContact', 1;
           'sensorFreeAcceleration', 'Sensor', 3;
           'sensorMagneticField', 'Sensor', 3;
           'sensorOrientation', 'Sensor', 4;
           'jointAngle', 'Joint', 3;
           'jointAngleXZY', 'Joint', 3;
           'jointAngleErgo', 'ErgonomicJointAngle', 3;
           'jointAngleErgoXZY', 'ErgonomicJointAngle', 3};
    
    % Parse the input arguments
    for i = 1:length(varargin)
        arg = varargin{i};
        
        % Verify arg starts with feature
        feature = arg{1};
        featureName = feature.string;
        if class(feature) ~= 'Feature'
            error(['Invalid argument: ' string(arg)]);
        end
        
        % Iterate over all requested properties for the feature
        for j = 2:length(arg)
            propName = arg{j}.string;
           
           % Make sure property type is correct for the requested feature
           index = find(strcmp(lut(:,1), featureName));
           if ~isempty(index) && ~strcmp(class(arg{j}), lut(index,2))
               error('Requested property does not correspond with requested feature');
           end

           % Compute index for the property
           switch(char(lut(index,2)))
               case 'Segment'
                   paramStruct = trial.subject.segments.segment;
               case 'FootContact'
                   paramStruct = trial.subject.footContactDefinition.contactDefinition;
               case 'Sensor'
                   paramStruct = trial.subject.sensors.sensor;
               case 'Joint'
                   paramStruct = trial.subject.joints.joint;
               case 'ErgonomicJointAngle'
                   paramStruct = trial.subject.ergonomicJointAngles.ergonomicJointAngle;
           end

           propIndex = (find(strcmp({paramStruct.label}, propName))-1) * cell2mat(lut(index,3)) + 1;
           sPropIndex = string(propIndex);

           % Get the requested data
           amt = cell2mat(lut(index,3));
           str1 = strjoin(['temp = vertcat(frame(4:end).' featureName ');'], '');
           str2 = strjoin(['temp = temp(:,' sPropIndex ':' string(propIndex+amt-1) ');'], '');
           eval(str1);
           eval(str2);
           colName = {char(strjoin([featureName '_' propName], ''))};
           Ttemp = table(temp, 'VariableNames', colName);
           output = [output Ttemp];
        end
        
        % If no properties were requested, fetch the entire feature
        if length(arg) == 1
            % If feature is a cell array, extract cell array
            if strcmp(featureName, 'tc') || strcmp(featureName, 'type') || strcmp(featureName, 'marker')
                str1 = strjoin(['temp = {frame(4:end).' featureName '}'';']);
                eval(str1);
                temp = table(temp, 'VariableNames', featureName);
                output = [output temp];
            % If feature only has 1 property, just extract it
            elseif strcmp(featureName, 'time') || strcmp(featureName, 'ms') || strcmp(featureName, 'index') || strcmp(featureName, 'centerOfMass')
                str1 = strjoin(['temp = vertcat(frame(4:end).' featureName ');']);
                eval(str1);
                temp = table(temp, 'VariableNames', featureName);
                output = [output temp];
            % Otherwise, extract all features recursively
            else
                % Use lut to find property type
                propType = char(lut(lut(:,1) == feature.string, 2));
                
                % Get list of properties based on type
                switch(propType)
                    case 'Segment'
                       paramStruct = trial.subject.segments.segment;
                    case 'FootContact'
                       paramStruct = trial.subject.footContactDefinition.contactDefinition;
                    case 'Sensor'
                       paramStruct = trial.subject.sensors.sensor;
                    case 'Joint'
                       paramStruct = trial.subject.joints.joint;
                    case 'ErgonomicJointAngle'
                       paramStruct = trial.subject.ergonomicJointAngles.ergonomicJointAngle;
                end
                
                % Construct array of properties
                paramLabels = {paramStruct.label};
                props = cell(1, length(paramLabels));
                for i = 1:length(paramLabels)
                    prop = paramLabels{i};
                    propEnums = enumeration(propType);
                    
                    % Get enums for all props in this trial
                    props{i} = propEnums(strcmp(propEnums.string, prop) == 1);
                end
                
                % Extract table of all properties
                temp = extractTrialFeatures(trial, horzcat({feature}, props));
                temp = timetable2table(temp);
                temp = removevars(temp, {'Time'});
                output = [output temp];
                
            end
        end
    end
    
    % Create timetable
    rowTimes = milliseconds([frame(4:end).time]');
    out = table2timetable(output, 'RowTimes', rowTimes);
end