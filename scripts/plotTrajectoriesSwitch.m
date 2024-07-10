function plotTrajectoriesSwitch(trajectoryData)
% 
% INPUTS:
%   trajectoryData:      Within trial smoothed trajectories for short and long trials from one session.
%
% OUTPUTS:
%   figure

    

    % Plot trajectories of short trials.
    figure('Units', 'Normalized', 'OuterPosition', [0.2, 0.9, 0.4, 0.7]);
    subplot(2,1,1); cla;
    hold on
    nTrials = length(trajectoryData.ShortTrials);    
    for iTrial = 1 : nTrials
        if isempty(trajectoryData.ShortTrials{iTrial})
            continue;
        end

        xPositions = trajectoryData.ShortTrials{iTrial}(:,1);
        yPositions = trajectoryData.ShortTrials{iTrial}(:,2);
        nPositions = size(xPositions,1);
        cmap = jet(nPositions);
    
        for i = 1 : nPositions - 1
            plot(xPositions([i i+1]), yPositions([i i+1]), 'color', cmap(i,:), 'linewidth', 1.5);
        end
    end
    set(gca, 'xlim', [-20 220]);
    set(gca, 'ylim', [-10 210]);
    title('Short Trials');
    hold off;

    % Plot trajectories of long trials.
    subplot(2,1,2); cla;
    hold on
    nTrials = length(trajectoryData.LongTrials);    
    for iTrial = 1 : nTrials
        if isempty(trajectoryData.LongTrials{iTrial})
            continue;
        end

        xPositions = trajectoryData.LongTrials{iTrial}(:,1);
        yPositions = trajectoryData.LongTrials{iTrial}(:,2);
        nPositions = size(xPositions,1);
        cmap = jet(nPositions);
    
        for i = 1 : nPositions - 1
            plot(xPositions([i i+1]), yPositions([i i+1]), 'color', cmap(i,:), 'linewidth', 1.5);
        end
    end
    set(gca, 'xlim', [-20 220]);
    set(gca, 'ylim', [-10 210]);
    title('Long Trials')

    % % Make legend
    % figureXLim = get(gca, 'xlim');
    % legendX = (figureXLim(1) + 10 : figureXLim(1) + 150)';
    % legendY = ones(length(legendX),1)*630;
    % n = size(legendX,1)-1;
    % cmap = jet(n);
    % for i = 1:n
    %     plot(legendX([i i+1]), legendY([i i+1]), 'color', cmap(i,:), 'linewidth', 4);
    % end
    % 
    % text(legendX(1)-5, legendY(1) + 40, '0', 'Color', 'white', 'FontSize', 14, 'FontName', 'arial')
    % text(legendX(end)-30, legendY(1) + 40, '18s', 'Color', 'white', 'FontSize', 14, 'FontName', 'arial')





    
    






    % behChamb = imread(imagefile);
    % fig = imshow(behChamb);
    % % axis on
    % hold on