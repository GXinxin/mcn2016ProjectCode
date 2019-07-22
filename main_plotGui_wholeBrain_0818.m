%% main function for arrow plot gui, whole brain data

cd 'C:\Users\Administrator\Desktop\Xinxin\StateData\2015-2-19 emx gcamp6 P4'
load('components_states_0816.mat')

load('embedded_allStates_0816.mat')
load('plotInput_tSNE_0816.mat')
load('stateSegmentOnOff_0818.mat')




%% plot t-sne results
states = {'AWAKE', 'NREM', 'REM'};
% colors = jet(length(states));
colors = [1, 0, 0; 0, 1, 0; 0, 0, 1];
colorMat = colors(stateId_embed, :);

pts_tsne = pts_tsne{1};

for d = 1:2
    for p = 1:length(perVector)
        perValue = perVector(p);
        for s = 1:length(states)
            tmp{s} = find(stateId_embed == s);
            no_dims = d + 1;
            h = figure;
            if no_dims == 2
                scatter(pts_tsne{1}{p}{d}(tmp{s}, 1), pts_tsne{1}{p}{d}(tmp{s}, 2), 5*ones(length(tmp{s}), 1), colorMat(tmp{s}, :))
            else
                scatter3(pts_tsne{1}{p}{d}(tmp{s}, 1), pts_tsne{1}{p}{d}(tmp{s}, 2), pts_tsne{1}{p}{d}(tmp{s}, 3), 5*ones(length(tmp{s}), 1), colorMat(tmp{s}, :))
            end
            titleName = [states{s}, ' perplexity', num2str(perValue)];
            title(titleName)
            fn = [states{s}, '_perplexity', num2str(perValue), 'dim', num2str(no_dims), '.png'];
            saveas(h, fn)     
            
        end

        
        h = figure; 
        if no_dims == 2
            scatter(pts_tsne{1}{p}{d}(:, 1), pts_tsne{1}{p}{d}(:, 2), 5*ones(size(colorMat, 1), 1), colorMat)
        else
            scatter3(pts_tsne{1}{p}{d}(:, 1), pts_tsne{1}{p}{d}(:, 2), pts_tsne{1}{p}{d}(:, 3), 5*ones(size(colorMat, 1), 1), colorMat)
        end
        titleName = ['AWAKE-r NREM-g REM-b perplexity', num2str(perValue)];
        title(titleName)
        fn = ['AllStates_perplexity', num2str(perValue), 'dim', num2str(no_dims), '.png'];
        saveas(h, fn)
    end
end





%% plot gui

embedId = 1 : 3 : length(stateId);
totalMovie = cat(2, AWAKE_movie, NREM_movie, REM_movie);
totalMovie_embed = totalMovie(:, embedId);
totalMovie_embed = reshape(totalMovie_embed, size(twoHemLabel(1, :, :), 2), size(twoHemLabel(1, :, :), 3), length(embedId));

if isSVD
    totalMovie_embed = totalMovie_embed/(3*10^16);
end


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

perVector = [32 64 96];
[px, py, id1] = plot_tSNE_wholeBrain_GUI(0, p, d, s, yData_w, totalMovie_embed, labels, [], stateId_embed, states, perVector);
[px, py, id2] = plot_tSNE_wholeBrain_GUI(0, p, d, s, yData_w, totalMovie_embed, labels, [], stateId_embed, states, perVector);
[px, py, id3] = plot_tSNE_wholeBrain_GUI(0, p, d, s, yData_w, totalMovie_embed, labels, [], stateId_embed, states, perVector);
[px, py, id4] = plot_tSNE_wholeBrain_GUI(0, p, d, s, yData_w, totalMovie_embed, labels, [], stateId_embed, states, perVector);
% plot_tSNE_wholeBrain_arrow_GUI(p, d, s, pts_tsne{1}, stateSegment, states, stateId(embedId), perVector)



mask = squeeze(twoHemLabel(1, :, :)>0);
sz = size(mask);
a_movie = reshape(AWAKE_movie, sz(1), sz(2), size(AWAKE_movie, 2)) .* repmat(mask, 1, 1, size(AWAKE_movie, 2));
n_movie = reshape(NREM_movie, sz(1), sz(2), size(NREM_movie, 2)) .* repmat(mask, 1, 1, size(NREM_movie, 2));
r_movie = reshape(REM_movie, sz(1), sz(2), size(REM_movie, 2)) .* repmat(mask, 1, 1, size(REM_movie, 2));

A = cat(3, a_movie, n_movie, r_movie);


% get demo maxProj
maxProj{1} = max(A(:, :, embedId(id1)), [], 3);
figure; imagesc(maxProj{1}); colorbar; axis image

maxProj{2} = max(A(:, :, embedId(id2)), [], 3);
figure; imagesc(maxProj{2}); colorbar; axis image

maxProj{3} = max(A(:, :, embedId(id3)), [], 3);
figure; imagesc(maxProj{3}); colorbar; axis image

maxProj{4} = max(A(:, :, embedId(id4)), [], 3);
figure; imagesc(maxProj{4}); colorbar; axis image

% two Hem Label
labels = squeeze(twoHemLabel(1, :, :));
labelId = unique(labels);
for j = 1:4
    for i = 1:length(labelId)
        clusterPixel = (labels == labelId(i)); 
        projMat = maxProj{j} .* clusterPixel;
        avgValue(i) = sum(projMat(:))/sum(clusterPixel(:));
        clusterMat(:, :, i) = clusterPixel * avgValue(i);
    end
    
    maxProjMat{j} = sum(clusterMat, 3);
    figure; imagesc(maxProjMat{j})
end





% get demo Projs
maxProj{1} = max(A(:, :, embedId(id1)), [], 3);
medianProj{1} = squeeze(median(permute(A(:, :, embedId(id1)), [3, 1, 2])));
meanProj{1} = mean(A(:, :, embedId(id1)), 3);

maxProj{2} = max(A(:, :, embedId(id2)), [], 3);
medianProj{2} = squeeze(median(permute(A(:, :, embedId(id2)), [3, 1, 2])));
meanProj{2} = mean(A(:, :, embedId(id2)), 3);

maxProj{3} = max(A(:, :, embedId(id3)), [], 3);
medianProj{3} = squeeze(median(permute(A(:, :, embedId(id3)), [3, 1, 2])));
meanProj{3} = mean(A(:, :, embedId(id3)), 3);

maxProj{4} = max(A(:, :, embedId(id4)), [], 3);
medianProj{4} = squeeze(median(permute(A(:, :, embedId(id4)), [3, 1, 2])));
meanProj{4} = mean(A(:, :, embedId(id4)), 3);


for j = 1:4
    h = figure; 
    subplot(1, 2, 1); imagesc(medianProj{j}); colorbar; axis image; caxis([-0.05, 0.2])
    subplot(1, 2, 2); imagesc(meanProj{j}); colorbar; axis image; caxis([-0.05, 0.2])
    saveas(h, ['pick', num2str(j), '.png'])
end


colors = jet(4);
for j = 2:4
    rgbProj(:, :, j-1) = mat2gray(meanProj{j}, [0, 0.25]);
%     colorProj(:, :, j) = meanProj{j}
end
h = figure; image(rgbProj); axis image
saveas(h, 'colorProj.png')




% two Hem Label
labels = squeeze(twoHemLabel(1, :, :));
labelId = unique(labels);
for j = 1:4
    if j == 1
        idSelect = id1;
    elseif j == 2
        idSelect = id2;
    elseif j == 3
        idSelect = id3;
    else
        idSelect = id4;
    end
    
    for i = 1:length(labelId)
        clusterPixel = (labels == labelId(i)); 
        clusterMat{i} = A(:, :, embedId(idSelect)) .* repmat(clusterPixel, 1, 1, length(idSelect));
        szsz = size(clusterMat{i});
        avgValue{i} = sum(reshape(clusterMat{i}, szsz(1)*szsz(2), szsz(3)))/sum(clusterPixel(:));
        
        maxClusterMat(:, :, i) = clusterPixel * max(avgValue{i});
        medianClusterMat(:, :, i) = clusterPixel * median(avgValue{i});
        meanClusterMat(:, :, i) = clusterPixel * mean(avgValue{i});
    end
    
    maxProjMat{j} = sum(maxClusterMat, 3);
    medianProjMat{j} = sum(medianClusterMat, 3);
    meanProjMat{j} = sum(meanClusterMat, 3);
    
    h = figure; 
%     subplot(1, 3, 1); imagesc(maxProjMat{j}); colorbar; axis image
    subplot(1, 2, 1); imagesc(medianProjMat{j}); caxis([-0.05, 0.2]); colorbar; axis image
    subplot(1, 2, 2); imagesc(meanProjMat{j}); caxis([-0.05, 0.2]); colorbar; axis image
    saveas(h, ['c_pick', num2str(j), '.png'])
end









figure;
for s = 1:12
    subplot(4, 3, s)
    imagesc(squeeze(A(:, :, embedId(id4(s))))); caxis([-0.15, 0.5])
end

save('clickPoint_0822.mat', 'id1', 'id2', 'id3', 'id4', 'A', 'embedId');







%% plot tsne method2
states = {'AWAKE', 'NREM', 'REM'};
% states = {'AWAKE', 'sleep'};
% colors = jet(length(states));
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