%% just to concatenate state ID in frames

stateId = [ones(1, size(SleepVid_s, 3)), 2*ones(1, size(CompSpecBOS_s, 3)), ...
    3*ones(1, size(CompSpecCON_s, 3)), 4*ones(1, size(CompSpecSONG_s, 3)), 5*ones(1, size(CompSpecNS_s, 3))];

save('6636_July1_concatStateId.mat', 'stateId')