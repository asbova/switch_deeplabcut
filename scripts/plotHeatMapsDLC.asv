function plotHeatMapsDLC(trajectoryData)
% 
% INPUTS:
%   trajectoryData:      Within trial smoothed trajectories for short and long trials from one session.
%
% OUTPUTS:
%   figure



    blocksize = 10;     % Size of blocks to quantify time spent in.
    xSize = 240;
    ySize = 240;
    nBlocksX = xSize / blocksize;
    nBlocksY = ySize / blocksize;

    index = 1;
    for iBlockX = 1 : nBlocksX
        for iBlockY = 1 : nBlocksY
            blockDimensions{index, 1} = [blocksize * (iBlockX - 1) + 1, blocksize * (iBlockX - 1) + blocksize];
            blockDimensions{index, 2} = [blocksize * (iBlockY - 1) + 1, blocksize * (iBlockY - 1) + blocksize];
            index = index + 1;
        end
    end

    blocksHistogram = zeros(1, length(blockDimensions));
    for iTrial = 1 : length(trajectoryData.LongTrials)
        trialTrajectory = trajectoryData.LongTrials{iTrial};
        for jPoint = 1 : length(trialTrajectory)
            for kBlock = 1 : length(blockDimensions)
                if trialTrajectory(jPoint, 1) >= blockDimensions{kBlock, 2}(1) && trialTrajectory(jPoint, 1) <= blockDimensions{kBlock, 2}(2) && ...
                        trialTrajectory(jPoint, 2) >= blockDimensions{kBlock, 1}(1) && trialTrajectory(jPoint, 2) <= blockDimensions{kBlock, 1}(2)

                    blocksHistogram(kBlock) = blocksHistogram(kBlock) + 1;
                end
            end
        end
    end



    highestEntries = max(blocksHistogram);
    figure;
    cla; hold on;
    for iBlock = 1 : length(blockDimensions)
        imagesc(blockDimensions{iBlock, 2}(1) : blockDimensions{iBlock,2}(2), blockDimensions{iBlock, 1}(1): blockDimensions{iBlock, 1}(2), blocksHistogram(iBlock));
    end
    colorbar;
    axis('on')
    axis xy
    set(gca, 'YDir', 'reverse');
    colormap('jet');
    caxis([0 highestEntries]);
    ylim([-20 170]);
    xlim([-20 220]);