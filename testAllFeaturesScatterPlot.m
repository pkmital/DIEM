%%
% addpath(genpath(pwd));
getAllFeaturesAndEntropies;
num_bins = 5;
y = all_entropies;
X = all_features;
num_features = 15;

%% plot each feature
h=formatFigure(1);
for feature_i = 1:num_features
    subplot(3,5,feature_i)
    hold on
    plot(all_features(:,feature_i));
    title([audio_features{feature_i}], 'FontSize', 14)
    hold off,
end

%% plot the distribution of each feature
h=formatFigure(2);
for feature_i = 1:num_features
    subplot(3,5,feature_i)
    hold on
    hist(all_features(:,feature_i),50);
    title([audio_features{feature_i}], 'FontSize', 14)
    hold off,
end

%% compute the bins
min_entropy = min(y);
max_entropy = max(y);
bin_step = (max_entropy-min_entropy) / num_bins;

xes = 1 : num_bins;

idxs = logical(zeros(length(all_entropies),num_bins));
for bin_i = 1 : num_bins
    idxs(:,bin_i) = (y >= (min_entropy + (bin_i-1)*bin_step)) ...
         & (y < (min_entropy + bin_i*bin_step));
    percent_of_frames = length(find(idxs(:,bin_i))) / length(all_entropies) * 100;
    fprintf('Bin %d explains %3.2f percent of the data\n', bin_i, percent_of_frames);
end

%% binned entropy analysis of features
h=formatFigure(3);
for feature_i = 1:num_features
    subplot(3,5,feature_i)
    hold on
    
    feature_binned = zeros(num_bins,2);
    for bin_i = 1 : num_bins
        feature_binned(bin_i,1) = mean(X(idxs(:,bin_i),feature_i));
        feature_binned(bin_i,2) = std(X(idxs(:,bin_i),feature_i)) ...
            / sqrt(length(X(idxs(:,bin_i),feature_i)));
    end


    plot(xes, feature_binned(:,1))
    errorbar(xes, feature_binned(:,1), feature_binned(:,2));
    set(gca,'XTick', 1:num_bins)
    set(gca, 'LooseInset', get(gca,'TightInset'));
    xlim([0,num_bins+1])
    title([audio_features{feature_i}], 'FontSize', 14)
    
    xlabel('Attentional Synchrony Bin')
    ylabel('Feature Val')
end
mtit('DIEM 1 - Feature Value',...
        'fontsize',14,'color',[1 0 0],...
        'xoff',0,'yoff',.045);
print(h,'-dpdf',sprintf('-r%d',300),[output_directory '/allfeatures_scatterplot.pdf']);
    

    
y = all_entropies;
X = all_features_mean;


xes = 1 : num_bins;
%% binned entropy analysis of features
h=formatFigure(4);
for feature_i = 1:num_features
    subplot(3,5,feature_i)
    hold on
    
    feature_binned = zeros(num_bins,2);
    for bin_i = 1 : num_bins
        feature_binned(bin_i,1) = mean(X(idxs(:,bin_i),feature_i));
        feature_binned(bin_i,2) = std(X(idxs(:,bin_i),feature_i)) ...
            / sqrt(length(X(idxs(:,bin_i),feature_i)));
    end


    plot(xes, feature_binned(:,1))
    errorbar(xes, feature_binned(:,1), feature_binned(:,2));
    set(gca,'XTick', 1:num_bins)
    set(gca, 'LooseInset', get(gca,'TightInset'));
    xlim([0,num_bins+1])
    title(['LP ' audio_features{feature_i}], 'FontSize', 14)
    
    xlabel('Attentional Synchrony Bin')
    ylabel('Feature Val')
end
mtit('DIEM 1 - Feature Low Pass',...
        'fontsize',14,'color',[1 0 0],...
        'xoff',0,'yoff',.045);
print(h,'-dpdf',sprintf('-r%d',300),[output_directory '/allfeatures_lowpass_scatterplot.pdf']);
    

    
y = all_entropies;
X = all_features_dev;

%% binned entropy analysis of features
h=formatFigure(5);
feature_binned = zeros(num_features,num_bins,2);
for feature_i = 1:num_features
    subplot(3,5,feature_i)
    hold on
    
    for bin_i = 1 : num_bins
        feature_binned(feature_i,bin_i,1) = mean(X(idxs(:,bin_i),feature_i));
        feature_binned(feature_i,bin_i,2) = std(X(idxs(:,bin_i),feature_i)) ...
            / sqrt(length(X(idxs(:,bin_i),feature_i)));
    end


    plot(xes, feature_binned(feature_i,:,1))
    errorbar(xes, feature_binned(feature_i,:,1), feature_binned(feature_i,:,2));
    set(gca,'XTick', 1:num_bins)
    set(gca, 'LooseInset', get(gca,'TightInset'));
    xlim([0,num_bins+1])
    title(['\Delta ' audio_features{feature_i}], 'FontSize', 14)
    
    xlabel('Attentional Synchrony Bin')
    ylabel('Feature Val')
end
mtit('DIEM 1 - Feature Contrast',...
        'fontsize',14,'color',[1 0 0],...
        'xoff',0,'yoff',.045);
print(h,'-dpdf',sprintf('-r%d',300),[output_directory '/allfeatures_deviation_scatterplot.pdf']);
    

    