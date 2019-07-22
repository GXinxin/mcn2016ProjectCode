%% get d prime for big regions
cd 'C:\Users\Administrator\Desktop\Xinxin\StateData\2015-2-19 emx gcamp6 P4'
% load('2015-ParcellationResult_small.mat')
load('components_states_0822_smallMask.mat')
load('ParcellationResult.mat')

regions = squeeze(group_label{1}(1, :, :));
figure; imagesc(regions)

selectedR = 1:50;

% figure; 
% for r = 1:length(selectedR)
%     subplot(2, 3, r)
%     imagesc(regions == selectedR(r))
% end

% embedId = 1 : 3 : length(stateId);
sleepMovie = cat(2, NREM_movie, REM_movie);
% totalMovie_embed = totalMovie(:, embedId);
% totalMovie_embed = reshape(totalMovie_embed, size(twoHemLabel(1, :, :), 2), size(twoHemLabel(1, :, :), 3), length(embedId));


for r = 1:length(selectedR)
    clusterId{r} = find(regions(:) == selectedR(r));
    sleepValue(r, :) = sum(sleepMovie(clusterId{r}, 1:2318), 1) / length(clusterId{r}); 
    awakeValue(r, :) = sum(AWAKE_movie(clusterId{r}, :), 1) / length(clusterId{r}); 
    
    z_sleep(r, :) = zscore(sleepValue(r, :));
    z_awake(r, :) = zscore(awakeValue(r, :));
    
    
    dP(r) = (mean(awakeValue(r, :)) - mean(sleepValue(r, :))) / sqrt(0.5 * (std(awakeValue(r, :))^2 + std(sleepValue(r, :))^2));
    pVect_awake = hist(awakeValue(r, :), -0.1:0.02:0.3);
    pVect_sleep = hist(sleepValue(r, :), -0.1:0.02:0.3);
    awake_h = cumsum(pVect_awake);
    sleep_h = cumsum(pVect_sleep);
    [a, ks(r)] = kstest2(awake_h, sleep_h);
%     figure; hist(sleepValue(r, :)); 
%     h = findobj(gca,'Type','patch');
%     set(h,'FaceColor','r','EdgeColor','w','facealpha',0.75)
%     hold on
%     hist(awakeValue(r, :));
%     h2 = findobj(gca,'Type','patch');
%     set(h2,'EdgeColor','w','facealpha',0.6)
%     title(['d prime = ', num2str(dP(r))])
%     xlabel('dF/F')
%     ylabel('Freqency')
%     saveas(h, ['region', num2str(selectedR(r)), '.png'])
    


    KL1 = sum(pVect_awake .* (log2(pVect_awake)-log2(pVect_sleep)));
    KL2 = sum(pVect_sleep .* (log2(pVect_sleep)-log2(pVect_awake)));
    KL(r) = (KL1+KL2)/2;
end


imgPlot = zeros(size(regions));
for i = 1:length(selectedR)
    imgPlot(regions == i) = dP(i);
end
colormap jet
h = figure; imagesc(imgPlot); caxis([0, 1.3]); axis image; colormap jet; colorbar
saveas(h, 'dPrimeValue2.png')
