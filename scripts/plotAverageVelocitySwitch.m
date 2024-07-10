function plotAverageVelocitySwitch(velocityData, frameRates)
% 
% INPUTS:
%   velocityData:        Within trial tangential velocity for short and long trials. Each row is one session.
%                        pixels/second
%
% OUTPUTS:
%   figure


    shortColor = [255, 178, 102] ./ 255;
    longColor = [255, 182, 234] ./ 255;
    intervalLimit = [-4 22];
    
    nSessions = length(velocityData);

    % Some sessions were recorded at 30 fps, so need to convert the sessions at 60 fps to same length as 30 fps.
    for iSession = 1 : nSessions
        frameRate = frameRates(iSession);
        if frameRate == 30
            averageShortVelocity(iSession,:) = mean(velocityData(iSession).ShortTrials, 1, 'omitnan');
            averageLongVelocity(iSession,:) = mean(velocityData(iSession).LongTrials, 1, 'omitnan');
        else
            binnedShortVelocity = [];            
            for jTrial = 1 : size(velocityData(iSession).ShortTrials, 1)
                binnedShortVelocity(jTrial, 1:419) = arrayfun(@(x) mean(velocityData(iSession).ShortTrials(jTrial, x:x+1)), 1:2:length(velocityData(iSession).ShortTrials)-2);
            end
            averageShortVelocity(iSession,:) = mean(binnedShortVelocity, 'omitnan');

            binnedLongVelocity = [];
            for jTrial = 1 : size(velocityData(iSession).LongTrials, 1)
                binnedLongVelocity(jTrial, 1:779) = arrayfun(@(x) mean(velocityData(iSession).LongTrials(jTrial, x:x+1)), 1:2:length(velocityData(iSession).LongTrials)-2);
            end
            averageLongVelocity(iSession,:) = mean(binnedLongVelocity, 'omitnan');
        end
    end

    % Calculate average over sessions.
    averageShortVelocityAll = mean(averageShortVelocity, 1, 'omitnan');
    averageLongVelocityAll = mean(averageLongVelocity, 1, 'omitnan');
    
    % Calculate standard error of the mean over sessions.
    stdShortVelocity = std(averageShortVelocity, 0, 1) ./ sqrt(nSessions);
    stdLongVelocity = std(averageLongVelocity, 0, 1) ./ sqrt(nSessions);

    % Plot the average across all mice.
    figure(1); clf;
    subplot(3,1,1); cla;
    hold on;
    x = intervalLimit(1) + 1/30 : 1/30 : intervalLimit(2);
    xline(0, '--');
    xline(6, '--');
    xline(18, '--');
    plotband(x(1:419), averageShortVelocityAll, stdShortVelocity, shortColor);
    plotband(x(1:end-1), averageLongVelocityAll, stdLongVelocity, longColor);   
    xlim(intervalLimit);
    xticks([-4 0 6 12 18 22]);
    xlabel('Time from Trial Start (s)');
    ylabel('Average Velocity (mm/s)')
    legend('', '', '', '', 'Short Trials', '', 'Long Trials');

    % Plot each session individually for short trials.
    subplot(3,1,2); cla;
    hold on;
    xline(0, '--');
    xline(6, '--');
    xline(18, '--');
    for iSession = 1 : nSessions
        plot(x(1:419), averageShortVelocity(iSession,:), 'Color', shortColor);
    end
    xlim(intervalLimit);
    xticks([-4 0 6 12 18 22]);
    xlabel('Time from Trial Start (s)');
    ylabel('Average Velocity (mm/s)')

    % Plot each session individually for long trials.
    subplot(3,1,3); cla;
    hold on;
    xline(0, '--');
    xline(6, '--');
    xline(18, '--');
    for iSession = 1 : nSessions
        plot(x(1:end-1), averageLongVelocity(iSession,:), 'Color', longColor);
    end
    xlim(intervalLimit);
    xticks([-4 0 6 12 18 22]);
    xlabel('Time from Trial Start (s)');
    ylabel('Average Velocity (mm/s)')