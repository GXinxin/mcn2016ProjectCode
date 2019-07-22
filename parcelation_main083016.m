% this performs the basic parcellation 08/30/16


addpath /home2/xg77/parcellationCode
addpath /fastscratch/xg77/parcellation
addpath /home2/xg77/CalciumImgCode  
addpath(genpath('/home2/xg77/CalciumImgCode/piotr_toolbox'))
addpath(genpath('/home2/xg77/CalciumImgCode/wholeBrainDX'))
addpath(genpath('/home2/xg77/CalciumImgCode/sigTOOL'))
addpath(genpath('/home2/xg77/CalciumImgCode/CalciumDX'))
addpath(genpath('/home2/xg77/CalciumImgCode/bfmatlab'))

% cd 'D:\Lab\Data\data_from_Jake\2-8-2016'
% cd 'C:\Users\Administrator\Desktop\Xinxin\StateData\2015-1-8 emx gcamp6 P4'
% cd 'C:\Users\Administrator\Desktop\Xinxin\StateData\2015-1-10 emx gcamp6 P6'
% cd 'C:\Users\Administrator\Desktop\Xinxin\StateData\2015-2-19 emx gcamp6 P4'

clear; clc;

downSample_scale = 0.25;
is_dFF = 1;
is_removeMotion = 0;
is_SVD = 0;
% is_L2distance = 1:3;
frames = 3000;
Ncluster = [50, 100];
is_local = 1;
sigma_c = 1.5;
leftonly = 0;
rotateAngle = 180;


filelist = readtext('files_par.txt', ' ');
fnms = filelist(:, 1);
fnms2 = filelist(:, 2);
mask_fnms = filelist(:, 3);
% svd_fnms = filelist(:, 4);
W = cell(length(fnms)+1, 2);
motion_Id = cell(length(fnms));
no_movies = length(fnms);

for n = 1:length(fnms)
% n = 1
    fnm = fnms{n};
    imgall = openMovie(fnm);
    imgall = imresize(imgall, downSample_scale, 'bilinear'); % downsample the movie matrix
    img2 = openMovie(fnms2{n});
    img2 = imresize(img2, downSample_scale, 'bilinear');
    imgall = cat(3, imgall, img2);
    clear img2
    imgall = imrotate(imgall, rotateAngle);
    sz = size(imgall);
    imgall = reshape(imgall, sz(1) * sz(2), sz(3));
    
    if (is_dFF)
        Amean = mean(imgall, 2);
        imgall = imgall ./ (Amean * ones(1, size(imgall, 2))) - 1;
    end
    
    
    % apply SVD, reconstruct based on good PCs
    if is_SVD
        load(svd_fnms{n})
        eigenLoad = imgall' * mixedfilters2;
        imgall = eigenLoad * mixedfilters2';
        imgall = imgall';
    end

    mask_fn = mask_fnms{n};
    
    M = load(mask_fn);
    for m = 1:2
        mask = M.roi{m};
        bmask{m} = imresize(mask, downSample_scale, 'bilinear'); % downsample the mask in the same way as for the data
        non_id{m} = find(bmask{m} == 1);
        img_inmask = single(imgall(non_id{m},:));


        dist = L2_distance(img_inmask', img_inmask');  % Euclidean distance between voxels
        type = 'L2';


        if is_local
            % local sigma
            sigma_row = median(dist,1);
            sigma_col = median(dist,2);
            weight = double(exp(-dist.^2./(sigma_col*sigma_row)));
        else
            % global sigma
            sigma = mean(dist(find(dist(:)))) * sigma_c;
            weight = double(exp(- dist.^2/(sigma^2)));  % the similarity matrix
        end

        W{n, m} = weight;
        [pathstr, name, ext] = fileparts(fnm);                   
    end
    BMasks{n} = bmask;    
end

% get mean weight matrix
mean_w = {0, 0};
for m = 1:2
    for n = 1:no_movies
        mean_w{m} = mean_w{m} + W{n, m};
    end
    W{n+1, m} = mean_w{m}/no_movies;
end


save([name(1:end-6), 'weightMatrix_twoHem.mat'], 'W', 'BMasks', 'Ncluster', 'frames', 'is_local', 'sigma_c', 'non_id', 'motion_Id');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main single parcellation (including mean weight)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for m = 1:2
    len = length(non_id{m});
    for n = 1:size(W, 1)
        weight = W{n, m};
        for c = 1:length(Ncluster)
            no_cluster = Ncluster(c);
            label = xilin_cluster_single(weight, 1:len, no_cluster);    
            label_img = zeros(size(bmask{m}));
            label_img(non_id{m}) = label;
            L(c, :, :) = label_img;
        end 
        Label{n, m} = L;
    end
end






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get glocal parcellation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% step 1: load all weight matrices to matlab
% apply eigen-decomposition

group_label = cell(1, 2);
for m = 1:2
    for c = 1:length(Ncluster)
        no_cluster = Ncluster(c);
            
        for r = 1:no_movies
            bmask = BMasks{r};
            w = W{r, m};    
            if r == 1
            % need to load a mask first to determine the size of the weight matrix (number of pixels)
                len = length(non_id{m});
                sub_data = zeros(len, no_cluster, no_movies);
                sub_data_ind = repmat(1:len, no_movies, 1)';
                sub_data_ind_len = ones(1, no_movies)*len;
            end
            
            % apply the eigen-decomposition to the weight matrix
            [NEigenvec,NEigenval] = my_ncut(w, no_cluster); 

            % save the normalized eigenvectors to variable "sub_data"
            vm = sqrt(sum(NEigenvec.^2, 2));  % compute the norm of each row
            sub_data(:, :, r) = NEigenvec./repmat(vm,1, no_cluster);              
        end
        
        % step 2: perform the groupwise parcellation
        [cross_result, cross_value] = group_ncut_cpu(no_movies, no_cluster, sub_data, sub_data_ind, sub_data_ind_len, bmask{m});

        % step 3: select the group labelled image
        [vv, vv_id] = min(cross_value);
        group_label{m}(c, :, :) = cross_result{vv_id};
    end
end

Label(no_movies + 2, :) = group_label;



save([name(1:end-6), 'ParcellationResult.mat'], 'Label', 'group_label', 'frames', 'Ncluster', 'BMasks');







