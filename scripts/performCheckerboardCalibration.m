function [cameraIntrinsics, cameraExtrinsics]  = performCheckerboardCalibration(videoFolder, videoName, projectName)


    squareSize = 10; % Size of each checkerboard square (mm).
    videoFiles = dir(fullfile(videoFolder, '*.mp4'));
    
    imageDirectory = fullfile('./data', projectName, 'calibrationImages');               % Location to save images.
    if ~exist(imageDirectory)
        mkdir(imageDirectory)
    else
        % Directory already exists.
    end

    figureDirectory = fullfile('./results', projectName, 'calibration', videoName);
    if ~exist(figureDirectory)
        mkdir(figureDirectory)
    else
        % Directory already exists.
    end

    % Load video and extract random frames.
    nFramesToExtract = 40;
    videoFolderDirectory = fullfile(imageDirectory, videoName);
    if ~exist(videoFolderDirectory)
        mkdir(videoFolderDirectory);
    else
        delete(fullfile(pwd, videoFolderDirectory, '*.jpg'));
    end
    
    currentVideo = VideoReader(fullfile(videoFolder, sprintf('%s.mp4', videoName)));     % Extract the frames from the current video and save as .jpg.
    videoFrames = read(currentVideo);
    nFrames = size(videoFrames, 4);
    framesToPull = round((nFrames - 1) .* rand(nFramesToExtract, 1) + 1);
    for iFrame = framesToPull'
        outputFilename = fullfile(videoFolderDirectory, sprintf('%s_Frame%d.jpg', videoName, iFrame));
        imwrite(videoFrames(:,:,:,iFrame), outputFilename, 'jpg');
    end
    
    % Get camera extrinsics and save into dlcStructure.    
    currentImages = imageDatastore(fullfile(imageDirectory, videoName));                % Grab all images from a single video.

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
            
        % Undistort a sample image.
        [undistortedImage, newOrigin] = undistortImage(currentImage, cameraParams, OutputView = 'full');
        
         % Estimate extrinsic parameters of the camera.
        [undistortedImagePoints, undistortedBoardSize, ~] = detectCheckerboardPoints(undistortedImage);
        if size(undistortedImagePoints,1) > size(imagePoints, 1)    % The undistorted image detected more checkerboard points than it should, don't use this image.
            x = 0;
            imageIndex = imageIndex + 1;
        else          
            x = 1;
        end
        figure;
        imshow(undistortedImage)
        title('Undistorted Image');
        hold on;
        plot(undistortedImagePoints(:,1,1), undistortedImagePoints(:,2,1), 'go');
        saveas(gcf, fullfile(figureDirectory, 'undistortedCalibration.png'));           
    end

    undistortedImagePoints = undistortedImagePoints + newOrigin.PrincipalPoint;
    cameraExtrinsics = estimateExtrinsics(undistortedImagePoints, worldPoints, cameraIntrinsics);

    figure; 
    showExtrinsics(cameraParams, "CameraCentric");
    saveas(gcf, fullfile(figureDirectory, 'cameraExtrinsics.png'));

    figure; 
    imshow(currentImage);
    hold on;
    plot(imagePoints(:,1,imageIndex), imagePoints(:,2,imageIndex), 'ro');
    title('Original Image');
    saveas(gcf, fullfile(figureDirectory, 'originalCalibration.png'));

    
    close all;

end