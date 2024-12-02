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
    videoFrames = read(currentVideo, [100 1000]);
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
    [imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints(currentImages.Files);
    worldPoints = generateCheckerboardPoints(boardSize, squareSize);

    % Calibrate the camera.
    goodImages = find(imagesUsed == 1);
    imageIndex = 1;
    x = 0;
    while x == 0        
        currentImage = imread(currentImages.Files{goodImages(imageIndex)});  % Get the image size
        imageSize = [size(currentImage, 1), size(currentImage, 2)];
        [cameraParams, ~, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, 'ImageSize', imageSize);
        cameraIntrinsics = cameraParams.Intrinsics;
    
        % figure; 
        % showExtrinsics(cameraParams, "CameraCentric");
    
        % Undistort a sample image.
        [undistortedImage, newOrigin] = undistortImage(currentImage, cameraParams, OutputView = 'full');
        % figure; 
        % imshow(currentImage);
        % hold on;
        % plot(imagePoints(:,1,1), imagePoints(:,2,1), 'ro');
        % title('Original Image');
        % figure;
        % imshow(undistortedImage)
        % title('Undistorted Image');
        % 
         % Estimate extrinsic parameters of the camera.
        [undistortedImagePoints, undistortedBoardSize, ~] = detectCheckerboardPoints(undistortedImage);
        if size(undistortedImagePoints,1) > size(imagePoints, 1)    % The undistorted image detected more checkerboard points than it should, don't use this image.
            x = 0;
            imageIndex = imageIndex + 1;
        else          
            x = 1;
        end
        % figure;
        % imshow(undistortedImage);
        % hold on;
        % plot(undistortedImagePoints(:,1,1), undistortedImagePoints(:,2,1), 'ro');
    end

    undistortedImagePoints = undistortedImagePoints + newOrigin.PrincipalPoint;
    dlcStructure(iVideo).cameraExtrinsics = estimateExtrinsics(undistortedImagePoints, worldPoints, cameraIntrinsics);
    dlcStructure(iVideo).cameraIntrinsics = cameraIntrinsics;

end

