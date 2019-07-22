function [AVx, AVy] = computeFlowField_xx(imgall, sz)

AVx = [];
AVy = [];
    
for f = 1:sz(3)-1
    img1 = imgall(:, :, f);
    img2 = imgall(:, :, f+1);
    [AVx(:, :, f), AVy(:, :, f), ~] = opticalFlow(img1, img2);
%     Vx = imresize(Vx, resizeRatio, 'bilinear');
%     Vy = imresize(Vy, resizeRatio, 'bilinear');
%     mag = sqrt(Vx.^2 + Vy.^2);
% 
%     id = mag > 0;
%     AVx(:, :, f) = Vx(:, :, f) .* id;
%     AVy(:, :, f) = Vy(:, :, f) .* id;
end