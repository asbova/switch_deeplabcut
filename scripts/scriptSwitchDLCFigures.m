% scriptSwitchDLCFigures
%
% Creates figures with DLC movement data. 

addpath(genpath('./switch_deeplabcut'))
cd './switch_deeplabcut'

resultsFolder = './results/calibrationTest';
load(fullfile(resultsFolder, 'dlcData.mat'));

% Plot the average velocity across each session for long vs. short trials.
plotAverageVelocitySwitch([dlcStructure(:).velocity], [dlcStructure(:).frameRate]);

% Plot the trajectories
for iSession = 1 : length(dlcStructure)
    plotTrajectoriesSwitch([dlcStructure(iSession).smoothedTrajectories], dlcStructure(iSession).convertedChamberCorners);
    saveas(gcf, fullfile(resultsFolder, sprintf('figures/%s_trajectoriesV4.png', dlcStructure(iSession).mouseID)));
    close all;
end

% Plot heat maps 
for iSession = 1 : length(dlcStructure)
    plotHeatMapsDLC([dlcStructure(iSession).smoothedTrajectories])

end
