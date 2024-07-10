% scriptCameraCalibrationCheckerboard

cd '/Users/asbova/Documents/MATLAB'                              % Rootpath for matlab code and data.
addpath(genpath('./switch_deeplabcut'))
cd './switch_deeplabcut'

videoFolder = './data/calibrationTest/calibrationVideos';
videoFiles = dir(fullfile(videoFolder, '*.mp4'));

imageDirectory = './data/calibrationTest/calibrationImages';     % Location to save images.
if ~exist(imageDirectory)
    mkdir(imageDirectory)
else
    % Directory already exists.
end

squareSize = 1; % Size of each checkerboard square (cm).

% Load in videos and extract random frames.
nFramesToExtract = 10;
for iVideo = 1 : length(videoFiles)
    currentVideoName = extractBefore(videoFiles(iVideo).name, '.mp4');      % Make a new folder for each video to store calibration images.
    videoFolderDirectory = fullfile(imageDirectory, currentVideoName);
    mkdir(videoFolderDirectory);

    currentVideo = VideoReader(fullfile(videoFolder, videoFiles(iVideo).name));     % Extract the frames from the current video and save as .jpg.
    videoFrames = read(currentVideo);
    nFrames = size(videoFrames, 4);
    framesToPull = round((nFrames - 1) .* rand(nFramesToExtract, 1) + 1);
    for iFrame = framesToPull'
        outputFilename = fullfile(videoFolderDirectory, sprintf('%s_Frame%d.jpg', currentVideoName, iFrame));
        imwrite(videoFrames(:,:,:,iFrame), outputFilename, 'jpg');
    end
end

% Get camera extrinsics and save into a data structure.
dlcStructure = [];
for iVideo = 1 : length(videoFiles)
    % Grab all images from a single video.
    currentVideoName = extractBefore(videoFiles(iVideo).name, '.mp4');
    dlcStructure(iVideo).mouseID = extractBefore(currentVideoName, '_');
    dlcStructure(iVideo).date = char(extractBetween(currentVideoName, sprintf('%s_', dlcStructure(iVideo).mouseID), '_'));

    currentImages = imageDatastore(fullfile(imageDirectory, currentVideoName));

    % Detect the checkerboard points in the images.
    [imagePoints, boardSize] = detectCheckerboardPoints(currentImages.Files);
    worldPoints = generateCheckerboardPoints(boardSize, squareSize);

    % Calibrate the camera.
    currentImage = imread(currentImages.Files{1});  % Get the image size
    imageSize = [size(currentImage, 1), size(currentImage, 2)];
    [cameraParams, imagesUsed, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, 'ImageSize', imageSize);
    cameraIntrinsics = cameraParams.Intrinsics;

    figure; 
    showExtrinsics(cameraParams, "CameraCentric");

    % Undistort a sample image.
    [undistortedImage, newOrigin] = undistortImage(currentImage, cameraParams, OutputView = 'full');
    % figure; 
    % imshow(currentImage);
    % title('Original Image');
    % figure;
    % imshow(undistortedImage)
    % title('Undistorted Image');

     % Estimate extrinsic parameters of the camera.
    [imagePoints, boardSize] = detectCheckerboardPoints(undistortedImage);
    imagePoints = imagePoints + newOrigin.PrincipalPoint;
    dlcStructure(iVideo).cameraExtrinsics = estimateExtrinsics(imagePoints, worldPoints, cameraIntrinsics);

end

