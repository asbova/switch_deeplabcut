% scriptOptoDLCfigures

cd '/Users/asbova/Documents/MATLAB'                 % Rootpath for matlab code and data.
addpath(genpath('./switch_deeplabcut'))
cd './switch_deeplabcut'

saveDirectory = './results/optoDopamine/figures';   % Location to save the figures.
if ~exist(saveDirectory)
    mkdir(saveDirectory)
else
    % Directory already exists.
end

load('./results/optoDopamine/dlcData.mat');         % Load the DLC data structure.


fig = figure('Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.7, 0.5]);

% Plot the average velocity with laser on and laser off (just long trials for now).
subplot(1,4,[1 2]);
cla; hold on;
plotVelocityOpto(dlcStructure);

subplot(1,4,3);
cla; hold on;
plotVelocityOptoAverages(dlcStructure);

subplot(1,4,4);
cla; hold on;
plotSwitchOptoAverages(trialDataStructure)

% Save figure.
origUnits = fig.Units;
fig.Units = fig.PaperUnits; 
fig.PaperSize = fig.Position(3:4);
fig.Units = origUnits;
saveas(fig, fullfile(saveDirectory, 'velocityOpto.pdf'));


