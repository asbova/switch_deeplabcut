% scriptSwitchDLCAnalysisCheckerboard
%
% Analysis to analyze DeepLabCut labeled videos. 

cd '/Users/asbova/Documents/MATLAB' % rootpath for matlab code and data
addpath(genpath('./switch_deeplabcut'))
cd './switch_deeplabcut'

projectName = 'timeVsMovement';    
saveDirectory = fullfile('./results', projectName);   % Location to save the structure.
if ~exist(saveDirectory)
    mkdir(saveDirectory)
else
    % Directory already exists.
end

% Load csv files.
csvDirectory = fullfile('./data', projectName, 'dlcOutput');
videoNames = dir(fullfile(csvDirectory, '*0.csv'));
mpcDirectory = fullfile('./data', projectName, 'medpc');

% Calibration files.
calibrationDirectory = fullfile('./data', projectName, 'calibrationVideos');          % Location of calibration videos.
calibrationVideos = dir(fullfile(calibrationDirectory, '*.mp4'));
trialStartFrames = readtable(fullfile('./data', projectName, 'trialStartTimes.csv'));

% Parameters for findInvalidPointsDLC
params.maxDistanceTraveledBetweenFrames = 15;
params.minValidP = 0.5;
params.minCertainP = 0.99;

% Analysis settings
bodypartToTrack = 6; 
trialBuffer = 4; % Amount of time before and after trial to collect kinematics through.

% Begin data structure.
dlcStructure = [];
for iVideo = 1 : length(videoNames)
    currentVideo = extractBefore(videoNames(iVideo).name, 'DLC');
    matchingCalibration = find(cellfun(@(x) strcmp(sprintf('%s.mp4', currentVideo), x), {calibrationVideos.name}));
    if isempty(matchingCalibration)
        continue;
    end
    currentMouse = extractBefore(currentVideo, '_202');
    currentDate = char(extractBetween(currentVideo, sprintf('%s_', currentMouse), '_'));

    dlcStructure(iVideo).name = currentVideo;
    dlcStructure(iVideo).mouseID = currentMouse;
    dlcStructure(iVideo).date = currentDate;
    dlcStructure(iVideo).csvPathway = fullfile(csvDirectory, videoNames(iVideo).name);
    dlcStructure(iVideo).medpcData = getMedPCdata(currentMouse, currentDate, mpcDirectory); % MedPC data

    % Get camera extrinsics and intrinsics with checkerboard calibration.
    [dlcStructure(iVideo).cameraIntrinsics, dlcStructure(iVideo).cameraExtrinsics]  = performCheckerboardCalibration(calibrationDirectory, currentVideo, projectName);

    % Import the labelling data. 
    [bodyparts, partsLocation, p] = readDLCcsv(dlcStructure(iVideo).csvPathway); 

    % Align dlc frames with trial starts.
    trialRow = find(contains(trialStartFrames.Mouse, currentMouse) & ismember(datetime(trialStartFrames.Date, 'InputFormat', 'yyyy-MM-dd'), currentDate));
    startFrames = [trialStartFrames.Trial1(trialRow), trialStartFrames.Trial2(trialRow)];
    [frameRate, alignedFrames] = alignVideoTrialsWithMedPC(startFrames, dlcStructure(iVideo).medpcData, size(p,2));
    chamberCorners = [trialStartFrames.Corner1X(trialRow), trialStartFrames.Corner1Y(trialRow); ...
        trialStartFrames.Corner2X(trialRow), trialStartFrames.Corner2Y(trialRow); ...
        trialStartFrames.Corner3X(trialRow), trialStartFrames.Corner3Y(trialRow); ...
        trialStartFrames.Corner4X(trialRow), trialStartFrames.Corner4Y(trialRow)];

    % Evaluate which Deeplabcut-labelled points are invalid from entire video.
    [invalidPoints, percentInvalidPoints] = findInvalidPointsDLC(partsLocation, p, params, chamberCorners);
    for iBodypart = 1 : length(bodyparts)
        partsLocation(iBodypart, invalidPoints(iBodypart,:), :) = NaN;
    end

    dlcStructure(iVideo).frameRate = frameRate;
    dlcStructure(iVideo).trialStartFrames = alignedFrames;
    dlcStructure(iVideo).bodyparts = bodyparts;
    dlcStructure(iVideo).partsLocation = partsLocation;
    dlcStructure(iVideo).percentInvalid = percentInvalidPoints;

    % Find percentage of points invalid only within trials.
    shortTrials = find(cellfun(@(x) x == 6000, {dlcStructure(iVideo).medpcData.programmedDuration}));
    longTrials = find(cellfun(@(x) x == 18000, {dlcStructure(iVideo).medpcData.programmedDuration}));
    percentInvalidTrials = zeros(length(bodyparts), length(alignedFrames));
    for iTrial = 1 : length(alignedFrames)
        % Find frame numbers for the current trial.
        if ismember(iTrial, shortTrials)
            currentFrames = alignedFrames(iTrial) : (alignedFrames(iTrial) + frameRate*6) - 1;
        else
            currentFrames = alignedFrames(iTrial) : (alignedFrames(iTrial) + frameRate*18) - 1;
        end
        percentInvalidTrials(:, iTrial) = (sum(invalidPoints(:, currentFrames), 2) / length(currentFrames)) * 100;
    end     
    dlcStructure(iVideo).percentInvalidTrials = percentInvalidTrials;
    fprintf('\n%s: Average percentage of points (body) invalid in trials: %0.2f\n', currentMouse, mean(percentInvalidTrials(6,:)));

    % Convert DLC marked parts locations in real-world coordinates (mm).
    newWorldPoints = NaN(size(partsLocation));
    for iBodypart = 1 : size(partsLocation, 1)
        newWorldPoints(iBodypart, :, :) = img2world2d(squeeze(partsLocation(iBodypart,:,:)), dlcStructure(iVideo).cameraExtrinsics, dlcStructure(iVideo).cameraIntrinsics);
    end
    dlcStructure(iVideo).convertedPartsLocation = newWorldPoints;
    dlcStructure(iVideo).convertedChamberCorners = img2world2d(chamberCorners, dlcStructure(iVideo).cameraExtrinsics, dlcStructure(iVideo).cameraIntrinsics);

    % Calculate kinematics 
    kinematicData = calculateKinematicsSwitch(dlcStructure(iVideo), bodypartToTrack, trialBuffer);
    dlcStructure(iVideo).smoothedTrajectories = kinematicData.smoothedTrajectories;
    dlcStructure(iVideo).velocity = kinematicData.velocity;
    dlcStructure(iVideo).distanceTraveled = kinematicData.distanceTraveled;
    
end

save(fullfile(saveDirectory, 'dlcDataCheck.mat'), 'dlcStructure');