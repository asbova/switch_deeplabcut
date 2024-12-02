function newWorldPoints = calibrateDLC(calibrationImage, imagePoints, partsLocation, videoName)
%
% Identify which points are valid to use for movement tracking analysis. 
%
% Input: 
%       calibrationImage:       still frame from video to be calibrated
%       imagePoints:            X, Y pixel locations of labeled bars for calibrating the camera    
%       partsLocation:          DLC-generated bodyparts locations for the entire video (part x frame x X,Y)
%
% Output: 
%       dlcData:                appended dlcData structure with kinematic data added.      


    % The real world points of the marked bars (in mm). 
    worldPoints = [0 0; 18 0; 36 0; 54 0; 72 0; 90 0; 108 0; 126 0; 144 0; 162 0; 180 0; 198 0; ...
        198 180; 180 180; 162 180; 144 180; 126 180; 108 180; 90 180; 72 180; 54 180; 36 180; 18 180; 0 180];
    imageSize = [size(calibrationImage, 1), size(calibrationImage, 2)];

    params = estimateCameraParameters(imagePoints, worldPoints, 'ImageSize', imageSize);
    intrinsics = params.Intrinsics;

    figure; 
    imshow(calibrationImage); 
    hold on;
    plot(imagePoints(:,1,1), imagePoints(:,2,1),'go');
    plot(params.ReprojectedPoints(:,1,1),params.ReprojectedPoints(:,2,1),'r+');
    legend('Detected Points','ReprojectedPoints');
    hold off;
    saveas(gcf, sprintf('./results/optoDopamine/calibration/%s.jpg', videoName))
    close all;

    % % Undistort the calibration image.
    % [undistortedImage, newOrigin] = undistortImage(calibrationImage, params);
    % imwrite(undistortedImage, sprintf('./results/timeVsMovement/calibration/Undistorted_%s.jpg', videoName))
    % 
    % % subplot(2,1,1);
    % % imshow(calibrationImage);
    % % title('Original Image');
    % % subplot(2,1,2);
    % % imshow(undistortedImage);
    % % title('Undistorted Image');
    % % 
    % 
    % undistortedImagePoints = readtable('./results/timeVsMovement/calibration/Undistorted_MOO3_2023-09-01_09-15-25_points.csv');
    % undistortedImagePoints = [undistortedImagePoints.X, undistortedImagePoints.Y];
    % undistortedImagePoints = undistortedImagePoints + newOrigin.PrincipalPoint;
    extrinsics = estimateExtrinsics(imagePoints(:,:,1), worldPoints, intrinsics);

    newWorldPoints = NaN(size(partsLocation));
    for iBodypart = 1 : size(partsLocation, 1)
        newWorldPoints(iBodypart, :, :) = img2world2d(squeeze(partsLocation(iBodypart,:,:)), extrinsics, intrinsics);
    end

end



    
