cd 'C:\Users\Administrator\Desktop\Xinxin\6636_July1'

load('constrainedNNMF_components.mat')
load('6636_July1_concatStateId.mat')
selectComponentId = [1:39, 41:43, 45:49];

% % compress awake spec data
% load('6636_July1_awake_BOS.mat')
% load('6636_July1_awake_CON.mat')
% load('6636_July1_awake_SONG.mat')
% load('6636_July1_awakeSPECs_ns.mat')
% 
% 
% CompSpecBOS_s =  imresize(permute(CompSpecBOS, [2, 3, 1]), .75, 'bilinear');
% CompSpecCON_s =  imresize(permute(CompSpecCON, [2, 3, 1]), .75, 'bilinear');
% CompSpecSONG_s =  imresize(permute(CompSpecSONG, [2, 3, 1]), .75, 'bilinear');
% CompSpecNS_s = imresize(COMPspec_ns, .75, 'bilinear');
% 
% CompSpecBOS_s = imresize(CompSpecBOS_s, .8, 'bilinear'); 
% CompSpecCON_s = imresize(CompSpecCON_s, .8, 'bilinear'); 
% CompSpecSONG_s = imresize(CompSpecSONG_s, .8, 'bilinear');
% CompSpecNS_s = imresize(CompSpecNS_s, .8, 'bilinear');
% 
% save('awake_spec_s.mat', 'CompSpecBOS_s', 'CompSpecCON_s', 'CompSpecSONG_s', 'CompSpecNS_s', '-v7.3');
% 
% 
% % compress sleep spec data
% load('SleepSound.mat')
% CompSpecSLEEP_s =  imresize(permute(CompSpec, [2, 3, 1]), .6, 'bilinear');
% save('sleep_spec_s.mat', 'CompSpecSLEEP_s', '-v7.3')


%% downSample awake movies
% load('6636_July1_awake_BOS.mat')
% CompVidBOS_s = imresize(permute(CompVidBOS, [2, 3, 1]), .2, 'bilinear');
% save('6636_July1_awakeVidBOS_s.mat', 'CompVidBOS_s')
% 
% load('6636_July1_awake_CON.mat')
% CompVidCON_s = imresize(permute(CompVidCON, [2, 3, 1]), .2, 'bilinear');
% save('6636_July1_awakeVidCON_s.mat', 'CompVidCON_s')
% 
% load('6636_July1_awake_SONG.mat')
% CompVidSONG_s = imresize(permute(CompVidSONG, [2, 3, 1]), .2, 'bilinear');
% save('6636_July1_awakeVidSONG_s.mat', 'CompVidSONG_s')




%% throw away silent frames based on a hard threshold

% compute 80% and 90% intensity threshold
id = [floor(size(Y_r, 2) * 0.8), floor(size(Y_r, 2) * 0.9)];
for i = 1:size(Y_r, 1)
    value = sort(Y_r(i, :));
    thresh8(i) = value(id(1));
    thresh9(i) = value(id(2));
end


% first look at the traces of the components, decided to choose 90%
% of intensity histogram for each component as cut-off threshold
for i = 1:2:size(Y_r, 1)-1
    h = figure; 
    subplot(4, 1, 1); plot(Y_r(i, :))
    subplot(4, 1, 2); plot(C(i, :))
    subplot(4, 1, 3); plot(Y_r(i+1, :))
    subplot(4, 1, 4); plot(C(i+1, :))
    title([num2str(thresh8(i)), ' ', num2str(thresh9(i)), ' ', num2str(thresh8(i+1)), ' ', num2str(thresh9(i+1))])
    saveas(h, ['componentTrace', num2str(i), '.png'])
end

Y_total = Y_r(selectComponentId, :);

% cutOff = sort(Y_total(:));
% cutOff = cutOff(floor(length(cutOff) * 0.95))
cutOff = 0.07; % a hard cutoff
threshMat = repmat(cutOff, size(Y_total));
selectMat = Y_total > threshMat;
selectId = find(sum(selectMat, 1) > 0);
length(selectId)

%% embedd with t-SNE
% H_total = [];
% stateId = [];
% for i = 1:length(H_norm)
%     H_total = [H_total, H_norm{i}];
%     stateId = [stateId, i * ones(1, size(H_norm{i}, 2))];
% end

embedId = selectId(1 : 2 : length(selectId)); % only embed every 2 point from the selected frames (imaging is 20hz)


Y_total = Y_total(:, embedId);

perVector = [50, 100, 200, 500];
for p = 1:length(perVector)
    perValue = perVector(p);
    for d = 1:2
        no_dims = d + 1;
        initial_dims = size(Y_total, 1);
        pts_tsne2{p}{d} = tsne(Y_total', [], no_dims, initial_dims, perValue);       
    end
end

%pts_tsne = pts_tsne2;



%% embed each state after threshold
stateOn = [1, find(stateId(2:end) - stateId(1:end-1) == 1) + 1];
stateOff = [stateOn(2:end)-1, length(stateId)];

for s = 1:length(unique(stateId))                                               
    singleStateId{s} = selectId((selectId <= stateOff(s)) & (selectId >= stateOn(s)));
end


states = {'SLEEP', 'BOS', 'CON', 'SONG', 'NOSYLLABLE'};

for s = 1:length(states)
    perVector = [20, 50, 100, 200];
    for p = 1:length(perVector)
        perValue = perVector(p);
        Y_r_single{s} = Y_r(selectComponentId, singleStateId{s});
        for d = 1:2
            no_dims = d + 1;
            initial_dims = size(Y_r_single{s}, 1);
            if s == 1 || s == 5
                embedId{s} = 1:4:size(Y_r_single{s}, 2);
            else
                embedId{s} = 1:2:size(Y_r_single{s}, 2);
            end
            pts_tsne_single{s}{p}{d} = tsne(Y_r_single{s}(:, embedId{s})', [], no_dims, initial_dims, perValue);
        end
    end
end


% plot t-sne for each state
for d = 1:2
    for p = 1:length(perVector)
        perValue = perVector(p);
        for s = 1:length(states)
            tmp{s} = length(1:2:size(Y_r_single{s}, 2));
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

save('embedded_allStates_0817_single_thresh0.07.mat', 'pts_tsne_single', 'Y_r_single', 'selectId', 'singleStateId', 'perVector')




%% embed with same sample size for each state after threshold
minLength = min([length(singleStateId{1}), length(singleStateId{2}), ...
    length(singleStateId{3}), length(singleStateId{4}), length(singleStateId{5})]);




%% plot embedding results
load('6636_July1_concatStateId.mat')
colors = jet(5);
colorMat = colors(stateId(embedId), :);
stateId_embed = stateId(embedId);
states = {'SLEEP', 'BOS', 'CON', 'SONG', 'NOSYLLABLE'};

for d = 1:2
    for p = 1:length(perVector)
        perValue = perVector(p);
        for s = 1:5
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
        titleName = ['SLEEP-b BOS-c CON-g SONG-y NOSYL-o  perplexity', num2str(perValue)];
        title(titleName)
        fn = ['AllStates_perplexity', num2str(perValue), 'dim', num2str(no_dims), '.png'];
        saveas(h, fn)
    end
end


save('embedded_allStates_0817_0.07.mat', 'pts_tsne', 'stateId', 'stateId_embed', 'colorMat', 'perVector')
% save('downSampledMovies.mat', 'SleepVid_s', 'CompVidBOS_s', 'CompVidCON_s', 'CompVidSONG_s', 'embedId', 'pts_tsne', 'H_norm', 'W_all');



%% plot frame and spectrogram after t-SNE

load('6636_July1_sleep_spec_s.mat')
load('6636_July1_awake_spec_s.mat')

load('6636_July1_SleepVid_s.mat')
load('6636_July1_awakeVidBOS_s.mat')
load('6636_July1_awakeVidCON_s.mat')
load('6636_July1_awakeVidSONG_s.mat')
load('6636_July1_awakeVidnsyllable_s.mat')


% concat movies
totalMovie = cat(3, SleepVid_s, CompVidBOS_s, CompVidCON_s, CompVidSONG_s, COMPdffVIDEO_nsyllable);
totalMovie_embed = totalMovie(:, :, embedId);

totalSpec = cat(3, CompSpecSLEEP_s, CompSpecBOS_s, CompSpecCON_s, CompSpecSONG_s, CompSpecNS_s);
totalSpec_embed = totalSpec(:, :, embedId);

save('plotInput_tSNE_0817_thresh0.07.mat', 'pts_tsne', 'totalMovie_embed', 'totalSpec_embed', 'tmp', 'stateId_embed', 'stateId', 'perVector', '-v7.3');

load('embedded_allStates_0817.mat')
p = 1;
d = 2;
s = 0;
states = {'SLEEP', 'BOS', 'CON', 'SONG', 'NOSYLLABLE'};
[px, py] = plot_tSNEpick_GUI(1, p, d, s, pts_tsne, totalMovie_embed, totalSpec_embed, tmp, stateId_embed, states, perVector);