
audio_feature_tags = {  'centroid', 'brightness', 'roughness', 'kurtosis', 'spread', ...
                        'skewness', 'flatness', 'rolloff85', 'entropy', 'regularity', ...
                        'envelope', 'spectralflux', 'rms', 'zcr', 'novelty' }; 

bin = 200;
mis = [];

for i = 1 : 15
   mis(i) =  mi(all_features(:,i),all_entropies, bin);
   title(audio_feature_tags{i});
   pause
end

formatFigure(2);
plot(mis)
xlim([0 16])
set(gca, 'XTick', 1:15)
set(gca, 'XTickLabel', audio_feature_tags)
xlabel('audio features')
ylabel('mutual information with eye-movement entropy')
title(['bin size: ' num2str(bin)])


%%
rs = [];

for i = 1 : 15
   [wx wy r] = cca(all_features(:,i)',all_entropies');
   rs(i) = r;
end

formatFigure(3);
plot(rs)
xlim([0 16])
set(gca, 'XTick', 1:15)
set(gca, 'XTickLabel', audio_feature_tags)
xlabel('audio features')
ylabel('pearson correlation of audio feature with eye-movement entropy')
title(['pearson correlation'])
pause