function [normalizedTrajectories,smoothedTrajectories,interpolatedTrajectories] = interpolateTrajectories(allTrajectories)
%
% Function to interpolate trajectories, accounting for missed frames/occlusions.
% Will divide each trajectory into evenly spaced segments.
%
% INPUTS
%   allTrajectories:            nTrials x nFrames x 2 array containing X and Y bodypart positions
%
% OUTPUTS
%   normalizedTrajectories:     num_trajectorypoints x 3 x
%                               numTrials array containing trajectories that were interpolated,
%                               smoothed, and divided into num_pd_trajectorypoints
%   smoothedTrajectories:       numTrials x 1 cell array containing smoothed
%                               versions of interp_pd_trajectories
%   interpolatedTrajectories:   numTrials x 1 cell array containing
%                               trajectories with missing points interpolated. Only includes the
%                               points from the first time the paw dorsum was detected to full
%                               extension on the initial reach

smoothWindow = 3;
nTrajectoryPoints = 300; % Should consider what this number should be. May not even want to calculate this.

nTrials = size(allTrajectories,1);

% Extract points
normalizedTrajectories = zeros(nTrajectoryPoints, 2, nTrials);
smoothedTrajectories = cell(nTrials,1);
interpolatedTrajectories = cell(nTrials,1);

for iTrial = 1 : nTrials
    currentTrajectory = squeeze(allTrajectories(iTrial,:,:));
    if all(isnan(currentTrajectory(:))) || sum(~isnan(currentTrajectory(:))) < 3
        % No points were identified in the current trajectory.
        normalizedTrajectories(:,:,iTrial) = NaN;
        smoothedTrajectories{iTrial} = NaN;
        interpolatedTrajectories{iTrial} = NaN;
        continue;
    end
    
    try
    [normalizedTrajectories(:,:,iTrial), interpolatedTrajectories{iTrial}, smoothedTrajectories{iTrial},] = ...
        smoothTrajectory(currentTrajectory, 'numtrajectoryPoints', nTrajectoryPoints, 'smoothwindow', smoothWindow);
    catch
        keyboard
    end
   
end

end