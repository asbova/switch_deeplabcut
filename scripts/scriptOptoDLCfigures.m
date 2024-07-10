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


figure(1); clf;

% Plot the average velocity with laser on and laser off (just long trials for now).
subplot(1,3,[1 2]);
cla; hold on;
plotVelocityOpto(dlcStructure);

subplot(1,3,3);
cla; hold on;
plotVelocityOptoAverages(dlcStructure);


saveas(gca, fullfile(saveDirectory, 'velocityOpto.png'));
