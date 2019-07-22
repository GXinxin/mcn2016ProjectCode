
cd 'C:\Users\Administrator\Desktop\Xinxin\StateData\2015-1-8 emx gcamp6 P4'



fnm = '2015-1-8-9.tif';
fnm2 = '2015-1-8-9@0001.tif';

% load('150219_twoHemMask.mat');


downSampleRatio = .5;

%---Get SVDs---
A = openMovie(fnm);
A = imresize(A, downSampleRatio, 'bilinear');
B = openMovie(fnm2);
B = imresize(B, downSampleRatio, 'bilinear');
A = cat(3, A, B);
clear B

sz = size(A); szZ=sz(3);
% mask = imresize(roi{1} + roi{2}, downSampleRatio, 'bilinear');
% A = A .* repmat(mask, 1, 1, szZ);


nPCs = 300;

npix = prod(sz(1:2));
A = reshape(A, npix, szZ); %reshape 3D array into space-time matrix
Amean = mean(A, 2); %avg at each pixel location in the image over time
A = A ./ (Amean * ones(1,szZ)) - 1;   % F/F0 - 1 == ((F-F0)/F0);
Amean = reshape(Amean,sz(1),sz(2));
A = reshape(A, sz(1), sz(2), szZ);

[mixedsig, mixedfilters, CovEvals, covtrace, movtm] = wholeBrainSVD_xx(A, nPCs);

clear A

%---START interactive block---
figure;
viewPCs_xx(mixedfilters(:,:,1:nPCs));

figure; plot(CovEvals); ylabel('eigenvalue, \lambda^2'); xlabel('eigenvalue index (PC mode no.)'); zoom xon

figure; PlotPCspectrum(fnm, CovEvals, 1:250); zoom xon
%---END interactive block---


% badPCs = [1:4, 7, 9];  %***change these values*** % for 160317_rightspon
% after cAMP basPCs - 1:5;
badPCs = [1];
sz=size(mixedfilters);
npix = prod(sz(1:2));
szXY = sz(1:2); szZ = size(mixedsig,2);
PCuse=setdiff(1:nPCs, badPCs);  %***change these values***
mixedfilters2 = reshape(mixedfilters(:,:,PCuse),npix,length(PCuse));  
% mov = mixedfilters2 * diag(CovEvals(PCuse).^(1/2)) * mixedsig(PCuse,:);  
% mov = zscore(reshape(mov,npix*szZ,1));
% mov = reshape(mov, szXY(1), szXY(2), szZ);  

% implay(mat2gray(mov,[-6 6]))

% frStart = 1;
% frEnd = szZ;
% [maxProj, Iarr, MnMx] = timeColorMapProj(mov, frStart, frEnd, fnm);
% % [maxProj, Iarr, MnMx] = timeColorMapProj(A,frStart, frEnd, filename,[],MnMx);
% Iarr2avi(Iarr, frStart, frEnd, fnm) 

%can change these frames
figure; fr=1746; imagesc(mov(:,:,fr),[-6 6]); title(['fr' num2str(fr)]); axis image; colorbar
figure; fr=1093; imagesc(mov(:,:,fr),[-6 6]); title(['fr' num2str(fr)]); axis image; colorbar
figure; fr=929; imagesc(mov(:,:,fr),[-6 6]); title(['fr' num2str(fr)]); axis image; colorbar
figure; fr=531; imagesc(mov(:,:,fr),[-6 6]); title(['fr' num2str(fr)]); axis image; colorbar
frStart = 1;
frEnd = szZ;
filename = fnm;
[maxProj, Iarr, MnMx] = timeColorMapProj(mov, frStart, frEnd, filename);
% [maxProj, Iarr, MnMx] = timeColorMapProj(A,frStart, frEnd, filename,[],MnMx);
Iarr2avi(Iarr, frStart, frEnd, filename) 

%Save the results in the following format
save([fnm(1:end-4) '_svd_' datestr(now,'yyyymmdd-HHMMSS') '.mat'], 'mixedfilters', 'mixedfilters2', 'mixedsig', 'CovEvals', 'badPCs', 'PCuse', 'Amean','movtm','covtrace')