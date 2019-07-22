% 
clear; clc;
cd 'C:\Users\Administrator\Desktop\Xinxin\6636_July1';
fn = '6636_July1_awake_SONG.mat';

load(fn);

img = permute(CompVidSONG, [2, 3, 1]);
img = imresize(img, .25, 'bilinear');
img = img - min(img(:));
sz = size(img);
img = reshape(img, sz(1)*sz(2), sz(3));

[W, H] = nnmf(img, 30);
dColors = jet(8); 
labels = dColors(size(H, 1),:) .* repmat(sz(3),1,3) / sz(3);

no_dims = 2;
initial_dims = 30;
pts_tsne = tsne(H', [], no_dims, initial_dims, 100);

h = figure(1); 
scatter(pts_tsne(:, 1), pts_tsne(:, 2), 5*ones(sz(3), 1), jet(sz(3)))
xlabel('dim1')
ylabel('dim2')
saveas(h, [fn, '.png'])
