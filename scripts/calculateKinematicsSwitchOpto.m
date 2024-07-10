function calculateKinematicsSwitchOpto(dlcData, bodypart)
%
% Identify which points are valid to use for movement tracking analysis. 
%
% Input: 
%       dlcData:                structure containing the DLC marked points, behavioral data, and trial information
%       bodypart:               bodypart that will have kinematics analyzed for                  
%
% Output: 
%       

    nTrials = length(dlcData.trialStartFrames);

    % Extract positional data based on trial type.
    shortTrials = find(cellfun(@(x) x == 6000, {dlcData.medpcData.programmedDuration}));
    longTrials = find(cellfun(@(x) x == 18000, {dlcData.medpcData.programmedDuration}));

    laserOnTrials = find(cellfun(@(x) x == 0, {dlcData.medpcData.opto}));
    laserOffTrials = find(cellfun(@(x) x == 1, {dlcData.medpcData.opto}));
    shortLaserOnTrials = intersect(shortTrials, laserOnTrials);
    shortLaserOffTrials = intersect(shortTrials, laserOffTrials);
    longLaserOnTrials = intersect(longTrials, laserOnTrials);
    longLaserOffTrials = intersect(longTrials, laserOffTrials);

    shortLaserOnTrialXY = NaN(length(shortLaserOnTrials), dlcData.frameRate*6, 2);
    shortLaserOffTrialXY = NaN(length(shortLaserOffTrials), dlcData.frameRate*6, 2);
    longLaserOnTrialXY = NaN(length(longLaserOnTrials), dlcData.frameRate*18, 2);
    longLaserOffTrialXY = NaN(length(longLaserOffTrials), dlcData.frameRate*18, 2);
    shortOnIndex = 1;
    shortOffIndex = 1;
    longOnIndex = 1;
    longOffIndex = 1;
    for iTrial = 1 : nTrials
        if ismember(iTrial, shortLaserOnTrials)
            currentFrames = dlcData.trialStartFrames(iTrial) : (dlcData.trialStartFrames(iTrial) + dlcData.frameRate*6)-1;
            shortLaserOnTrialXY(shortOnIndex,:,:) = dlcData.partsLocation(bodypart, currentFrames, :);
            shortOnIndex = shortOnIndex + 1;
        elseif ismember(iTrial, shortLaserOffTrials)
            currentFrames = dlcData.trialStartFrames(iTrial) : (dlcData.trialStartFrames(iTrial) + dlcData.frameRate*6)-1;
            shortLaserOffTrialXY(shortOffIndex,:,:) = dlcData.partsLocation(bodypart, currentFrames, :);
            shortOffIndex = shortOffIndex + 1;
        elseif ismember(iTrial, longLaserOnTrials)
            currentFrames = dlcData.trialStartFrames(iTrial) : (dlcData.trialStartFrames(iTrial) + dlcData.frameRate*18)-1;
            longLaserOnTrialXY(longOnIndex,:,:) = dlcData.partsLocation(bodypart, currentFrames, :);
            longOnIndex = longOnIndex + 1;
        elseif ismember(iTrial, longLaserOffTrials)
            currentFrames = dlcData.trialStartFrames(iTrial) : (dlcData.trialStartFrames(iTrial) + dlcData.frameRate*18)-1;
            longLaserOffTrialXY(longOffIndex,:,:) = dlcData.partsLocation(bodypart, currentFrames, :);
            longOffIndex = longOffIndex + 1;
        end
    end