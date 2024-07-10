% scriptSwitchDLCAnalysis
%
% Analysis to analyze DeepLabCut labeled videos. 

cd '/Users/asbova/Documents/MATLAB' % rootpath for matlab code and data
addpath(genpath('./switch_deeplabcut'))
cd './switch_deeplabcut'

saveDirectory = './results/optoDopamine';   % Location to save the structure.
if ~exist(saveDirectory)
    mkdir(saveDirectory)
else
    % Directory already exists.
end

% Load csv files.
csvDirectory = './data/optoDopamine/dlcOutput';
videoNames = dir(fullfile(csvDirectory, '*0.csv'));
mpcDirectory = './data/optoDopamine/medpc';

% Calibration files.
imageDirectory = './data/optoDopamine/stills';
calibrationDirectory = './data/optoDopamine/calibrations';
trialStartFrames = readtable(fullfile(calibrationDirectory, 'trialStartTimes.csv'));
imageFiles = dir(fullfile(imageDirectory, '*.jpg'));
calibrationFiles = dir(fullfile(calibrationDirectory, '*.csv'));
calibrationFilenames = {calibrationFiles.name};

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
    currentMouse = extractBefore(currentVideo, '_202');
    currentDate = char(extractBetween(currentVideo, sprintf('%s_', currentMouse), '_'));

    dlcStructure(iVideo).name = currentVideo;
    dlcStructure(iVideo).mouseID = currentMouse;
    dlcStructure(iVideo).date = currentDate;
    dlcStructure(iVideo).csvPathway = fullfile(csvDirectory, videoNames(iVideo).name);
    dlcStructure(iVideo).medpcData = getMedPCdata(currentMouse, currentDate, mpcDirectory); % MedPC data

    % Import the labelling data. 
    [bodyparts, partsLocation, p] = readDLCcsv(dlcStructure(iVideo).csvPathway); 

    % Align dlc frames with trial starts.
    trialRow = find(contains(trialStartFrames.Mouse, currentMouse) & ismember(datetime(trialStartFrames.Date, 'InputFormat', 'yyyy-MM-dd'), currentDate));
    startFrames = [trialStartFrames.Trial1(trialRow), trialStartFrames.Trial2(trialRow)];
    [frameRate, alignedFrames] = alignVideoTrialsWithMedPC(startFrames, dlcStructure(iVideo).medpcData, size(p,2));

    % Load the calibration file.
    currentCalibration = readtable(fullfile(calibrationDirectory, sprintf('Measurements_%s.csv', dlcStructure(iVideo).name)));
    chamberCorners = [currentCalibration.X(1:4), currentCalibration.Y(1:4)];
    dlcStructure(iVideo).corners = chamberCorners;
    dlcStructure(iVideo).calibrationPoints = [currentCalibration.X(5:end), currentCalibration.Y(5:end)];

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
    imageIndex = find(contains({imageFiles.name}, currentVideo));
    currentImage = imread(fullfile(imageDirectory, imageFiles(imageIndex).name)); % Load the current image.
    imagePoints = [];
    imagePoints(:,:,1) = dlcStructure(iVideo).calibrationPoints(1:24,:);   
    if size(dlcStructure(iVideo).calibrationPoints, 1) == 48
        imagePoints(:,:,2) = dlcStructure(iVideo).calibrationPoints(25:end,:);
    elseif size(dlcStructure(iVideo).calibrationPoints, 1) == 72
        imagePoints(:,:,2) = dlcStructure(iVideo).calibrationPoints(25:48,:);
        imagePoints(:,:,3) = dlcStructure(iVideo).calibrationPoints(49:end,:);
    elseif size(dlcStructure(iVideo).calibrationPoints, 1) == 96
        imagePoints(:,:,2) = dlcStructure(iVideo).calibrationPoints(25:48,:);
        imagePoints(:,:,3) = dlcStructure(iVideo).calibrationPoints(49:72,:);
        imagePoints(:,:,4) = dlcStructure(iVideo).calibrationPoints(73:end,:);
    end
    dlcStructure(iVideo).convertedPartsLocation = calibrateDLC(currentImage, imagePoints, dlcStructure(iVideo).partsLocation, currentVideo);

    % Calculate kinematics 
    kinematicData = calculateKinematicsSwitch(dlcStructure(iVideo), bodypartToTrack, trialBuffer);
    dlcStructure(iVideo).smoothedTrajectories = kinematicData.smoothedTrajectories;
    dlcStructure(iVideo).velocity = kinematicData.velocity;
    dlcStructure(iVideo).distanceTraveled = kinematicData.distanceTraveled;
    
end

save(fullfile(saveDirectory, 'dlcData.mat'), 'dlcStructure');