function out = extractAllSegmentMeanVelocities(trial, ts, te)
% EXTRACTALLSEGMENTMEANVELOCITIES Computes mean absolute velocities of all
% segments between specified start and end times in a particular trial.
%
%   out = extractAllSegmentMeanVelocities(trial, ts, te) Returns a row vector
%   containing the mean absolute velocities in trial between the times of ts
%   and te.
%
%   o trial is an MVNX structure returned by the load_mvnx function.
%
%   o ts is a duration representing the start time.
%
%   o te is a duration representing the end time.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Extract table of all joint angles from the trial
velocities = extractTrialFeatures(trial, {Feature.velocity});

% Compute start and end indices into velocities timetable
startIndex = indexTimeTable(velocities, ts);
endIndex = indexTimeTable(velocities, te);

% Compute average absolute velocity between start and end times
tMean = zeros(1, width(velocities));
for i = startIndex:endIndex
    t = zeros(1, width(velocities));
    for j = 1:width(velocities)
        t(j) = norm(table2array(velocities(i,j)));
    end
    tMean = tMean + t;
end
tMean = tMean / (endIndex - startIndex + 1);


% Convert to a table
vars = velocities.Properties.VariableNames;
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
    

