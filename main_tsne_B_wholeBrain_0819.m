%% main for run_tSne, whole brain data

cd 'C:\Users\Administrator\Desktop\Xinxin\StateData\2015-2-19 emx gcamp6 P4'
% load('components_states_0816.mat')

% cd 'C:\Users\Administrator\Desktop\Xinxin\StateData\2015-1-10 emx gcamp6 P6'
% cd 'C:\Users\Administrator\Desktop\Xinxin\StateData\2015-1-8 emx gcamp6 P4'
% cd 'C:\Users\Administrator\Desktop\Xinxin\StateData\160617_p12'
% load('components_states_0821_noSVD.mat')
% load('components_states_0821_noSVD_smallMask.mat')
% load('components_states_0821.mat')
% load('components_states_0822_smallMask.mat')
load('components_states_0822_smallMask.mat')


i = 1;
% AWAKE_W{i} = AWAKE_W{i}(:, 1:1000)
stateId = [ones(1, size(AWAKE_W{i}, 2)), 2 * ones(1, size(NREM_W{i}, 2)), 3 * ones(1, size(REM_W{i}, 2))];
embedId = 1 : 3 : length(stateId);
stateId_embed = stateId(embedId);

% for i = 1:length(NREM_W)
for i = 1
    W = cat(2, AWAKE_W{i}, NREM_W{i}, REM_W{i});
    ww = W;
    W = W - min(ww(:));
%     W = W([1:14, 16:end], :);
    
    for p = 1:3
        parameters.perplexity = 32 * p;  
        for d = 1:2
            parameters.num_tsne_dim = d + 1;
            parameters = setRunParameters(parameters);

            [yData_w{p}{d}, betas_w{p}{d}, P_w{p}{d}, errors_w{p}{d}] = run_tSne(W(:, embedId)', parameters);    
        end
    end
end

save('embedded_allStates_G_0822_smallMask.mat', 'yData_w', 'betas_w', 'P_w', 'errors_w', 'stateId_embed', 'stateId', 'embedId', 'parameters')





%%
i = 1;
stateId = [ones(1, size(AWAKE_W{i}, 2)), 2 * ones(1, size(NREM_W{i}, 2)), 3 * ones(1, size(REM_W{i}, 2))];
embedId = 1 : 3 : length(stateId);
stateId_embed = stateId(embedId);

% for i = 1:length(NREM_W)
for i = 1
    W{i} = cat(2, AWAKE_W{i}, NREM_W{i}, REM_W{i});
    ww = W{i};
    ww = ww([1:22, 24:end], :);
    W{i} = W{i} - min(ww(:));
    
    for p = 1:3
        parameters.perplexity = 32 * p;  
        for d = 1:2
            parameters.num_tsne_dim = d + 1;
            parameters = setRunParameters(parameters);

            [yData_w{p}{d}, betas_w{p}{d}, P_w{p}{d}, errors_w{p}{d}] = run_tSne(ww(:, embedId)', parameters);    
        end
    end
end

save('embedded_allStates_0821_noSVD.mat', 'yData_w', 'betas_w', 'P_w', 'errors_w', 'stateId_embed', 'stateId', 'embedId', 'parameters')




%% for 160617

cd 'C:\Users\Administrator\Desktop\Xinxin\StateData\160617_p12'
load('components_states_0821.mat')

i = 1;
AWAKE_W{i} = AWAKE_W{i}(:, 1:4000);
stateId = [ones(1, size(AWAKE_W{i}, 2)), 2 * ones(1, size(SLEEP_W{i}, 2))];
embedId = 1 : 3 : length(stateId);
stateId_embed = stateId(embedId);

% for i = 1:length(NREM_W)
for i = 1
    W = cat(2, AWAKE_W{i}, SLEEP_W{i});
    ww = W;
    W = W - min(ww(:));

    
    for p = 3:4
        parameters.perplexity = 32 * p;  
        for d = 1:2
            parameters.num_tsne_dim = d + 1;
            parameters = setRunParameters(parameters);

            [yData_w{p}{d}, betas_w{p}{d}, P_w{p}{d}, errors_w{p}{d}] = run_tSne(W(:, embedId)', parameters);    
        end
    end
end

save('embedded_allStates_G_0821.mat', 'yData_w', 'betas_w', 'P_w', 'errors_w', 'stateId_embed', 'stateId', 'embedId', 'parameters')





%%
embedId = 1 : 3 : length(stateId);
totalMovie = cat(2, AWAKE_movie(:, 1:4000), SLEEP_movie);
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

