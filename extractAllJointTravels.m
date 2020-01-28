function out = extractAllJointTravels(trial, ts, te)
% EXTRACTALLJOINTTRAVELS Computes joint travel between specified start and
% end times for all joints in a particular trial.
%
%   out = extractAllJointTravels(trial, ts, te) Returns a row vector
%   containing the travel of all joints in trial between the times of ts
%   and te.
%
%   o trial is an MVNX structure returned by the load_mvnx function.
%
%   o ts is a duration representing the start time.
%
%   o te is a duration representing the end time.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Extract table of all joint angles from the trial
jointAngles = extractTrialFeatures(trial, {Feature.jointAngle}, {Feature.jointAngleErgo});

% Compute start and end indices into jointAngles timetable
startIndex = indexTimeTable(jointAngles, ts);
endIndex = indexTimeTable(jointAngles, te);

tstart = jointAngles(startIndex, :);
tend = jointAngles(endIndex, :);

% Calculate travel for all joint angles 
% travel = endAngle - startAngle
for i = 1:width(tend)
    tend.(i) = tend.(i) - tstart.(i);
end

% Convert to a table
tend = timetable2table(tend);
tend = removevars(tend, {'Time'});

% Split joint angle measurements into their xyz components
vars = tend.Properties.VariableNames;
newVars = {};
tend = table2array(tend);
for i = 1:length(vars)
    old = vars{i};
    newVars = horzcat(newVars, join([old, '_X'], ''), join([old, '_Y'], ''), join([old, '_Z'], ''));
end

tend = array2table(tend, 'VariableNames', newVars);

% Calculate average travel for certain joints
targets = tend.Properties.VariableNames(contains(tend.Properties.VariableNames, 'Left'));
for i = 1:length(targets)
    leftName = targets{i};
    rightName =strrep(leftName, 'Left', 'Right');
    avgName = strrep(leftName, 'Left', 'Avg');
    left = tend.(leftName);
    right = tend.(rightName);
    avg = (left + right) / 2;
    avgT = table(avg, 'VariableNames', {avgName});
    tend = [tend avgT];
end

% Calculate absolute value of travel for all joint angles
for i = 1:width(tend)
    value = tend.(i);
    name = tend.Properties.VariableNames(i);
    newName = join(['abs', name], '');
    absT = table(abs(value), 'VariableNames', newName);
    tend = [tend absT];
end

out = tend;
    

