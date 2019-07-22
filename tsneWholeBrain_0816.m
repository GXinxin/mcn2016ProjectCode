%% whole brain, run t-sne after parcellation
clear; clc;

cd 'C:\Users\Administrator\Desktop\Xinxin\StateData\2015-1-8 emx gcamp6 P4'
load('components_states_0821_noSVD.mat')


i = 1;
stateId = [ones(1, size(AWAKE_W{i}, 2)), 2 * ones(1, size(NREM_W{i}, 2)), 3 * ones(1, size(REM_W{i}, 2))];
embedId = 1 : 3 : length(stateId);
stateId_embed = stateId(embedId);
for i = 1
    W{i} = cat(2, AWAKE_W{i}, NREM_W{i}, REM_W{i});
    ww = W{i}([1:22, 24:99], :);
    
    perVector = [50, 100, 200, 500];
    for p = 1:length(perVector)
        perValue = perVector(p);
        for d = 1:2
            no_dims = d + 1;
            initial_dims = size(ww, 1);
            pts_tsne{i}{1}{p}{d} = tsne(ww(:, embedId)', [], no_dims, initial_dims, perValue);
        end
    end
end

save('embedded_allStates_0821_noSVD.mat', 'pts_tsne', 'stateId', 'stateId_embed', 'perVector')



%% embed equal data size for all states

stateFrame = min([size(AWAKE_movie, 2), size(NREM_movie, 2), size(REM_movie, 2)]);

stateId_equal = [ones(1, stateFrame), 2*ones(1, stateFrame), 3*ones(1, stateFrame)];
embedId = 1:2:length(stateId_equal);
% for i = 1:length(NREM_W)
for i = 1
    W_equal{i} = cat(2, AWAKE_W{i}(:, 1:stateFrame), NREM_W{i}(:, 1:stateFrame), REM_W{i}(:, 1:stateFrame));
    
    perVector = [50, 100, 200, 500];
    for p = 3:length(perVector)
        perValue = perVector(p);
        for d = 1:2
            no_dims = d + 1;
            initial_dims = size(W_equal{i}, 1);
            pts_tsne_equal{i}{p}{d} = tsne(W_equal{i}(:, embedId)', [], no_dims, initial_dims, perValue);
        end
    end
end

save('embedded_allStates_0817_equal.mat', 'pts_tsne_equal', 'stateId_equal', 'embedId', 'perVector')


states = {'AWAKE', 'NREM', 'REM'};
% colors = jet(length(states));
colors = [1, 0, 0; 0, 1, 0; 0, 0, 1];
colorMat = colors(stateId_equal(embedId), :);

for d = 1:2
    for p = 1:length(perVector)
        perValue = perVector(p);
        for s = 1:length(states)
            tmp{s} = find(stateId_equal(embedId) == s);
            no_dims = d + 1;
            h = figure;
            if no_dims == 2
                scatter(pts_tsne_equal{1}{p}{d}(tmp{s}, 1), pts_tsne_equal{1}{p}{d}(tmp{s}, 2), 5*ones(length(tmp{s}), 1), colorMat(tmp{s}, :))
            else
                scatter3(pts_tsne_equal{1}{p}{d}(tmp{s}, 1), pts_tsne_equal{1}{p}{d}(tmp{s}, 2), pts_tsne_equal{1}{p}{d}(tmp{s}, 3), 5*ones(length(tmp{s}), 1), colorMat(tmp{s}, :))
            end
            titleName = [states{s}, ' perplexity', num2str(perValue)];
            title(titleName)
            fn = [states{s}, '_equal_perplexity', num2str(perValue), 'dim', num2str(no_dims), '.png'];
            saveas(h, fn)     
        end

        
        h = figure; 
        if no_dims == 2
            scatter(pts_tsne_equal{1}{p}{d}(:, 1), pts_tsne_equal{1}{p}{d}(:, 2), 5*ones(size(colorMat, 1), 1), colorMat)
        else
            scatter3(pts_tsne_equal{1}{p}{d}(:, 1), pts_tsne_equal{1}{p}{d}(:, 2), pts_tsne_equal{1}{p}{d}(:, 3), 5*ones(size(colorMat, 1), 1), colorMat)
        end
        titleName = ['AWAKE-r NREM-g REM-b perplexity', num2str(perValue)];
        title(titleName)
        fn = ['AllStates_equal_perplexity', num2str(perValue), 'dim', num2str(no_dims), '.png'];
        saveas(h, fn)
    end
end




%% embed each state separately
states = {'AWAKE', 'NREM', 'REM'};

W_single{1} = AWAKE_W{1};
W_single{2} = NREM_W{1};
W_single{3} = REM_W{1};


for s = 1:length(states)
    perVector = [50, 100, 200, 500, 20];
    for p = 5:length(perVector)
        perValue = perVector(p);
        for d = 1:2
            no_dims = d + 1;
            initial_dims = size(W_single{s}, 1);
            embedId = 1:2:size(W_single{s}, 2);
            pts_tsne_single{s}{p}{d} = tsne(W_single{s}(:, embedId)', [], no_dims, initial_dims, perValue);
        end
    end
end

save('embedded_allStates_0817_single.mat', 'pts_tsne_single', 'W_single', 'embedId', 'perVector')


% plot t-sne for each state
for d = 1:2
    for p = 1:length(perVector)
        perValue = perVector(p);
        for s = 1:length(states)
            tmp{s} = length(1:2:size(W_single{s}, 2));
            no_dims = d + 1;
            h = figure;
            if no_dims == 2
                scatter(pts_tsne_single{s}{p}{d}(:, 1), pts_tsne_single{s}{p}{d}(:, 2), 5*ones(length(tmp{s}), 1))
            else
                scatter3(pts_tsne_single{s}{p}{d}(:, 1), pts_tsne_single{s}{p}{d}(:, 2), pts_tsne_single{s}{p}{d}(:, 3), 5*ones(length(tmp{s}), 1))
            end
            titleName = [states{s}, ' perplexity', num2str(perValue)];
            title(titleName)
            fn = [states{s}, '_perplexity', num2str(perValue), 'dim', num2str(no_dims), '.png'];
            saveas(h, fn)     
        end
    end
end



%% plot t-sne results
states = {'AWAKE', 'NREM', 'REM'};
% colors = jet(length(states));
colors = [1, 0, 0; 0, 1, 0; 0, 0, 1];
colorMat = colors(stateId_embed, :);

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






%% interactive plot gui
totalMovie = cat(2, AWAKE_movie, NREM_movie, REM_movie);
totalMovie_embed = totalMovie(:, embedId);
totalMovie_embed = reshape(totalMovie_embed, size(twoHemLabel(1, :, :), 2), size(twoHemLabel(1, :, :), 3), length(embedId));


save('plotInput_tSNE_0816.mat', 'pts_tsne', 'totalMovie_embed', 'tmp', 'stateId_embed', 'stateId', 'perVector', 'twoHemLabel', '-v7.3');


load('embedded_allStates_0816.mat')
load('plotInput_tSNE_0816.mat')

p = 1;
d = 2;
s = 0;
states = {'AWAKE', 'NREM', 'REM'};
labels = squeeze(twoHemLabel(1, :, :));
pts_tsne = pts_tsne{1};
[px, py] = plot_tSNE_wholeBrain_GUI(0, p, d, s, pts_tsne, totalMovie_embed, labels, [], stateId_embed, states, perVector);




%% for 160617 data
clear; clc;

cd 'C:\Users\Administrator\Desktop\Xinxin\StateData\160617_p12'
load('components_states_0821.mat')


i = 1;
stateId = [ones(1, size(AWAKE_W{i}(:, 1:4000), 2)), 2 * ones(1, size(SLEEP_W{i}, 2))];
embedId = 1 : 3 : length(stateId);
stateId_embed = stateId(embedId);
for i = 1
    W{i} = cat(2, AWAKE_W{i}(:, 1:4000), SLEEP_W{i});
    ww = W{i};
    ww = ww - min(ww(:));
    
    perVector = [50, 100, 200, 500];
    for p = 1:length(perVector)
        perValue = perVector(p);
        for d = 1:2
            no_dims = d + 1;
            initial_dims = size(ww, 1);
            pts_tsne{i}{1}{p}{d} = tsne(ww(:, embedId)', [], no_dims, initial_dims, perValue);
        end
    end
end

save('embedded_allStates_0821_EuDist.mat', 'pts_tsne', 'stateId', 'stateId_embed', 'perVector')

%% plot t-sne results
states = {'AWAKE', 'SLEEP'};
% colors = jet(length(states));
colors = [1, 0, 0; 0, 1, 0; 0, 0, 1];
colorMat = colors(stateId_embed, :);

for d = 1:2
    for p = 1:length(perVector)
        perValue = perVector(p);
        for s = 1:length(states)
            tmp{s} = find(stateId_embed == s);
            no_dims = d + 1;
            h = figure;
            if no_dims == 2
                scatter(pts_tsne{1}{1}{p}{d}(tmp{s}, 1), pts_tsne{1}{1}{p}{d}(tmp{s}, 2), 5*ones(length(tmp{s}), 1), colorMat(tmp{s}, :))
            else
                scatter3(pts_tsne{1}{1}{p}{d}(tmp{s}, 1), pts_tsne{1}{1}{p}{d}(tmp{s}, 2), pts_tsne{1}{1}{p}{d}(tmp{s}, 3), 5*ones(length(tmp{s}), 1), colorMat(tmp{s}, :))
            end
            titleName = [states{s}, ' perplexity', num2str(perValue)];
            title(titleName)
            fn = [states{s}, '_perplexity', num2str(perValue), 'dim', num2str(no_dims), '.png'];
            saveas(h, fn)     
        end

        
        h = figure; 
        if no_dims == 2
            scatter(pts_tsne{1}{1}{p}{d}(:, 1), pts_tsne{1}{1}{p}{d}(:, 2), 5*ones(size(colorMat, 1), 1), colorMat)
        else
            scatter3(pts_tsne{1}{1}{p}{d}(:, 1), pts_tsne{1}{1}{p}{d}(:, 2), pts_tsne{1}{1}{p}{d}(:, 3), 5*ones(size(colorMat, 1), 1), colorMat)
        end
        titleName = ['AWAKE-r NREM-g REM-b perplexity', num2str(perValue)];
        title(titleName)
        fn = ['AllStates_perplexity', num2str(perValue), 'dim', num2str(no_dims), '.png'];
        saveas(h, fn)
    end
end






%% interactive plot gui
totalMovie = cat(2, AWAKE_movie(:, 1:4000), SLEEP_movie);
totalMovie_embed = totalMovie(:, embedId);
totalMovie_embed = reshape(totalMovie_embed, size(twoHemLabel(1, :, :), 2), size(twoHemLabel(1, :, :), 3), length(embedId));


save('plotInput_tSNE_0816.mat', 'pts_tsne', 'totalMovie_embed', 'tmp', 'stateId_embed', 'stateId', 'perVector', 'twoHemLabel', '-v7.3');


load('embedded_allStates_0816.mat')
load('plotInput_tSNE_0816.mat')

p = 1;
d = 2;
s = 0;
states = {'AWAKE', 'SLEEP'};
labels = squeeze(twoHemLabel(1, :, :));
% pts_tsne = pts_tsne{1};
[px, py] = plot_tSNE_wholeBrain_GUI(0, p, d, s, pts_tsne, totalMovie_embed, labels, [], stateId_embed, states, perVector);

