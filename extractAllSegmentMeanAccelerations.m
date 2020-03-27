function out = extractAllSegmentMeanAccelerations(trial, ts, te)
% EXTRACTALLSEGMENTMEANACCELERATIONS Computes mean absolute accelerations of all
% segments between specified start and end times in a particular trial.
%
%   out = extractAllSegmentMeanAccelerations(trial, ts, te) Returns a row vector
%   containing the mean absolute accelerations in trial between the times of ts
%   and te.
%
%   o trial is an MVNX structure returned by the load_mvnx function.
%
%   o ts is a duration representing the start time.
%
%   o te is a duration representing the end time.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Extract table of all joint angles from the trial
accelerations = extractTrialFeatures(trial, {Feature.acceleration});

% Compute start and end indices into velocities timetable
startIndex = indexTimeTable(accelerations, ts);
endIndex = indexTimeTable(accelerations, te);

% Compute average absolute acceleration between start and end times
tMean = zeros(1, width(accelerations));
for i = startIndex:endIndex
    t = zeros(1, width(accelerations));
    for j = 1:width(accelerations)
        t(j) = norm(table2array(accelerations(i,j)));
    end
    tMean = tMean + t;
end
tMean = tMean / (endIndex - startIndex + 1);

% Convert to a table
vars = accelerations.Properties.VariableNames;
tMean = array2table(tMean, 'VariableNames', vars);

% Calculate average travel for certain segments
targets = tMean.Properties.VariableNames(contains(tMean.Properties.VariableNames, 'Left'));
for i = 1:length(targets)
    leftName = targets{i};
    rightName =strrep(leftName, 'Left', 'Right');
    avgName = strrep(leftName, 'Left', 'Avg');
    left = tMean.(leftName);
    right = tMean.(rightName);
    avg = (left + right) / 2;
    avgT = table(avg, 'VariableNames', {avgName});
    tMean = [tMean avgT];
end

out = tMean;
    

