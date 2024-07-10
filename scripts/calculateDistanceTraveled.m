function [euclidianDistance] = calculateDistanceTraveled(positions)
%
% Calculate distance traveled within trials.
%
% INPUTS:
%  positions:               cell array of positions for each trial 
%
% OUTPUTS:
%   euclidianDistance:      nTrials x nPoints array containing the euclidian distance traveled between each frame

    nTrials = size(positions,1);
    euclidianDistance = NaN(nTrials, size(positions{1,1},1) - 1);
    for iTrial = 1 : nTrials
            nPoints = size(positions{iTrial,1},1) - 1;
            xyDifference = diff(positions{iTrial,1},1,1);
            euclidianDistance(iTrial, 1:nPoints) = sqrt(sum(xyDifference.^2,2)); % calculate euclidian distance
    end

end