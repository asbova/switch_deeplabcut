function normalizedTrajectory = evenlySpacedPointsAlongTrajectory(trajectory, varargin)
%
% Function to divide a trajectory into evenly spaced points.
%
% INPUTS
%   trajectory:     m x 2 array where each row m is the number of frames and each row is an (x,y) coordinate.
%
% VARARGIN
%   nPointsOut:     number of points to divide the trajectory into
%
% OUTPUTS
%   pointsOut:      nPointsOut x 2 array containing the initial trajectory divided into nPointsOut points. 


nPointsOut = 100;
if nargin == 2
    nPointsOut = varargin{1};
end

lengthOfPath = pathlength(trajectory);
distancePerPoint = lengthOfPath / (nPointsOut-1);

normalizedTrajectory = zeros(nPointsOut,size(trajectory,2));
normalizedTrajectory(1,:) = trajectory(1,:);
normalizedTrajectory(nPointsOut,:) = trajectory(end,:);

currentTrajectoryIndex = 1;
for iPoint = 2 : nPointsOut-1
    
    startPoint = normalizedTrajectory(iPoint-1,:);
    
    distanceAlongTrajectory = 0;
    while distanceAlongTrajectory < distancePerPoint
        currentTrajectoryIndex = currentTrajectoryIndex + 1;
        if distanceAlongTrajectory == 0
            currentPoint = startPoint;
        else
            currentPoint = trajectory(currentTrajectoryIndex-1,:);
        end
        
        previousDistanceAlongTrajectory = distanceAlongTrajectory;
        distanceAlongTrajectory = distanceAlongTrajectory + sqrt(sum((trajectory(currentTrajectoryIndex,:) - currentPoint).^2,2));
    end

    try
    remainingDistance = distancePerPoint - previousDistanceAlongTrajectory;
    catch
        keyboard
    end
    
    normalizedTrajectory(iPoint,:) = findPointAlongLine(currentPoint, trajectory(currentTrajectoryIndex,:), remainingDistance);
	currentTrajectoryIndex = currentTrajectoryIndex - 1;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pt = findPointAlongLine(startPt, endPt, ptDist)

fullDist = sqrt(sum((endPt-startPt).^2,2));
fractDist = ptDist/fullDist;

pt = startPt + (endPt-startPt)*fractDist;

end
