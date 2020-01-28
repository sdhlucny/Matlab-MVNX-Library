function Y = extractMeasurement(trial, feature, index)
%  EXTRACTMEASUREMENT Extracts frames for a single feature-property pair from
%  a trial. To use this function, the user needs to be aware of the exact
%  feature name and relative index of the property that is to be accessed.
% 
%  WARNING: THIS IS AN OUTDATED VERSION OF THIS FUNCTION LEFT IN THE LIBRARY
%  FOR LEGACY PURPOSES. FOR EASIER FEATURE EXTRACTION, USE
%  extractTrialFeatures FUNCTION.
% 
%     Y = extractMeasurement(trial, feature, index)
%     
%     o trial is an MVNX structure returned by the load_mvnx function.
% 
%     o feature is a string containing the exact name of the feature to
%     extract.
% 
%     o index is the relative index of the property to extract.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Get the frame structure from the trial
    frame = trial.subject.frames.frame;
    % Find the number of frames (skip the first 3 calibration frames)
    numFrames = size(frame, 2) - 3;
    
    % Create arrays to populate
    rowTimes = zeros(numFrames, 1);
    data = zeros(numFrames, 1);
    
    for i = 1:numFrames
       rowTimes(i) = frame(i+3).time;
       eval(['data(i) = frame(i+3).' feature '(' num2str(index) ');']);
    end
    % Convert row times to milliseconds
    rowTimes = milliseconds(rowTimes);
    
    % Construct time table
    featureName = [feature '_' num2str(index)];
    Y = array2timetable(data, 'RowTimes', rowTimes, 'VariableNames', {featureName});
    
    if nargout == 0
        % Plot the measurements
        figure();
        eval(['plot(Y.Time, Y.' feature ');']);
    end
end