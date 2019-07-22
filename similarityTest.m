%% calculate similarity matrix and plot on the scatter plot

i = 1;
% AWAKE_W{i} = AWAKE_W{i}(:, 1:1000)
stateId = [ones(1, size(AWAKE_W{i}, 2)), 2 * ones(1, size(NREM_W{i}, 2)), 3 * ones(1, size(REM_W{i}, 2))];
embedId = 1 : 3 : length(stateId);
stateId_embed = stateId(embedId);

% for i = 1:length(NREM_W)
i = 1
W = cat(2, AWAKE_W{i}, NREM_W{i}, REM_W{i});
ww = W;
W = W - min(ww(:));
ww = W(:, embedId);

S_L = cov(ww(1:50, :));
S_R = cov(ww(51:100, :));

for f = 1:size(S_L, 1)
    corrBetween(f) = corr(S_L(f, :)', S_R(f, :)');
end
corrId = find(corrBetween > 0.4);




states = {'AWAKE', 'NREM', 'REM'};
colors = [1, 0, 0; 0, 1, 0; 0, 0, 1];
colorMat = colors(stateId_embed, :);


pts_tsne = yData_w;
perVector = [32, 64, 96];

for d = 1:2
    for p = 1:length(perVector)
        perValue = perVector(p);
        for s = 1:length(states)
            tmp{s} = find(stateId_embed == s);
            no_dims = d + 1;
            h = figure;
            if no_dims == 2
                scatter(pts_tsne{p}{d}(tmp{s}, 1), pts_tsne{p}{d}(tmp{s}, 2), 5*ones(length(tmp{s}), 1), colorMat(tmp{s}, :))
            else
                scatter3(pts_tsne{p}{d}(tmp{s}, 1), pts_tsne{p}{d}(tmp{s}, 2), pts_tsne{p}{d}(tmp{s}, 3), 5*ones(length(tmp{s}), 1), colorMat(tmp{s}, :))
            end
            titleName = [states{s}, ' perplexity', num2str(perValue)];
            title(titleName)
            fn = [states{s}, '_perplexity', num2str(perValue), 'dim', num2str(no_dims), '.png'];
            saveas(h, fn)     
        end

        
        h = figure; 
        if no_dims == 2
            scatter(pts_tsne{p}{d}(:, 1), pts_tsne{p}{d}(:, 2), 5*ones(size(colorMat, 1), 1), colorMat)
        else
            scatter3(pts_tsne{p}{d}(:, 1), pts_tsne{p}{d}(:, 2), pts_tsne{p}{d}(:, 3), 5*ones(size(colorMat, 1), 1), colorMat)
        end
        titleName = ['AWAKE-r NREM-g REM-b perplexity', num2str(perValue)];
        title(titleName)
        fn = ['AllStates_perplexity', num2str(perValue), 'dim', num2str(no_dims), '.png'];
        saveas(h, fn)
    end
end



embedId = 1 : 3 : length(stateId);
totalMovie = cat(2, AWAKE_movie, NREM_movie, REM_movie);
totalMovie_embed = totalMovie(:, embedId);
totalMovie_embed = reshape(totalMovie_embed, size(twoHemLabel(1, :, :), 2), size(twoHemLabel(1, :, :), 3), length(embedId));

p = 2;
d = 2;
s = 0;
states = {'AWAKE', 'NREM', 'REM'};
labels = squeeze(twoHemLabel(1, :, :));
stateSegment = [AWAKE_segmentTotal, NREM_segmentTotal + sum(stateId == 1), REM_segmentTotal + sum(stateId == 1) + sum(stateId == 2)];
stateSegment = stateSegment(:, (stateSegment(2, :) - stateSegment(1, :) > 10));

embedId = 1 : 3 : length(stateId);
stateSegment = floor(stateSegment/3) + 1;
% [px, py] = plot_tSNE_wholeBrain_GUI(0, p, d, s, pts_tsne{1}{1}, totalMovie_embed, labels, [], stateId_embed, states, perVector);

figure(2); hist(corrBetween, 100)
perVector = [32 64 96];
% [px, py, id1] = plot_tSNE_wholeBrain_GUI(0, p, d, s, yData_w, totalMovie_embed, labels, [], stateId_embed, states, perVector);
% [px, py, id1] = plot_tSNE_wholeBrain_GUI2(corrBetween, 0, p, d, s, yData_w, totalMovie_embed, labels, [], stateId_embed, states, perVector);
[px, py, id1] = plot_tSNE_wholeBrain_GUI2(corrBetween, corrId, 0, p, d, s, yData_w, totalMovie_embed, labels, [], stateId_embed, states, perVector);






%% for 160617 animal



states = {'AWAKE', 'sleep'};
colors = [1, 0, 0; 0, 1, 0; 0, 0, 1];
colorMat = colors(stateId_embed, :);

pts_tsne = yData_w;
perVector = [32, 64, 96];


mask = squeeze(twoHemLabel(1, :, :)>0);
sz = size(mask);
a_movie = reshape(AWAKE_movie, sz(1), sz(2), size(AWAKE_movie, 2)) .* repmat(mask, 1, 1, size(AWAKE_movie, 2));
n_movie = reshape(NREM_movie, sz(1), sz(2), size(NREM_movie, 2)) .* repmat(mask, 1, 1, size(NREM_movie, 2));
r_movie = reshape(REM_movie, sz(1), sz(2), size(REM_movie, 2)) .* repmat(mask, 1, 1, size(REM_movie, 2));

A = cat(3, a_movie, n_movie, r_movie);
frStart = 1;
frEnd = size(A, 3);
filename = 'masked_movie';
[maxProj, Iarr] = timeColorMapProj(A, frStart, frEnd, filename);
% clear A
%Iarr2montage(Iarr, frStart, frEnd, 10, filename);
%Write avi movie
Iarr2avi(Iarr, frStart, frEnd, filename)


i = 1;
% AWAKE_W{i} = AWAKE_W{i}(:, 1:1000)
stateId = [ones(1, size(AWAKE_W{i}, 2)), 2 * ones(1, size(NREM_W{i}, 2)), 3 * ones(1, size(REM_W{i}, 2))];
embedId = 1 : 3 : length(stateId);
stateId_embed = stateId(embedId);

% for i = 1:length(NREM_W)
i = 1
W = cat(2, AWAKE_W{i}, SLEEP_W{i});
ww = W;
W = W - min(ww(:));
ww = W(:, embedId);

S_L = cov(ww(1:50, :));
S_R = cov(ww(51:100, :));

for f = 1:size(S_L, 1)
    corrBetween(f) = corr(S_L(f, :)', S_R(f, :)');
end
corrId = find(corrBetween > 0.4);


% pts_tsne = yData_w;
perVector = [32, 64, 96];


embedId = 1 : 3 : length(stateId);
totalMovie = cat(2, AWAKE_movie(:, 1:4000), SLEEP_movie);
totalMovie_embed = totalMovie(:, embedId);
totalMovie_embed = reshape(totalMovie_embed, size(twoHemLabel(1, :, :), 2), size(twoHemLabel(1, :, :), 3), length(embedId));

p = 2;
d = 2;
s = 0;
% states = {'AWAKE', 'NREM', 'REM'};
labels = squeeze(twoHemLabel(1, :, :));
stateSegment = [AWAKE_segmentTotal, NREM_segmentTotal + sum(stateId == 1), REM_segmentTotal + sum(stateId == 1) + sum(stateId == 2)];
stateSegment = stateSegment(:, (stateSegment(2, :) - stateSegment(1, :) > 10));

embedId = 1 : 3 : length(stateId);
stateSegment = floor(stateSegment/3) + 1;
% [px, py] = plot_tSNE_wholeBrain_GUI(0, p, d, s, pts_tsne{1}{1}, totalMovie_embed, labels, [], stateId_embed, states, perVector);

figure(2); hist(corrBetween, 100)
perVector = [32 64 96];
pts = pts_tsne{1}{1};
% [px, py, id1] = plot_tSNE_wholeBrain_GUI(0, p, d, s, yData_w, totalMovie_embed, labels, [], stateId_embed, states, perVector);
[px, py, id1] = plot_tSNE_wholeBrain_GUI2(corrBetween, 0, p, d, s, pts, totalMovie_embed, labels, [], stateId_embed, states, perVector);
