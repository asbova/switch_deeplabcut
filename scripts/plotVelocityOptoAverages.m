function plotVelocityOptoAverages(dlcData)

% Plot the average velocity for trials with laser off vs. trials with laser on.
% Plots the individual mouse averages (circles) and between mouse averages (bars).
%
% INPUTS:
%   dlcData:            Data structure with DLC kinematics for individual mouse sessions.
%
% OUTPUTS:
%   figure
%


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

        averageVelocity(iSession, 1) = mean(mean(laserOffVelocity, 1, 'omitnan'));
        averageVelocity(iSession, 2) = mean(mean(laserOnVelocity, 1, 'omitnan'));        
    end

   
    acrossMouseAverageOff = mean(averageVelocity(:, 1));
    acrossMouseAverageOn = mean(averageVelocity(:, 2));

    for iSession = 1 : nSessions
        plot(1:2, averageVelocity(iSession, :), 'Color', 'k');
    end    
    scatter(ones(nSessions,1), averageVelocity(:,1), 70, offColor, 'filled');
    scatter(ones(nSessions,1)*2,averageVelocity(:,2), 70, onColor, 'filled');
    line([.75 1.25], [acrossMouseAverageOff acrossMouseAverageOff], 'LineWidth', 3, 'Color', offColor)
    line([1.75 2.25], [acrossMouseAverageOn acrossMouseAverageOn], 'LineWidth', 3, 'Color', onColor)

    xlim([0.5 2.5]);
    ylim([30 60]);
    xticks([1 2]);
    xticklabels({'Laser Off', 'Laser On'});
    ylabel('Average Velocity (mm/s)')
    set(gca, 'FontSize', 14);

    [p, h, stats] = signrank(averageVelocity(:,1), averageVelocity(:,2));
    fprintf('\nSign Rank: Laser On vs. Laser Off Velocity: p = %.2f', p)