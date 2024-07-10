function kinematicData = calculateKinematicsSwitch(dlcData, bodypart, trialBuffer)
%
% Identify which points are valid to use for movement tracking analysis. 
%
% Input: 
%       dlcData:                structure containing the DLC marked points, behavioral data, and trial information
%       bodypart:               bodypart that will have kinematics analyzed for      
%       trialBuffer:            the amount of time (in seconds) appended before and after trial start and end to analyze
%
% Output: 
%       dlcData:                appended dlcData structure with kinematic data added.      


    nTrials = length(dlcData.trialStartFrames);
    trialFrameBuffer = dlcData.frameRate*trialBuffer;
    nPointsShort = dlcData.frameRate*(6 + trialBuffer*2);
    nPointsLong = dlcData.frameRate*(18 + trialBuffer*2);

    % Extract positional data based on trial type.
    shortTrials = find(cellfun(@(x) x == 6000, {dlcData.medpcData.programmedDuration}));
    longTrials = find(cellfun(@(x) x == 18000, {dlcData.medpcData.programmedDuration}));   
    shortTrialXY = NaN(length(shortTrials), nPointsShort, 2);    
    longTrialXY = NaN(length(longTrials), nPointsLong, 2);
    shortIndex = 1;
    longIndex = 1;
    for iTrial = 1 : nTrials
        if ismember(iTrial, shortTrials)
            currentFrames = dlcData.trialStartFrames(iTrial) - trialFrameBuffer : (dlcData.trialStartFrames(iTrial) + (dlcData.frameRate*(6 + trialBuffer)) -1);
            shortTrialXY(shortIndex,:,:) = dlcData.convertedPartsLocation(bodypart, currentFrames, :);
            shortIndex = shortIndex + 1;
        elseif ismember(iTrial, longTrials)
            currentFrames = dlcData.trialStartFrames(iTrial) - trialFrameBuffer : (dlcData.trialStartFrames(iTrial) + (dlcData.frameRate*(18 + trialBuffer)) -1);
            longTrialXY(longIndex,:,:) = dlcData.convertedPartsLocation(bodypart, currentFrames, :);
            longIndex = longIndex + 1;
        end
    end

    % Interpolate trajectories
    warning off
    [normalizedTrajectoriesShortTrials, smoothedTrajectoriesShortTrials, interpolatedTrajectoriesShortTrials] = interpolateTrajectories(shortTrialXY);
    [normalizedTrajectoriesLongTrials, smoothedTrajectoriesLongTrials, interpolatedTrajectoriesLongTrials] = interpolateTrajectories(longTrialXY);
    warning on

    % Calculate velocity (pixels/second).
    [velocityShortTrials, tangentialVelocityShortTrials] = calculateVelocity(smoothedTrajectoriesShortTrials, dlcData.frameRate, nPointsShort);
    [velocityLongTrials, tangentialVelocityLongTrials] = calculateVelocity(smoothedTrajectoriesLongTrials, dlcData.frameRate, nPointsLong);

    % Calculate average distance traveled (pixels).
    euclidianDistanceShort = calculateDistanceTraveled(smoothedTrajectoriesShortTrials);
    euclidianDistanceLong = calculateDistanceTraveled(smoothedTrajectoriesLongTrials);

    kinematicData.smoothedTrajectories.ShortTrials = smoothedTrajectoriesShortTrials;
    kinematicData.smoothedTrajectories.LongTrials = smoothedTrajectoriesLongTrials;
    kinematicData.velocity.ShortTrials = tangentialVelocityShortTrials;
    kinematicData.velocity.LongTrials = tangentialVelocityLongTrials;
    kinematicData.distanceTraveled.ShortTrials = euclidianDistanceShort;
    kinematicData.distanceTraveled.LongTrials = euclidianDistanceLong;


end

