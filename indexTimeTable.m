function I = indexTimeTable(T, time)
% INDEXTIMETABLE Small helper function to make indexing a timetable easier.
% The user specifies the approximate time to access in the timetable, and
% this function finds the row closest to that time.
%
%   I = indexTimeTable(T, time) returns the row index of timetable T that
%   is closest to the time specified by the duration time.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make sure time is a duration
if ~isa(time, 'duration')
    error('time variable must be a duration.');
end

% Get Time column from timetable
t = T.Time;
[~, I] = min(abs(t - time));