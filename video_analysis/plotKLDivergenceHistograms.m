entropy_dir = ['/Users/pkmital/diem/matlab/video_analysis/entropy_data'];
movie_names = getDiemShortMovieNames(1);

diff_hp_all = [];
diff_lp_all = [];
diff_sampled_all = [];

for file_i = 1 : length(movie_names)
   dir_struct = dir([entropy_dir '/*' movie_names{file_i} '*']);
   if(length(dir_struct))
        entropy_filename = dir_struct.name;
        fprintf('loading %s\n', mat2str(entropy_filename));
        load([entropy_dir '/' entropy_filename]);
        
        diff_hp_all = [diff_hp_all; diff_hp];
        diff_lp_all = [diff_lp_all; diff_lp];
        diff_sampled_all = [diff_sampled_all; diff_sampled];
   end
end

%%

formatFigure(1),
title('Histogram of KL-Divergences between Actual Eye-movements and a LP model of Flow')
hist(diff_lp_all( diff_lp_all>-5 & diff_lp_all < 0 & ~isnan(diff_lp_all) ), 50)
mean(diff_lp_all( diff_lp_all>-5 & diff_lp_all < 0 & ~isnan(diff_lp_all) ))


formatFigure(2),
title('Histogram of KL-Divergences between Actual Eye-movements and a HP model of Flow')
hist(diff_hp_all( diff_hp_all>-5 & diff_hp_all < 0 & ~isnan(diff_hp_all) ), 50)
mean(diff_hp_all( diff_hp_all>-5 & diff_hp_all < 0 & ~isnan(diff_hp_all) ))


formatFigure(3),
title('Histogram of KL-Divergences between Actual Eye-movements and a Baseline of sampled Eye-movements')
hist(diff_sampled_all( diff_sampled_all>-5 & diff_sampled_all < 0 & ~isnan(diff_sampled_all) ), 50)
mean(diff_sampled_all( diff_sampled_all>-5 & diff_sampled_all < 0 & ~isnan(diff_sampled_all) ))