function [px, py, id] = plot_tSNE_wholeBrain_GUI(isArrow, p, d, s, pts_tsne, movie, labels, tmps, stateId_embed, states, perVector)
% p: perplexity value
% d: dimension of embedding
% s: state index for the plot, s = 0 plots all states

pts = pts_tsne{p}{d-1};

NA = 100;
colors = [1, 0, 0; 0, 1, 0; 0, 0, 1];
colorMat = colors(stateId_embed, :);

h = figure(1);
if s == 0
    if d == 2
        scatter(pts(:, 1), pts(:, 2), 5*ones(size(colorMat, 1), 1), colorMat); hold on
        if isArrow
            quiver(pts(1:NA-1, 1), pts(1:NA-1, 2), pts(2:NA, 1) - pts(1:NA-1, 1), pts(2:NA, 2) - pts(1:NA-1, 2), 0); hold on
        end
    else
        scatter3(pts(:, 1), pts(:, 2), pts(:, 3), 5*ones(size(colorMat, 1), 1), colorMat); hold on
        if isArrow
            quiver3(pts(1:NA-1, 1), pts(1:NA-1, 2), pts(1:NA-1, 3), ...
                pts(2:NA, 1) - pts(1:NA-1, 1), pts(2:NA, 2) - pts(1:NA-1, 2), pts(2:NA, 3) - pts(1:NA-1, 3), 0); hold on
        end
    end
%     titleName = ['AWAKE-r NREM-g REM-b  perplexity', num2str(perVector(p))];
%     title(titleName)
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
    id(i) = dsearchn(pts, [px(i), py(i)]);
    scatter(px(i), py(i), 'k*'); hold on
    
    
    figure;
    subplot(2, 1, 1); imagesc(movie(:, :, id(i))); axis equal; axis off; 
    colorbar; colormap jet; caxis([-0.3, 0.6]); % [-0.3, 0.6] for Cacan1_exp_p7_160816
%     subplot(2, 1, 2); imagesc(spec(:, :, id))
    title(num2str(stateId_embed(id(i))))

    i = i+1;
    answer = inputdlg('Quit? (enter y to exit)');
    if strcmp(answer, 'y')
        clicking = 0;
    end
end



