function [frameRate, alignedFrames] = alignVideoTrialsWithMedPC(videoFrames, medpcData, nFrames)
%
% Aligns the video frames to trial starts. 
%
% Input: 
%       videoFrames:        Frame numbers of "cues on" for first two trials.
%       medpcData:          Trial by trial data of behavioral events from MedPC.
%       nFrames:            The number of frames in the full video.
%
% Output: 
%       frameRate:          The frame rate of the video in frames per second (60 or 30);
%       alignedFrames:      The frame numbers of "cues on" for all trials in the video.

    % Determine the frame rate.
    if (abs((nFrames/60/60) - 90)) < (abs((nFrames/60/30) - 90))
        frameRate = 60;     % Frames per second.
    else
        frameRate = 30;
    end

    % Find the difference between video frames and trial start and align frames.
    trialStartTimesMPC = [medpcData.realTrialStart]*frameRate;
    frameDifference = videoFrames - trialStartTimesMPC(1,1:2);
    alignedFrames = round(trialStartTimesMPC + mean(frameDifference));

end