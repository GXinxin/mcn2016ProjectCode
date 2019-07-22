function [px, py] = plot_tSNEpick_GUI(isArrow, p, d, s, pts_tsne, movie, spec, tmps, stateId, states, perVector, ss)
% p: perplexity value
% d: dimension of embedding
% s: state index for the plot, s = 0 plots all states

pts = pts_tsne{p}{d-1};




h = figure;
if s == 0
    colors = jet(length(unique(stateId)));
    colorMat = colors(stateId, :);
    if d == 2
        scatter(pts(:, 1), pts(:, 2), 5*ones(size(colorMat, 1), 1), colorMat); hold on
%         for ss = 1:length(unique(stateId))
            id = find(stateId == ss);
            if isArrow
                quiver(pts(id(1:end-1), 1), pts(id(1:end-1), 2), pts(id(2:end), 1) - pts(id(1:end-1), 1), ...
                    pts(id(2:end), 2) - pts(id(1:end-1), 2), 0, 'MaxHeadSize', .04); hold on
            end
%         end
    else
        scatter3(pts(:, 1), pts(:, 2), pts(:, 3), 5*ones(size(colorMat, 1), 1), colorMat); hold on
%         for ss = 1:length(unique(stateId))
            id = find(stateId == ss);
            if isArrow
                quiver3(pts(id(1:end-1), 1), pts(id(1:end-1), 2), pts(id(1:end-1), 3), ...
                    pts(id(2:end), 1) - pts(id(1:end-1), 1), pts(id(2:end), 2) - pts(id(1:end-1), 2), pts(id(2:end), 3) - pts(id(1:end-1), 3), 0, 'MaxHeadSize', .04); hold on
            end
%         end
    end
    
    titleName = ['SLEEP-b BOS-c CON-g SONG-y NOSYL-o  perplexity', num2str(perVector(p))];
    title(titleName)
        
else
    if d == 2
        scatter(pts(:, 1), pts(:, 2), 5*ones(size(pts, 1), 1)); hold on
        if isArrow
            quiver(pts(1:end-1, 1), pts(1:end-1, 2), pts(2:end, 1) - pts(1:end-1, 1), pts(2:end, 2) - pts(1:end-1, 2), 0, 'MaxHeadSize', .04); hold on
        end
    else
        scatter3(pts(:, 1), pts(:, 2), pts(:, 3), 5*ones(size(pts, 1), 1)); hold on
        if isArrow
            quiver3(pts(1:end-1, 1), pts(1:end-1, 2), pts(1:end-1, 3), ...
                pts(2:end, 1) - pts(1:end-1, 1), pts(2:end, 2) - pts(1:end-1, 2), pts(2:end, 3) - pts(1:end-1, 3), 0, 'MaxHeadSize', .04); hold on
        end
    end
    
    titleName = [states{s}, ' perplexity', num2str(perVector(p))];
    title(titleName)
end

hold on
clicking = 1; 
px = []; 
py = []; 
i = 1; 

while clicking
    if d == 2
        [px(i), py(i)] = getpts(h);
%         dist = (pts(:, 1) - px(i)).^2 + (pts(:, 2) - py(i)).^2;
        
    else
        [px(i), py(i), pz(i)] = getpts(h);
%         dist = (pts(:, 1) - px(i)).^2 + (pts(:, 2) - py(i)).^2 + (pts(:, 3) - pz(i)).^2;
    end

    
%     id = find(dist == min(dist));
%     id = id(1);
    id = dsearchn(pts, [px(i), py(i)]);
    scatter(px(i), py(i), 'k*'); hold on
    
    
    figure;
    subplot(2, 1, 1); imagesc(movie(:, :, id)); axis equal; axis off; caxis([0, 0.05])
    subplot(2, 1, 2); imagesc(spec(:, :, id))
    if s == 0
        title(num2str(stateId(id)))
    end

    i = i+1;
    answer = inputdlg('Quit? (enter y to exit)');
    if strcmp(answer, 'y')
        clicking = 0;
    end
end



