% clear; clc;

downSample_scale = 0.5;
is_dFF = 1;
is_removeMotion = 0;
is_SVD = 0;
% is_L2distance = 1:3;
frames = 3000;
Ncluster = [50, 100];
is_local = 1;
sigma_c = 1.5;
leftonly = 0;



filelist = readtext('files.txt', ' ');
fnms = filelist(:, 1);
% fnms2 = filelist(:, 2);
mask_fnms = filelist(:, 2);
% svd_fnms = filelist(:, 4);
W = cell(length(fnms)+1, 2);
motion_Id = cell(length(fnms));
no_movies = length(fnms);
for n = 1:length(fnms)
% n = 1
    fnm = fnms{n};
    imgall = openMovie(fnm);
    imgall = imresize(imgall, downSample_scale, 'bilinear'); % downsample the movie matrix
%     img2 = openMovie(fnms2{n});
%     img2 = imresize(img2, downSample_scale, 'bilinear');
%     imgall = cat(3, imgall, img2);
%     clear img2
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
    mask = M.roi{1} + M.roi{2};
    bmask = imresize(mask, downSample_scale, 'bilinear'); % downsample the mask in the same way as for the data
    imgall = reshape(imgall, sz(1), sz(2), sz(3));
%     imgall2 = reshape(imgall, sz(1), sz(2), sz(3)) .* repmat(bmask, 1, 1, sz(3));
%     img_inmask = single(imgall(non_id{m},:));
    imgall2 = imresize(imgall, .5, 'bilinear');
    [AVx, AVy] = computeFlowField_xx(imgall2, sz);
    for f = 1:10
        figure; quiver(AVx(:, :, f), AVy(:, :, f));
        set(gca,'Ydir','Normal')
    end
    
%     opticFlow = opticalFlowLK;
%     OF = opticFlow(imgall2);
%     movie0 = imresize(imgall2, .5, 'bilinear');
%     [AVx, AVy] = computeFlowField_xx(movie0, sz);
    AVx_s = AVx .* repmat(imresize(bmask, .5, 'bilinear'), 1, 1, sz(3)-1);
    AVy_s = AVy .* repmat(imresize(bmask, .5, 'bilinear'), 1, 1, sz(3)-1);
    AVx_s = imresize(AVx_s, 0.25, 'bilinear');
    AVy_s = imresize(AVy_s, 0.25, 'bilinear');
    
    for f = 1:20
        figure; quiver(AVx_s(:, :, f), AVy_s(:, :, f));
        set(gca,'Ydir','Reverse')
    end

end