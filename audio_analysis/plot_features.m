mir_toolbox_directory = ['/Users/pkmital/Coding/Matlab/MIRtoolbox1.3.3'];
audio_directory = ['/Users/pkmital/diem/data/DIEM/Experiments/deploy/diem1/library/audio'];
output_directory = ['output'];
mkdir(output_directory);

addpath(genpath(mir_toolbox_directory));
files = dir([audio_directory '/*.wav']);

frame_size = 0.0929;
hop_size = 0.5;

for file_i = 1 : length(files)
    
    % get the file
    mir_file = miraudio([audio_directory '/' files(file_i).name]);
    
    % and the features
    mir_features = mirfeatures_frame(mir_file, frame_size, hop_size);
    
    % and stats on the features
    mir_stats = mirstat(mir_features);
    
    % save it in a matlab mat file
    save([output_directory '/' files(file_i).name(1:end-4) '_features.mat']);
    
    pause
end