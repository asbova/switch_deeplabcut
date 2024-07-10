function plotVelocityOpto(dlcData)

% Plot the average velocity for trials with laser off vs. trials with laser on.
%
% INPUTS:
%   dlcData:            Data structure with DLC kinematics for individual mouse sessions.
%
% OUTPUTS:
%   figure
%


    intervalLimit = [-4 22];
    onColor = [246 176 12] ./ 255;
    offColor = 'k'; 

    nSessions = length(dlcData);
    for iSession = 1 : nSessions

        % Determine which trials are laser on and which are laser off.
        behaviorData = dlcData(iSession).medpcData;
        longTrials = find(cellfun(@(x) x == 18000, {behaviorData.programmedDuration}));
        laserOnTrials = find(cellfun(@(x) x == 0, {behaviorData.opto}));
        laserOffTrials = find(cellfun(@(x) x == 1, {behaviorData.opto}));
        laserOnRows = ismember(longTrials, laserOnTrials);
        laserOffRows = ismember(longTrials, laserOffTrials);

        laserOnVelocity = dlcData(iSession).velocity.LongTrials(laserOnRows, :);
        laserOffVelocity = dlcData(iSession).velocity.LongTrials(laserOffRows, :);

        averageLaserOnVelocity(iSession, :) = mean(laserOnVelocity, 1, 'omitnan');
        averageLaserOffVelocity(iSession, :) = mean(laserOffVelocity, 1, 'omitnan');
    end


    acrossMouseAverageOn = mean(averageLaserOnVelocity);
    acrossMouseSTDon = std(averageLaserOnVelocity, 0, 1) ./ sqrt(nSessions);
    acrossMouseAverageOff = mean(averageLaserOffVelocity);
    acrossMouseSTDoff = std(averageLaserOffVelocity, 0, 1) ./ sqrt(nSessions);

    x = intervalLimit(1) + 1/60 : 1/60 : intervalLimit(2);
    xline(0, '--');
    plotband(x(1:end-1), acrossMouseAverageOff, acrossMouseSTDoff, offColor);
    plotband(x(1:end-1), acrossMouseAverageOn, acrossMouseSTDon, onColor);
    xlim(intervalLimit);
    xticks([-4 0 6 12 18 22]);
    ylabel('Velocity (mm/s)');
    xlabel('Time from Trial Start (s)');
    legend('', '', 'Laser Off', '', 'Laser On');
    set(gca, 'FontSize', 14)