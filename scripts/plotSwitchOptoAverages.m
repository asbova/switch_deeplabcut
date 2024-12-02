function plotSwitchOptoAverages(dlcData)

% Plot the average switch departure time for trials with laser off vs. trials with laser on.
% Plots the individual mouse averages (circles) and between mouse averages (bars).
%
% INPUTS:
%   dlcData:            Data structure containing MedPC behavioral data and DLC kinematics for individual mouse sessions.
%
% OUTPUTS:
%   figure
%


    onColor = [246 176 12] ./ 255;
    offColor = 'k'; 

    nSessions = length(dlcData);
    mouseIDs = fieldnames(dlcData);
    averageSwitch = NaN(nSessions, 2);
    for iSession = 1 : length(mouseIDs)

        % Determine which trials are laser on and which are laser off.
        behaviorData = dlcData.(char(mouseIDs(iSession)));
        longTrials = find(cellfun(@(x) x == 18000, {behaviorData.programmedDuration}));
        laserOnTrials = find(cellfun(@(x) x == 0, {behaviorData.opto}));
        laserOffTrials = find(cellfun(@(x) x == 1, {behaviorData.opto}));
        longLaserOnTrials = intersect(longTrials, laserOnTrials);
        longLaserOffTrials = intersect(longTrials, laserOffTrials);

        laserOnSwitch = [behaviorData(longLaserOnTrials).SwitchDepart];
        laserOffSwitch = [behaviorData(longLaserOffTrials).SwitchDepart];

        averageSwitch(iSession, 1) = mean(laserOffSwitch, 'omitnan');
        averageSwitch(iSession, 2) = mean(laserOnSwitch, 'omitnan');        
    end
   
    acrossMouseAverageOff = mean(averageSwitch(:, 1));
    acrossMouseAverageOn = mean(averageSwitch(:, 2));

    for iSession = 1 : nSessions
        plot(1:2, averageSwitch(iSession, :), 'Color', 'k');
    end    
    scatter(ones(nSessions,1), averageSwitch(:,1), 70, offColor, 'filled');
    scatter(ones(nSessions,1)*2, averageSwitch(:,2), 70, onColor, 'filled');
    line([.75 1.25], [acrossMouseAverageOff acrossMouseAverageOff], 'LineWidth', 3, 'Color', offColor)
    line([1.75 2.25], [acrossMouseAverageOn acrossMouseAverageOn], 'LineWidth', 3, 'Color', onColor)

    xlim([0.5 2.5]);
    ylim([6 14]);
    xticks([1 2]);
    xticklabels({'Laser Off', 'Laser On'});
    ylabel('Average Switch Time (s)')
    set(gca, 'FontSize', 14);

    [p, h, stats] = signrank(averageSwitch(:,1), averageSwitch(:,2));
    fprintf('\nSign Rank: Laser On vs. Laser Off Switch Time: p = %.2f', p)