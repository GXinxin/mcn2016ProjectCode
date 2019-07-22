cd 'C:\Users\Administrator\Desktop\Xinxin\StateData'


img = openMovie('2015-2-19-1.tif');
% img = openMovie('1_VGlut_Con_p14_2_10_2016.tif');
% totalMask = masks{1} + masks{2};
% img = img .* repmat(totalMask, 1, 1, size(img, 3));
img = imresize(img, .5, 'bilinear');
img = img - min(img(:));
sz = size(img);
img = reshape(img, sz(1)*sz(2), sz(3));

[W, H] = nnmf(img, 100);

components = reshape(W, sz(1), sz(2), size(W, 2));

for i = 1:4
    h = figure; 
    for j = 1:25
        subplot(5, 5, j)
        imagesc(components(:, :, (i-1)*25 + j))
    end
    saveas(h, ['components', num2str(i), '.png'])
end

save('nnmf100_15021901_0814.mat', 'W', 'H')




%% test SVD
[U, S, V] = svd(img);



%% t-SNE
embedId = 1:2:size(H, 2);
perVector = [100, 200, 500, 1000];
for p = 1:length(perVector)
    perValue = perVector(p);
    for d = 1:2
        no_dims = d + 1;
        initial_dims = size(H, 1) - 7;
        pts_tsne{p}{d} = tsne(H(1:93, embedId)', [], no_dims, initial_dims, perValue);
        
        
        h = figure; 
        if no_dims == 2
            scatter(pts_tsne{p}{d}(:, 1), pts_tsne{p}{d}(:, 2), 5*ones(length(embedId), 1))
        else
            scatter3(pts_tsne{p}{d}(:, 1), pts_tsne{p}{d}(:, 2), pts_tsne{p}{d}(:, 3), 5*ones(length(embedId), 1))
        end
%         titleName = ['SLEEP-b BOS-c CON-y SONG-r  perplexity', num2str(perValue)];
%         title(titleName)
        fn = ['AllStates_perplexity', num2str(perValue), 'dim', num2str(no_dims), '.png'];
        saveas(h, fn)
        
    end
end