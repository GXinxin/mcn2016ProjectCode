% binary threshold each component

cd 'C:\Users\Administrator\Desktop\Xinxin\6636_July1'

load('constrainedNNMF_components.mat')
load('6636_July1_concatStateId.mat')
selectComponentId = [1:39, 41:43, 45:49];

for i = 1 : size(C, 1)
    binaryTrace(i, :) = Y_r(i, :) > 3*std(Y_r(i, :));
end



binaryTrace(i, :) = Y_r(i, :) > 3*std(Y_r(:));


for i = 1:size(Y_r, 1)
    h = figure; 
    subplot(2, 1, 1); plot(C(i, :)); 
    subplot(2, 1, 2); plot(binaryTrace(i, :))

%     title([num2str(thresh8(i)), ' ', num2str(thresh9(i)), ' ', num2str(thresh8(i+1)), ' ', num2str(thresh9(i+1))])
%     saveas(h, ['componentTrace', num2str(i), '.png'])
end


for i = 1:2:size(Y_r, 1)-1
    h = figure; 
    subplot(2, 1, 1); plot(C(i, :)); hold on; plot(binaryTrace(i, :))
    subplot(2, 1, 2); plot(C(i+1, :)); hold on; plot(binaryTrace(i+1, :))

%     title([num2str(thresh8(i)), ' ', num2str(thresh9(i)), ' ', num2str(thresh8(i+1)), ' ', num2str(thresh9(i+1))])
%     saveas(h, ['componentTrace', num2str(i), '.png'])
end