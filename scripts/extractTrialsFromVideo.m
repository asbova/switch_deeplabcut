% script_trimVideosIntoTrials


videoDirectory = '/Users/asbova/Documents';
cd(videoDirectory)

filename = 'E2BM3_2024-07-09_09-07-47.mp4';
video = VideoReader(filename);
frameRate = video.FrameRate;
videoDuration = video.Duration;
nFrames = frameRate * videoDuration;

% Extract medpc data
protocols = {'Switch_6L18R_SITI_REINFORCE_FP_V3'};
medpcDataPathway = '/Users/asbova/Documents/MATLAB/switch_deeplabcut/data/medpc';
mouseIDs = 'E2BM3';
dateRange = {'2024-07-09', '2024-07-09'};    
mpcParsed = getDataIntr(medpcDataPathway, protocols, mouseIDs, dateRange);
trialDataStructure = getTrialData(mpcParsed);
behaviorData = trialDataStructure.E2BM3;

startFrame = 3289;
threshold = 1000000;
time = startFrame / frameRate;
lightOn = 0;
trialNumber = 0;
trialTimes = [];
tic;
while time <= videoDuration

    video.CurrentTime = time;
    videoFrame = readFrame(video);
    binaryFrame = rgb2gray(videoFrame);
    
    if time == startFrame / frameRate                                           % Set the ROI for the cue light.
        imshow(binaryFrame);
        fprintf('DRAW YOUR RECTANGLE AROUND CUE LIGHT')
        roi = drawrectangle;
        ledPosition = roi.Position;
        yValues = round(ledPosition(2) : ledPosition(2) + ledPosition(4));
        xValues = ledPosition(1) : ledPosition(1) + ledPosition(3);
        close all;
    end

    whitePixels = sum(sum(binaryFrame(yValues, xValues)));
    if whitePixels >= threshold && lightOn == 0             % Light just turned on (trial start).
        toc;
        lightOn = 1;
        trialNumber = trialNumber + 1;
        trialTimes(trialNumber, 1) = video.CurrentTime;
        trialDuration = behaviorData(trialNumber).programmedDuration / 1000;   
        itiDuration = behaviorData(trialNumber + 1).ITI + behaviorData(trialNumber + 1).initiationRT + behaviorData(trialNumber).RT - 0.8;
        time = time + trialDuration + itiDuration;

    % elseif whitePixels < threshold && lightOn == 1          % Light just turned off (trial end).
    %     lightOn = 0;
    %     trialTimes(trialNumber, 2) = video.CurrentTime;
    %     if trialNumber == size(trialDataStructure.FNE5, 2)  % Last trial.
    %         break;
    %     else
    %         itiDuration = behaviorData(trialNumber + 1).ITI + behaviorData(trialNumber + 1).initiationRT + behaviorData(trialNumber).RT - 0.1;
    %     end
    %     time = time + itiDuration;

    else
        time = time + (1 / frameRate);
    end

end
toc;



tic;
time = 0;
while time < 50
    video.CurrentTime = time;
    videoFrame = readFrame(video);
    binaryFrame = rgb2gray(videoFrame);
    % whitePixels = sum(sum(binaryFrame(yValues, xValues)));
    time = time + (1 / frameRate);
end
toc;