
%% which diem are we running
diem = 1;
movie_names = getDiemMovieNames(diem);
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
stats_folder = ['/Users/pkmital/diem/matlab/stats/'];
stats_filename = ['diem' num2str(diem) '_entropies'];
% load([stats_folder stats_filename], 'entropies', 'movie_names');

output_directory = ['output'];
mkdir(output_directory);

num_movies = length(entropies);

r_sq_correlation = ...
    struct( 'centroid', [], ...
    'brightness', [], ...
    'roughness', [], ...
    'kurtosis', [], ...
    'spread', [], ...
    'skewness', [], ...
    'flatness', [], ...
    'rolloff85', [], ...
    'entropy', [], ...
    'regularity', [], ...
    'envelope', [], ...
    'spectralflux', [], ...
    'rms', [], ...
    'zcr', [], ...
    'novelty', []);

%% process the scatter plot of each movie and every feature versus
%% the entropy of the eye-movements
for movie_i = 1:num_movies
    
    file_name = strrep(movie_names{movie_i}, '_', ' ');
    
    % load the audio features
    load([audio_folder audio_feature_filename num2str(movie_i)]);
    num_features = length(audio_features);
    
    % i'm taking the nearest audio frame to a given video frame.
    frame_ratio = length(audiofeatures.entropy) / length(entropies{movie_i});
    
    good_data = entropies{movie_i} > 0.0001 & ~isinf(entropies{movie_i}) & ~isnan(entropies{movie_i});
    
    y = entropies{movie_i};
    y = y(good_data);
    
    if(~isempty(find(entropies{movie_i} < 0.0001)) || ~isempty(find(isinf(entropies{movie_i}))) || ~isempty(find(isnan(entropies{movie_i}))))
        percent_bad = (1.0 - length(find(good_data)) / length(entropies{movie_i})) * 100;
        fprintf('Removed %f percent of the data in the entropy vector due to bad data\n', percent_bad);
    end
    
    
    
    %% plot a scatter plot of each feature versus entropy
    all_features = zeros(num_features, length(find(good_data)));
    h=formatFigure(1);
    for feature_i = 1:num_features
        
        subplot(3,5,feature_i)
        hold on
        
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
        [features features_dev] = myresample(features, length(entropies{movie_i}), frame_ratio);
        
        X = features(:);
        
        % remove the bad data from no eye-tracking information (results in
        % 0 entropy which is not right)
        X = X(good_data);
        
        all_features(feature_i,:) = X';
        %        [brob,rob_stats] = robustfit(y,X);
        %        rsquare_robustfit = corr(y,brob(1)+brob(2)*X)^2;
        
        X2 = [ones(size(X)) X];
        [b,bint,r,rint,stats] = regress(y,X2);
        fprintf('For %s, R-squared: %f\n', audio_features{feature_i}, stats(1));%, rsquare_robustfit);
        
        % features(isnan(features)) = 0;
        scatter(y, X, 'r+');
        set(gca, 'LooseInset', get(gca,'TightInset'));
        
        title([{audio_features{feature_i}},{['R^2: ' num2str(stats(1))]}])
    end
    
    mtit(file_name,...
        'fontsize',14,'color',[1 0 0],...
        'xoff',0,'yoff',.045);
    
    print(h,'-dpdf',sprintf('-r%d',300),[output_directory '/' file_name, '_scatterplot.pdf']);
    
    %% histogram of each feature
    h=formatFigure(2);
    for feature_i = 1:num_features
        subplot(3,5,feature_i)
        hold on
        features = eval(['audiofeatures.' audio_features{feature_i}]);
        hist(features,30)
        set(gca, 'LooseInset', get(gca,'TightInset'));
        title([{audio_features{feature_i}}]);
    end
    
    mtit(file_name,...
        'fontsize',14,'color',[1 0 0],...
        'xoff',0,'yoff',.045);
    print(h,'-dpdf',sprintf('-r%d',300),[output_directory '/' file_name, '_feature_histogram.pdf']);
    
    %% histogram of entropies
    h=formatFigure(3);
    hold on
    hist(y,30)
    title([{'Histogram of Entropies'}, {file_name}])
    ylabel('Frequency')
    xlabel('Bin')
    
    print(h,'-dpdf',sprintf('-r%d',300),[output_directory '/' file_name, '_entropy_histogram.pdf']);
    
    min_entropy = min(y);
    max_entropy = max(y);
    num_bins = 5;
    bin_step = (max_entropy-min_entropy) / num_bins;
    
    xes = 1 : num_bins;
    
    %% binned entropy analysis of features
    h=formatFigure(4);
    for feature_i = 1:num_features
        subplot(3,5,feature_i)
        hold on
        features = eval(['audiofeatures.' audio_features{feature_i}]);
        % this is where we get just the audio frames at the nearest video
        % frame times
        [features features_dev] = myresample(features, length(entropies{movie_i}), frame_ratio);
        X = features(:);
        % remove the bad data from no eye-tracking information (results in
        % 0 entropy which is not right)
        X = X(good_data);
        feature_binned = zeros(num_bins,2);
        for bin_i = 1 : num_bins
            idxs = y >= (min_entropy + (bin_i-1)*bin_step) & y < (min_entropy + bin_i*bin_step);
            feature_binned(bin_i,1) = mean(X(idxs));
            feature_binned(bin_i,2) = std(X(idxs)) / sqrt(length(X(idxs)));
        end
        
        
        plot(xes, feature_binned(:,1))
        errorbar(xes, feature_binned(:,1), feature_binned(:,2));
        set(gca,'XTick', 1:num_bins)
        set(gca, 'LooseInset', get(gca,'TightInset'));
        xlim([0,num_bins+1])
        title([{audio_features{feature_i}}], 'FontSize', 14)
        xlabel('Entropy Bin')
        ylabel('Feature Val')
    end
    
    mtit(file_name,...
        'fontsize',14,'color',[1 0 0],...
        'xoff',0,'yoff',.045);
    
    print(h,'-dpdf',sprintf('-r%d',300),[output_directory '/' file_name, '_binned_analysis.pdf']);
    
end