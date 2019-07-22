%% get averaged traces for each node after parcellation, and then concatenate states
cd 'C:\Users\Administrator\Desktop\Xinxin\StateData\2015-2-19 emx gcamp6 P4'
% cd 'C:\Users\Administrator\Desktop\Xinxin\StateData\VglutCon_p14'

clear; clc
% cd 'C:\Users\Administrator\Desktop\Xinxin\StateData\2015-1-10 emx gcamp6 P6'
% cd 'C:\Users\Administrator\Desktop\Xinxin\StateData\2015-1-8 emx gcamp6 P4'


load('ParcellationResult_small_0822.mat')
downSampleRatio = 0.25;
isSVD = 0;

Ncluster = [50, 100];

% Put two hemispheres together
sz = size(Label{1, 1}); % create an addition matrix to add to the right hemisphere
addition = ones(sz);
for c = 1:length(Ncluster)
    addition(c, :, :) = Ncluster(c) * addition(c, :, :);
end
addition = reshape(addition, sz(1), sz(2) * sz(3));

for r = size(Label, 1)
    right = double(reshape(Label{r, 2}, sz(1), sz(2) * sz(3)));
    right(right > 0) = right(right > 0) + addition(right > 0);
    twoHemLabel = reshape(right, sz(1), sz(2), sz(3)) + double(Label{r, 1});
end



filelist = readtext('files_concat.txt', ' ');
fnms = filelist(:, 1);
state_fnms = filelist(:, 2);
% svd_fnms = filelist(:, 3);
for n = 1:length(filelist)
    
    % get state frames
    load(state_fnms{n})
   
    if ~isempty(QS_frames)
        NREM{n} = QS_frames;
    end
    if ~isempty(sleepWhiskerPlusNuchalAS_frames)
        REM{n} = sleepWhiskerPlusNuchalAS_frames;
    end
    if ~isempty(wake_frames)
        AWAKE{n} = wake_frames;
    end
    
    
    % load movies
    fnm = fnms{n};
    img1 = openMovie(fnm);
    img1 = imresize(img1, downSampleRatio, 'bilinear'); % downsample the movie matrix
    fnm2 = dir(fullfile([fnm(1:end-4), '@0001.tif']));
    img2 = openMovie(fnm2.name);
    img2 = imresize(img2, downSampleRatio, 'bilinear'); % downsample the movie matrix
    imgall = cat(3, img1, img2);
    sz = size(imgall);
    clear img1 img2
    imgall = reshape(imgall, sz(1) * sz(2), sz(3));
    
    Amean = mean(imgall, 2);
    imgall = imgall ./ (Amean * ones(1, size(imgall, 2))) - 1;
    
    if isSVD 
        load(svd_fnms{n})
        eigSz = size(Amean);
        eigVectors = imresize(reshape(mixedfilters2, eigSz(1), eigSz(2), size(mixedfilters2, 2)), 0.5, 'bilinear');
        eigVectors = reshape(eigVectors, sz(1)*sz(2), size(mixedfilters2, 2));
        
        eigenLoad = imgall' * eigVectors;
        imgall = eigenLoad * eigVectors';
        imgall = imgall';
    end

    
    if n == 1
        NREM_movie = imgall(:, NREM{n});
        REM_movie = imgall(:, REM{n});
        AWAKE_movie = imgall(:, AWAKE{n});
    else
        NREM_movie = cat(2, NREM_movie, imgall(:, NREM{n}));
        REM_movie = cat(2, REM_movie, imgall(:, REM{n}));
        AWAKE_movie = cat(2, AWAKE_movie, imgall(:, AWAKE{n}));
    end
    
end



for i = 1 : size(twoHemLabel, 1)
    labels = squeeze(twoHemLabel(i, :, :));
    for c = 1 : length(unique(labels(:)))-1
        clusterId{i}{c} = find(labels(:) == c);
        NREM_W{i}(c, :) = sum(NREM_movie(clusterId{i}{c}, :), 1) / length(clusterId{i}{c}); 
        REM_W{i}(c, :) = sum(REM_movie(clusterId{i}{c}, :), 1) / length(clusterId{i}{c});
        AWAKE_W{i}(c, :) = sum(AWAKE_movie(clusterId{i}{c}, :), 1) / length(clusterId{i}{c});
    end
end

save('components_states_0822_smallMask.mat', 'NREM', 'NREM_movie', 'NREM_W', 'REM', 'REM_movie', 'REM_W', 'AWAKE', 'AWAKE_movie', 'AWAKE_W', 'twoHemLabel')





%% label continuous or incontinuous state frames (keep track of segments, for looking at dynamics)

for n = 1 : length(state_fnms)
    
    load(state_fnms{n});
    
    if ~isempty(QS_frames)
        NREM{n} = QS_frames;
    end
    if ~isempty(sleepWhiskerPlusNuchalAS_frames)
        REM{n} = sleepWhiskerPlusNuchalAS_frames;
    end
    if ~isempty(wake_frames)
        AWAKE{n} = wake_frames;
    end
    
    
    % get consecutive segments from each state
    AWAKE_segment{n}(1, :) = [1, find(AWAKE{n}(2:end) - AWAKE{n}(1:end-1) > 1) + 1];
    AWAKE_segment{n}(2, :) = [find(AWAKE{n}(2:end) - AWAKE{n}(1:end-1) > 1), length(AWAKE{n})];
    NREM_segment{n}(1, :) = [1, find(NREM{n}(2:end) - NREM{n}(1:end-1) > 1) + 1];
    NREM_segment{n}(2, :) = [find(NREM{n}(2:end) - NREM{n}(1:end-1) > 1), length(NREM{n})];
    REM_segment{n}(1, :) = [1, find(REM{n}(2:end) - REM{n}(1:end-1) > 1) + 1];
    REM_segment{n}(2, :) = [find(REM{n}(2:end) - REM{n}(1:end-1) > 1), length(REM{n})];
    
    
end


for n = 1:length(state_fnms)
    stateLen_movie(n, :) = [length(AWAKE{n}), length(NREM{n}), length(REM{n})];
end


AWAKE_segmentTotal = [];
NREM_segmentTotal = [];
REM_segmentTotal = [];
for n = 1:length(state_fnms)
    AWAKE_segmentTotal = [AWAKE_segmentTotal, AWAKE_segment{n} + sum(stateLen_movie(1:n-1, 1))];
    NREM_segmentTotal = [NREM_segmentTotal, NREM_segment{n} + sum(stateLen_movie(1:n-1, 2))];
    REM_segmentTotal = [REM_segmentTotal, REM_segment{n} + sum(stateLen_movie(1:n-1, 3))];
end

save('stateSegmentOnOff_0819.mat', 'AWAKE_segment', 'NREM_segment', 'REM_segment', 'AWAKE_segmentTotal', 'NREM_segmentTotal', 'REM_segmentTotal')

