function [px, py] = plot_tSNE_wholeBrain_arrow_GUI(p, d, s, pts_tsne, stateSegment, states, stateId, perVector)
% p: perplexity value
% d: dimension of embedding
% s: state index for the plot, s = 0 plots all states

pts = pts_tsne{1}{p}{d-1};

NA = 100;
colors = [1, 0, 0; 0, 1, 0; 0, 0, 1];
colorMat = colors(stateId, :);

h = figure('Position', [100, 100, 1049, 895]);
if s == 0
    if d == 2
        scatter(pts(:, 1), pts(:, 2), 5*ones(size(colorMat, 1), 1), colorMat); hold on
    else
        scatter3(pts(:, 1), pts(:, 2), pts(:, 3), 5*ones(size(colorMat, 1), 1), colorMat); hold on
    end
    titleName = ['AWAKE-r NREM-g REM-b  perplexity', num2str(perVector(p))];
    title(titleName)
end


% add arrow
hold on
clicking = 1; 
i = 1; 




while (clicking && i < size(stateSegment, 2))   
    on = stateSegment(1, i);
    off = min(50 + on, stateSegment(2, i));
    if d == 2
        quiver(pts(on:off-1, 1), pts(on:off-1, 2), pts(on+1:off, 1) - pts(on:off-1, 1), pts(on+1:off, 2) - pts(on:off-1, 2), 0);       
    else
        quiver3(pts(on:off-1, 1), pts(on:off-1, 2), pts(on:off-1, 3), ...
            pts(on+1:off, 1) - pts(on:off-1, 1), pts(on+1:off, 2) - pts(on:off-1, 2), pts(on+1:off, 3) - pts(on:off-1, 3), 0); 
    end

    
    i = i+1;
%     answer = inputdlg('Quit? (enter y to exit)');
%     if strcmp(answer, 'y')
%         clicking = 0;
%     end
    a = getpts(h);
    
    
    close(h)
    
    h = figure('Position', [100, 100, 1049, 895]);
    if d == 2
        scatter(pts(:, 1), pts(:, 2), 5*ones(size(colorMat, 1), 1), colorMat); hold on
    else
        scatter3(pts(:, 1), pts(:, 2), pts(:, 3), 5*ones(size(colorMat, 1), 1), colorMat); hold on
    end
    titleName = ['AWAKE-r NREM-g REM-b  perplexity', num2str(perVector(p))];
    title(titleName)
    
end



