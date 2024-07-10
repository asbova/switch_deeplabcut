function [xyVelocity, tangentialVelocity] = calculateVelocity(positions, frameRate, nTrialPoints)
%
% Calculate velocity along each direction and tangential to the direction of motion
%
% INPUTS:
%   positions:              cell array of bodypart positions for each trial 
%   frameRate:              frame rate in frames per second
%   nTrialPoints:           number of frames that are evaluated for each trial
%
% OUTPUTS:
%   xyVelocity:             cell array with an entry for each trial containing the velocity along x and y directions
%   tangentialVelocity:     nTrials x nPoints array containing velocity tangential to the direction of motion

    smoothWidth = 3;
    
    nTrials = size(positions,1);
    xyVelocity = cell(nTrials,1);
    tangentialVelocity = NaN(nTrials, nTrialPoints-1);  
    
    for iTrial = 1 : nTrials
        clear firstValidFrame
        clear lastValidFrame

        % Clip rawTrajectory to remove any NaN's from the beginning or end of the trajectory.
        rawTrajectory = positions{iTrial,1};
        if isnan(positions{iTrial,1}(1,1))
            firstValidFrame = find(~isnan(rawTrajectory),1);
            rawTrajectory = positions{iTrial,1}(firstValidFrame:end,:);
        end
        if isnan(positions{iTrial,1}(end,1))
            lastValidFrame = find(~isnan(rawTrajectory(:,1)),1,'last');
            rawTrajectory = rawTrajectory(1:lastValidFrame,:);
        end

        nPoints = size(rawTrajectory,1);
        xyDifference = diff(rawTrajectory, 1, 1);
        xyVelocity{iTrial,1} = xyDifference * frameRate;
        
        for jDimension = 1 : size(xyDifference,2)
            xyVelocity{iTrial,1}(:,jDimension) = smooth(xyVelocity{iTrial,1}(:,jDimension), smoothWidth);
        end

        tempTangentialVelocity = sqrt(sum(xyDifference.^2,2)) * frameRate;
        tempTangentialVelocity = smooth(tempTangentialVelocity, smoothWidth);

        if exist('firstValidFrame')
            %truncatedSmoothedTrajectory = smoothedTrajectory;
            nPoints = size(tempTangentialVelocity, 1) + firstValidFrame-1;
            tangentialVelocity(iTrial, firstValidFrame : nPoints, :) = tempTangentialVelocity;
        else
            tangentialVelocity(iTrial, 1 : size(tempTangentialVelocity,1)) = tempTangentialVelocity;
        end
    end

end