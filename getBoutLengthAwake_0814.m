% get time points with no syllables from dbase (awake data)

cd 'C:\Users\Administrator\Desktop\Xinxin\6636_July1\awake'
load('analysis.mat')

Fs = 40000;
imgFs = 20;
for i = 1:length(dbase.SegmentTimes)
    if ~isempty(dbase.SegmentTimes{i})
        On = floor(dbase.SegmentTimes{i}(:, 1)/ Fs * imgFs) - .1 * imgFs;
        Off = floor(dbase.SegmentTimes{i}(:, 1)/ Fs * imgFs) + .1 * imgFs;
        noS_segment{i} = 1:On(1);
        for s = 1:length(On)-1
            noS_segment{i} = [noS_segment{i}, Off(s) : On(s+1)];
        end
        noS_segment{i} = [noS_segment{i}, Off(end):floor(dbase.FileLength(i)/ Fs * imgFs)];
    else
        noS_segment{i} = 1:floor(dbase.FileLength(i)/ Fs * imgFs);
    end
end
save('noS_segment.mat', 'noS_segment');

%% get compiled no syllable period, save the movie and spectrogram separately
cd 'C:\Users\Administrator\Desktop\Xinxin\6636_July1\awake'
filelist = dir(fullfile('*_row*.mat'));
load('noS_segment.mat')

Fs = 40000;
imgFs = 20;
COMPdffVIDEO_s = [];
COMPdffVIDEO_nsyllable = [];
COMPspec_ns = [];
for i = 7:length(dbase.SegmentTimes)
% for i = 7:7
    fn = filelist(i).name;
    load(fn);
    clear VIDEO
    
    segment = noS_segment{i};
    dffVIDEO_single = imresize(permute(dffVIDEO, [2, 3, 1]), .2, 'bilinear');
    if i == 1
        COMPdffVIDEO_s = dffVIDEO_single;
        COMPdffVIDEO_nsyllable = dffVIDEO_single(:, :, segment);
        COMPspec_ns = permute(SPEC(segment, :, :), [2, 3, 1]);
    else
        COMPdffVIDEO_s = cat(3, COMPdffVIDEO_s, dffVIDEO_single); 
        COMPdffVIDEO_nsyllable = cat(3, COMPdffVIDEO_nsyllable, dffVIDEO_single(:, :, segment));    
        COMPspec_ns = cat(3, COMPspec_ns, permute(SPEC(segment, :, :), [2, 3, 1]));
    end
    i
end

save('6636_July1_awakeSPECs_ns.mat', 'COMPspec_ns', '-v7.3');
save('6636_July1_awakeVid_s_nsyllable.mat', 'COMPdffVIDEO_nsyllable', '-v7.3');
save('6636_July1_awakeVid_s.mat', 'COMPdffVIDEO_s', '-v7.3');

