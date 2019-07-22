%% plot gui for each state 
cd 'C:\Users\Administrator\Desktop\Xinxin\6636_July1'

load('embedded_allStates_0817_single_thresh0.07.mat')
selectComponentId = [1:39, 41:43, 45:49];
states = {'SLEEP', 'BOS', 'CON', 'SONG', 'NOSYLLABLE'};

load('6636_July1_sleep_spec_s.mat')
load('6636_July1_awake_spec_s.mat')

load('6636_July1_SleepVid_s.mat')
load('6636_July1_awakeVidBOS_s.mat')
load('6636_July1_awakeVidCON_s.mat')
load('6636_July1_awakeVidSONG_s.mat')
load('6636_July1_awakeVidnsyllable_s.mat')


% concat movies
totalMovie = cat(3, SleepVid_s, CompVidBOS_s, CompVidCON_s, CompVidSONG_s, COMPdffVIDEO_nsyllable);
totalSpec = cat(3, CompSpecSLEEP_s, CompSpecBOS_s, CompSpecCON_s, CompSpecSONG_s, CompSpecNS_s);

% if plot all states
embedId = embedId_th;
totalMovie_embed = totalMovie(:, :, embedId);
totalSpec_embed = totalSpec(:, :, embedId);

% % if plot each state separately
% for s = 1:length(states)    
%     movieSelected{s} = totalMovie(:, :, selectStateId(singleStateId{s}));
%     specSelected{s} = totalSpec(:, :, selectStateId(singleStateId{s}));
% end

save('plotInput_tSNE_0817_thresh0.07.mat', 'pts_tsne_single', 'movieSelected', 'specSelected', 'tmp', 'singleStateId', 'selectStateId', 'perVector', '-v7.3');
% save('plotInput_tSNE_0817_thresh0.07.mat', 'pts_tsne', 'totalMovie_embed', 'totalSpec_embed', 'tmp', 'stateId_embed', 'stateId', 'perVector', '-v7.3');


% load('embedded_allStates_0817.mat')
p = 1;
d = 2;
s = 0;
ss = 4;
pts_tsne = yData_th;
stateId_embed = stateId(embedId_th);
perVector = [32, 64, 96];
states = {'SLEEP', 'BOS', 'CON', 'SONG', 'NOSYLLABLE'};
[px, py] = plot_tSNEpick_GUI(1, p, d, s, pts_tsne, totalMovie_embed, totalSpec_embed, [], stateId_embed, states, perVector, ss);


% % for each state separately
% p = 1;
% d = 2;
% s = 2;
% Movie_embed = movieSelected{s};
% Spec_embed = specSelected{s};
% 
% [px, py] = plot_tSNEpick_GUI(0, p, d, s, pts_tsne_single{s}, Movie_embed, Spec_embed, [], [], states, perVector);