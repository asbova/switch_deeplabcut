function [normalizedTrajectory, interpolatedTrajectory, smoothedTrajectory] = smoothTrajectory(rawTrajectory, varargin)
% 
% Function to smooth and interpolate the trajectory points into a standard number of divisions.
%
% INPUTS
%   rawTrajectory:          m x 2 array where each row m is the number of frames and each row is an (x,y) coordinate.
%
% VARARGIN
%   numTrajectoryPoints:    number of points to divide the trajectory into
%   smoothWindow:           width of the smoothing window the rawTrajectory is passed through
%
% OUTPUTS
%   normalizedTrajectory:   numTrajectoryPoints x 2 array containing coordinates of each normalized trajectory point.
%                           This is smoothed_trajectory divided. 
%   interpolatedTrajectory: m x 2 array where m is the number of frames in rawTrajectory. This is with points
%                           interpolated to account for missing points in the 3D rawTrajectory. Uses pchip
%                           interpolation.
%   smoothed_trajectory:    m x 2 array where m is the number of frames in rawTrajectory. The smoothed_trajectory is a
%                           smoothed version of interpolatedTrajectory.

    smoothWindow = 3;
    nTrajectoryPoints = 100;    
    for iarg = 1 : 2 : nargin - 1
        switch lower(varargin{iarg})
            case 'numtrajectorypoints'
                nTrajectoryPoints = varargin{iarg + 1};
            case 'smoothwindow'
                smoothWindow = varargin{iarg + 1};
        end
    end
    
    nFramesTrue = size(rawTrajectory, 1);
    % Clip rawTrajectory to remove any NaN's from the beginning or end of the trajectory.
    if isnan(rawTrajectory(1,1))
        firstValidFrame = find(~isnan(rawTrajectory(:,1)),1);
        rawTrajectory = rawTrajectory(firstValidFrame:end,:);
    end
    if isnan(rawTrajectory(end,1))
        lastValidFrame = find(~isnan(rawTrajectory(:,1)),1,'last');
        rawTrajectory = rawTrajectory(1:lastValidFrame,:);
    end


    interpolatedTrajectory = zeros(size(rawTrajectory));
    smoothedTrajectory = zeros(size(rawTrajectory));
    nFrames = size(rawTrajectory,1);
    
    if nFrames < 2
       normalizedTrajectory = NaN(nTrajectoryPoints,2);
       interpolatedTrajectory = NaN(1,2);
       smoothedTrajectory = NaN(1,2);
    else
        for iDimension = 1 : size(rawTrajectory,2)
            interpolatedTrajectory(:,iDimension) = pchip(1:nFrames, rawTrajectory(:,iDimension), 1:nFrames);
            smoothedTrajectory(:,iDimension) = smooth(interpolatedTrajectory(:,iDimension), smoothWindow);
        end
    
        normalizedTrajectory = evenlySpacedPointsAlongTrajectory(smoothedTrajectory, nTrajectoryPoints);
    end

    if exist('firstValidFrame')
        truncatedSmoothedTrajectory = smoothedTrajectory;
        nPoints = size(truncatedSmoothedTrajectory, 1) + firstValidFrame-1;
        smoothedTrajectory(1 : firstValidFrame-1, :) = NaN;
        smoothedTrajectory(firstValidFrame : nPoints, :) = truncatedSmoothedTrajectory;
        if exist('lastValidFrame')
            smoothedTrajectory(lastValidFrame + firstValidFrame : nFramesTrue, :) = NaN;
        end
    end

    if exist('lastValidFrame') & ~exist('firstValidFrame')
        smoothedTrajectory(lastValidFrame + 1 : nFramesTrue, :) = NaN;
    end
    


end