% apply simple NNMF for data from all states together, and embed together
% onto the same space




clear; clc;
%% data prep

downSampleRatio = 0.2;

% sleep dataset
cd 'C:\Users\Administrator\Desktop\Xinxin\6636_July1\asleep'
load('compiled.mat')
SleepVid_s = imresize(permute(CompVid, [2, 3, 1]), downSampleRatio, 'bilinear');

save('SleepVid_s.mat', 'SleepVid_s', '-v7.3')
save('SleepSound.mat', 'CompSound', 'CompSpec', '-v7.3')


% awake dataset
clear; 
cd 'C:\Users\Administrator\Desktop\Xinxin\6636_July1\awake'
filelist = dir(fullfile('*_row*.mat'));

img_all = [];
for i = 1:length(filelist)
    fn = filelist(i).name;
    load(fn)
    
    movie = imresize(permute(dffVIDEO, [2, 3, 1]), downSampleRatio, 'bilinear');
    sz = size(movie);
    movie = reshape(movie, sz(1)*sz(2), sz(3));
    img_all = [img_all, movie];
end
randCompAwake_s = reshape(img_all, sz(1), sz(2), size(img_all, 2));

save('randCompAwake_s.mat', 'randCompAwake_s', '-v7.3');





%%
% put sleep + awake data together

clear; clc;
cd 'C:\Users\Administrator\Desktop\Xinxin\6636_July1'

load('randCompAwake_s.mat')
load('SleepVid_s.mat')

imgall = cat(3, randCompAwake_s(:, :, 1:5000), SleepVid_s(:, :, 1:5000));
sz = size(imgall);
imgall = reshape(imgall, sz(1)*sz(2), sz(3));

tic
[W, H] = nnmf(imgall, 50);
toc

components = reshape(W, sz(1), sz(2), size(W, 2));


h = figure; 
for i = 1:20
    subplot(4, 5, i)
    imagesc(squeeze(components(:, :, i)))
end
saveas(h, 'nnmf_simple1_.2_0814.png')

h = figure; 
for i = 21:40
    subplot(4, 5, i-20)
    imagesc(squeeze(components(:, :, i)))
end
saveas(h, 'nnmf_simple2_.2_0814.png')

h = figure; 
for i = 41:50
    subplot(4, 5, i-40)
    imagesc(squeeze(components(:, :, i)))
end
saveas(h, 'nnmf_simple3_.2_0814.png')


% remove the 49th component
W_all = W(:, [1:48, 50]);
save('nnmf_components_0814.mat', 'W_all')






%% proj all data onto the selected components

clear; clc;
load('nnmf_components_0814.mat')

downSampleRatio = 0.2;

% ----------- sleep data --------------
load('SleepVid_s.mat');
sz = size(SleepVid_s);
img = reshape(SleepVid_s, sz(1) * sz(2), sz(3));
H_tmp = W_all' * img;

for t = 1:size(H_tmp, 2)
    normH(t) = norm(H_tmp(:, t));
end
H_norm{1} = H_tmp ./ repmat(normH, 49, 1);



% --------- awake data (3 states) ---------
% --- BOS
load('6636_July1_awake_BOS.mat');
CompVidBOS_s = imresize(permute(CompVidBOS, [2, 3, 1]), downSampleRatio, 'bilinear');
sz = size(CompVidBOS_s);
img = reshape(CompVidBOS_s, sz(1) * sz(2), sz(3));
H_tmp = W_all' * img;

clear normH
for t = 1:size(H_tmp, 2)
    normH(t) = norm(H_tmp(:, t));
end
H_norm{2} = H_tmp ./ repmat(normH, 49, 1);


% --- CON
load('6636_July1_awake_CON.mat');
CompVidCON_s = imresize(permute(CompVidCON, [2, 3, 1]), downSampleRatio, 'bilinear');
sz = size(CompVidCON_s);
img = reshape(CompVidCON_s, sz(1) * sz(2), sz(3));
H_tmp = W_all' * img;

clear normH
for t = 1:size(H_tmp, 2)
    normH(t) = norm(H_tmp(:, t));
end
H_norm{3} = H_tmp ./ repmat(normH, 49, 1);


% --- SONG
load('6636_July1_awake_SONG.mat');
CompVidSONG_s = imresize(permute(CompVidSONG, [2, 3, 1]), downSampleRatio, 'bilinear');
sz = size(CompVidSONG_s);
img = reshape(CompVidSONG_s, sz(1) * sz(2), sz(3));
H_tmp = W_all' * img;

clear normH
for t = 1:size(H_tmp, 2)
    normH(t) = norm(H_tmp(:, t));
end
H_norm{4} = H_tmp ./ repmat(normH, 49, 1);




%% embedd with t-SNE
H_total = [];
stateId = [];
for i = 1:length(H_norm)
    H_total = [H_total, H_norm{i}];
    stateId = [stateId, i * ones(1, size(H_norm{i}, 2))];
end
embedId = 1 : 4 : length(stateId); % only embed every 4 point, 5hz sampling rate (imaging is 20hz)



perVector = [200, 500, 1000];
for p = 1:length(perVector)
    perValue = perVector(p);
    for d = 1:2
        no_dims = d + 1;
        initial_dims = size(H_total, 1);
        pts_tsne{p}{d} = tsne(H_total(:, embedId)', [], no_dims, initial_dims, perValue);

        colors = jet(4);
        colorMat = colors(stateId(embedId), :);


        stateId_embed = stateId(embedId);
        states = {'SLEEP', 'BOS', 'CON', 'SONG'};

        for s = 1:4
            tmp{s} = find(stateId_embed == s);
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
        titleName = ['SLEEP-b BOS-c CON-y SONG-r  perplexity', num2str(perValue)];
        title(titleName)
        fn = ['AllStates_perplexity', num2str(perValue), 'dim', num2str(no_dims), '.png'];
        saveas(h, fn)
    end
end

save('embedded_allStates_0814.mat', 'pts_tsne')
save('downSampledMovies.mat', 'SleepVid_s', 'CompVidBOS_s', 'CompVidCON_s', 'CompVidSONG_s', 'embedId', 'pts_tsne', 'H_norm', 'W_all');



%% plot frame and spectrogram after t-SNE

% concat movies
totalMovie = cat(3, SleepVid_s, CompVidBOS_s, CompVidCON_s, CompVidSONG_s);
totalMovie_embed = totalMovie(:, :, embedId);

load('SleepSound.mat')
totalSpec = cat(3, permute(CompSpec, [2, 3, 1]), permute(CompSpecBOS, [2, 3, 1]), permute(CompSpecCON, [2, 3, 1]), permute(CompSpecSONG, [2, 3, 1]));
totalSpec_embed = totalSpec(:, :, embedId);
stateId_embed = stateId(embedId);
save('plotInput_tSNE.mat', 'pts_tsne', 'totalMovie_embed', 'totalSpec_embed', 'tmp', 'stateId_embed', 'states', 'perVector', '-v7.3');

p = 1;
d = 2;
s = 0;
[px, py] = plot_tSNEpick_GUI(p, d, s, pts_tsne, totalMovie_embed, totalSpec_embed, tmp, stateId_embed, states, perVector);