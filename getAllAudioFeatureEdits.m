load('/Users/pkmital/diem/matlab/stats/output2/diem1_entropies.mat')

addpath(genpath('/Users/pkmital/diem/matlab/'));

%% which diem are we running
diem = 1;

% get the movie names
movie_names = getDiemMovieNames(diem);

% get the cinematic features
[cine_features cine_feature_tags cine_feature_values] = getDiemCinematicFeatures(diem);

%% load the auditory features
audio_folder = ['/Users/pkmital/diem/matlab/audio_analysis/diem' num2str(diem) '/'];
audio_feature_filename = ['audio_features_diem' num2str(diem) '_movie'];
audio_features = {'centroid', ...
    'brightness', ...
    'roughness', ...
    'kurtosis', ...
    'spread', ...
    'skewness', ...
    'flatness', ...
    'rolloff85', ...
    'entropy', ...
    'regularity', ...
    'envelope', ...
    'spectralflux', ...
    'rms', ...
    'zcr', ...
    'novelty'};

%% load the stats of each frame and every movie
stats_folder = ['/Users/pkmital/diem/matlab/stats/output2'];
stats_filename = ['diem' num2str(diem) '_entropies'];
% load([stats_folder stats_filename], 'entropies', 'movie_names');

output_directory = ['output'];
mkdir(output_directory);

num_movies = length(entropies);

all_edits_entropies = {};
all_edits_features = {};
all_edits_features_mean = {};
all_edits_features_dev = {};

edit = 1;

%% process the scatter plot of each movie and every feature versus
%% the entropy of the eye-movements
for movie_i = 1:num_movies
    
    file_name = strrep(movie_names{movie_i}, '_', ' ');
    
    num_frames = length(entropies{movie_i});
    
    fprintf('Processing %2d/%2d: %s (%d frames)\n', movie_i, num_movies, file_name, num_frames);
    
    % load the audio features
    load([audio_folder audio_feature_filename num2str(movie_i)]);
    num_features = length(audio_features);
    
    % i'm taking the nearest audio frame to a given video frame.
    frame_ratio = length(audiofeatures.entropy) / num_frames;
    
    % get the edits
    edits = double(cine_features{movie_i}{1});
    edits = [round(edits ./ 1000.0 .* 30.0) + 1];
    
    % remove edits which exist after the length of the movie (this can
    % happen if the data we have for eye-movements is less than the length
    % of the actual movie)
    i = length(edits);
    while(i > 0 && edits(i) > num_frames)
        edits(i) = [];
        i = i - 1;
    end
    edits = [edits; num_frames];
    
    num_edits = length(edits);
    
    edit_i = 1;
    while edit_i < num_edits
        edit_indx = edits(edit_i):edits(edit_i+1);
        this_edit_entropies = entropies{movie_i}(edit_indx);
        fprintf('\tEdit %3d/%3d: %4d frames\n', edit_i, num_edits-1, length(this_edit_entropies));
        
        % index which frames have good subject data
        good_data = (this_edit_entropies > 0.0001) & ~isinf(this_edit_entropies) & ~isnan(this_edit_entropies);
        y = this_edit_entropies;
        y = y(good_data);
        
        % print how many frames were removed
        if( ~isempty(find(this_edit_entropies < 0.0001)) || ...
            ~isempty(find(isinf(this_edit_entropies))) || ...
            ~isempty(find(isnan(this_edit_entropies))))
            percent_bad = (1.0 - length(find(good_data)) / length(this_edit_entropies)) * 100;
            fprintf('\tRemoved %f percent of the data in the entropy vector due to bad data\n', percent_bad);
        end
        
        % if there aren't enough frames in this edit, remove the edit
        if length(good_data) < 2
            fprintf('\tRemoving edit due to no frames\n');
            num_edits = num_edits - 1;
            edits(edit_i) = [];
            continue;
        end
        
        all_edits_entropies{movie_i}{edit_i} = y;
        
        this_features = [];
        this_features_mean = [];
        this_features_dev = [];
        for feature_i = 1:num_features
            
            features = eval(['audiofeatures.' audio_features{feature_i}]);
            % fprintf('evaluating %s\n', audio_features{feature_i})
            if(size(features,2) == 2)
                features = features(:,1);
            end
            
            % flux starts at the second audio frame, so we have to insert a
            % frame in the beginning to keep our video to audio frame alignment
            if(strcmp(audio_features{feature_i},'spectralflux') == 1)
                features(2:end+1) = features(1:end);
                features(1) = 0;
            end
            
            % this is where we get just the audio frames at the nearest video
            % frame times
            [features features_mean features_dev] = myresample(features, edits(edit_i+1)-edits(edit_i)+1, frame_ratio, edits(edit_i));
            
            X = features(:);
            X_mean = features_mean(:);
            X_dev = features_dev(:);
            
            % remove the bad data from no eye-tracking information (results in
            % 0 entropy which is not right)
            X = X(good_data);
            X_mean = X_mean(good_data);
            X_dev = X_dev(good_data);
            
            this_features = [this_features X];
            this_features_mean = [this_features_mean X_mean];
            this_features_dev = [this_features_dev X_dev];
        end
        
        all_edits_features{movie_i}{edit_i} = this_features;
        all_edits_features_mean{movie_i}{edit_i} = this_features_mean;
        all_edits_features_dev{movie_i}{edit_i} = this_features_dev;
        
        edit_i = edit_i + 1;
        edit = edit + 1;
    end
%     
%     good_data = entropies{movie_i} > 0.0001 & ~isinf(entropies{movie_i}) & ~isnan(entropies{movie_i});
%     
%     y = entropies{movie_i};
%     y = y(good_data);
%     
%     if(~isempty(find(entropies{movie_i} < 0.0001)) || ~isempty(find(isinf(entropies{movie_i}))) || ~isempty(find(isnan(entropies{movie_i}))))
%         percent_bad = (1.0 - length(find(good_data)) / length(entropies{movie_i})) * 100;
%         fprintf('Removed %f percent of the data in the entropy vector due to bad data\n', percent_bad);
%     end
%     
%     all_entropies = [all_entropies; y];
% 
%     this_features = [];
%     this_features_mean = [];
%     this_features_dev = [];
%     for feature_i = 1:num_features
%         
%         features = eval(['audiofeatures.' audio_features{feature_i}]);
%         % fprintf('evaluating %s\n', audio_features{feature_i})
%         if(size(features,2) == 2)
%             features = features(:,1);
%         end
%         
%         % flux starts at the second audio frame, so we have to insert a
%         % frame in the beginning to keep our video to audio frame alignment
%         if(strcmp(audio_features{feature_i},'spectralflux') == 1)
%             features(2:end+1) = features(1:end);
%             features(1) = 0;
%         end
%         
%         % this is where we get just the audio frames at the nearest video
%         % frame times
%         [features features_mean features_dev] = myresample(features, length(entropies{movie_i}), frame_ratio);
%         
%         X = features(:);
%         X_mean = features_mean(:);
%         X_dev = features_dev(:);
%         
%         % remove the bad data from no eye-tracking information (results in
%         % 0 entropy which is not right)
%         X = X(good_data);
%         X_mean = X_mean(good_data);
%         X_dev = X_dev(good_data);
%         
%         this_features = [this_features X];
%         this_features_mean = [this_features_mean X_mean];
%         this_features_dev = [this_features_dev X_dev];
%     end
%     
%     all_features = [all_features; this_features];
%     all_features_mean = [all_features_mean; this_features_mean];
%     all_features_dev = [all_features_dev; this_features_dev];
%     
    
end