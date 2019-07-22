%% main for run_tSne, single neuron data
cd 'C:\Users\Administrator\Desktop\Xinxin\6636_July1'

load('constrainedNNMF_components.mat')
load('6636_July1_concatStateId.mat')
selectComponentId = [1:39, 41:43, 45:49];



%% original dataset, down sampled by embedId
embedId = 1:4:length(stateId);
for p = 1:3
    parameters.perplexity = 32 * p;    
    for d = 1:2
        parameters.num_tsne_dim = d + 1;
        parameters = setRunParameters(parameters);

        [yData{p}{d}, betas{p}{d}, P{p}{d}, errors{p}{d}] = run_tSne(C(:, embedId)', parameters);    
    end
end
save('tsneB_noThresh_0818.mat', 'yData', 'betas', 'P', 'errors', 'embedId', 'stateId', 'parameters', 'selectComponentId')



%% thresholded dataset, down sampled by new_embedId
C_total = C(selectComponentId, :);

cutOff = 0.05; % a hard cutoff
threshMat = repmat(cutOff, size(C_total));
selectMat = C_total > threshMat;
selectId = find(sum(selectMat, 1) > 0);
length(selectId)

embedId_th = selectId(1 : 4 : length(selectId)); % only embed every 2 point from the selected frames (imaging is 20hz)
C_total = C_total(:, embedId_th);

for p = 1:3
    parameters.perplexity = 32 * p;  
    for d = 1:2
        parameters.num_tsne_dim = d + 1;
        parameters = setRunParameters(parameters);
    
        [yData_th{p}{d}, betas_th{p}{d}, P_th{p}{d}, errors_th{p}{d}] = run_tSne(C_total', parameters);    
    end
end
save('tsneB_Thresh_0818.mat', 'yData_th', 'betas_th', 'P_th', 'errors_th', 'embedId_th', 'stateId', 'selectId', 'parameters', 'selectComponentId')





%% tsne after binarization

C_total = binaryTrace(selectComponentId, :);
selectId = find(sum(C_total, 1) > 0);
length(selectId)

embedId_th = selectId(1 : 4 : length(selectId)); % only embed every 2 point from the selected frames (imaging is 20hz)
C_total = C_total(:, embedId_th);

for p = 1:3
    parameters.perplexity = 32 * p;  
    for d = 1:2
        parameters.num_tsne_dim = d + 1;
        parameters = setRunParameters(parameters);
    
        [yData_th{p}{d}, betas_th{p}{d}, P_th{p}{d}, errors_th{p}{d}] = run_tSne(C_total', parameters);    
    end
end
save('tsneB_binaryThresh_0818.mat', 'yData_th', 'betas_th', 'P_th', 'errors_th', 'embedId_th', 'stateId', 'selectId', 'parameters', 'selectComponentId')





%% plot tsne, after threshold
