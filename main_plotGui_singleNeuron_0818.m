%% main function for arrow plot gui, song bird data
cd 'C:\Users\Administrator\Desktop\Xinxin\6636_July1'

load('6636_July1_sleep_spec_s.mat')
load('6636_July1_awake_spec_s.mat')

load('6636_July1_SleepVid_s.mat')
load('6636_July1_awakeVidBOS_s.mat')
load('6636_July1_awakeVidCON_s.mat')
load('6636_July1_awakeVidSONG_s.mat')
load('6636_July1_awakeVidnsyllable_s.mat')


load('plotInput_tSNE_0817_thresh0.07.mat')

embedId = selectId(1 : 2 : length(selectId)); % only embed every 2 point from the selected frames (imaging is 20hz)

% concat movies
totalMovie = cat(3, SleepVid_s, CompVidBOS_s, CompVidCON_s, CompVidSONG_s, COMPdffVIDEO_nsyllable);
totalMovie_embed = totalMovie(:, :, embedId);

totalSpec = cat(3, CompSpecSLEEP_s, CompSpecBOS_s, CompSpecCON_s, CompSpecSONG_s, CompSpecNS_s);
totalSpec_embed = totalSpec(:, :, embedId);

save('plotInput_tSNE_0817_thresh0.07.mat', 'pts_tsne', 'totalMovie_embed', 'totalSpec_embed', 'tmp', 'stateId_embed', 'stateId', 'perVector', '-v7.3');

% load('embedded_allStates_0817.mat')
p = 3;
d = 2;
s = 0;
states = {'SLEEP', 'BOS', 'CON', 'SONG', 'NOSYLLABLE'};
[px, py] = plot_tSNEpick_GUI(1, p, d, s, pts_tsne, totalMovie_embed, totalSpec_embed, tmp, stateId_embed, states, perVector, 1);

%% plot result from embedding of single states
load('embedded_allStates_0817_single_thresh0.07.mat')

for s = 1:5
    if s == 1 || s == 5
        embedId{s} = 1:4:size(Y_r_single{s}, 2);
    else
        embedId{s} = 1:2:size(Y_r_single{s}, 2);
    end
end


totalMovie2{1} = SleepVid_s;
totalMovie2{2} = CompVidBOS_s;
totalMovie2{3} = CompVidCON_s;
totalMovie2{4} = CompVidSONG_s;
totalMovie2{5} = COMPdffVIDEO_nsyllable;

totalSpec2{1} = CompSpecSLEEP_s;
totalSpec2{2} = CompSpecBOS_s;
totalSpec2{3} = CompSpecCON_s;
totalSpec2{4} = CompSpecSONG_s;
totalSpec2{5} = CompSpecNS_s;


p = 4;
d = 3;
s = 2;

totalMovie_embed = totalMovie2{s}(:, :, embedId{s});
totalSpec_embed = totalSpec2{s}(:, :, embedId{s});

states = {'SLEEP', 'BOS', 'CON', 'SONG', 'NOSYLLABLE'};
[px, py] = plot_tSNEpick_GUI(1, p, d, s, pts_tsne_single{s}, totalMovie_embed, totalSpec_embed, [], embedId, states, perVector);