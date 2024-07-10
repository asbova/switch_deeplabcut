function plotDistanceTraveledOptoAverages(dlcData)

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

        laserOnDistance = dlcData(iSession).velocity.LongTrials(laserOnRows, :);
        laserOffDistance = dlcData(iSession).velocity.LongTrials(laserOffRows, :);

        averageDistance(iSession, 1) = mean(sum(laserOffDistance, 2, 'omitnan')) * 0.1;  % mm to cm;
        averageDistance(iSession, 2) = mean(sum(laserOnDistance, 2, 'omitnan')) * 0.1;      
    end

   
    acrossMouseAverageOff = mean(averageDistance(:, 1));
    acrossMouseAverageOn = mean(averageDistance(:, 2));

    for iSession = 1 : nSessions
        plot(1:2, averageDistance(iSession, :), 'Color', 'k');
    end    
    scatter(ones(nSessions,1), averageDistance(:,1), 70, offColor, 'filled');
    scatter(ones(nSessions,1)*2,averageDistance(:,2), 70, onColor, 'filled');
    line([.75 1.25], [acrossMouseAverageOff acrossMouseAverageOff], 'LineWidth', 3, 'Color', offColor)
    line([1.75 2.25], [acrossMouseAverageOn acrossMouseAverageOn], 'LineWidth', 3, 'Color', onColor)

    xlim([0.5 2.5]);
    ylim([30 60]);
    xticks([1 2]);
    xticklabels({'Laser Off', 'Laser On'});
    ylabel('Average Velocity (mm/s)')
    set(gca, 'FontSize', 14);

    signrank(averageDistance(:,1), averageDistance(:,2))