function processKLDivergence(movie_name)
show = 1;

% get attention map movie file names
directory = 'diem1_saliencymaps/';
hp_flow = ls([directory '*' movie_name '*' '_flow' '*' '.avi']);
lp_flow = ls([directory '*' movie_name '*' '_lpflow' '*' '.avi']);

% open them into a VideoReader
hp_flow_movie = VideoReader([directory hp_flow]);
lp_flow_movie = VideoReader([directory lp_flow]);

nMovieFrames = hp_flow_movie.NumberOfFrames;
movie_width = hp_flow_movie.Width;
movie_height = hp_flow_movie.Height;

% frames x subjects
[mean_x_binocular mean_y_binocular] = getBinocularDistributionOld(movie_name, movie_width, movie_height);
[nOrigMovieFrames nSubjects] = size(mean_x_binocular);

% vectorize the array to get the distribution of all fixations
x_distribution = mean_x_binocular(:);
y_distribution = mean_y_binocular(:);

% find non-zero data
good_data = find(x_distribution+y_distribution);

% set the distribution
x_distribution = x_distribution(good_data);
y_distribution = y_distribution(good_data);

% Store the size of the distribution for finding a random index
distribution_size = length(x_distribution);

% we start calculating the attention map 5 frames in, so we'd
% expect a 5 frames offset here:
origMovieOffset = nOrigMovieFrames - nMovieFrames;

% 1 degree in pixels for 1280 x 960 at 90 cm 
radius_size = 50.5;

% create a sigma matrix with a covariance of 2 degrees 
sigma = [radius_size * 2 / 3, 0; 0 radius_size * 2 / 3];
sigmas = repmat(sigma, [1,1,nSubjects]);

distribution_num_subjects = 500;
sigmas_predictive = repmat(sigma, [1,1,distribution_num_subjects]);
p_predictive = ones(1,distribution_num_subjects) / (distribution_num_subjects);

% we sample every 8th location of the pdf, so we scale everything down
% this is purely because of processing/memory constraints!
scalar = 8;
movie_height_small = round(movie_height / scalar);
movie_width_small = round(movie_width / scalar);
mean_x_binocular = mean_x_binocular / scalar;
mean_y_binocular = mean_y_binocular / scalar;
x_distribution = x_distribution / scalar;
y_distribution = y_distribution / scalar;
[i j] = ind2sub([movie_height_small, movie_width_small], 1:movie_height_small*movie_width_small);
grid = [i;j]';

% stats
entropy_lp = zeros(nMovieFrames,1);
entropy_hp = zeros(nMovieFrames,1);
entropy_actual = zeros(nMovieFrames,1);
entropy_sampled = zeros(nMovieFrames,1);
cross_entropy_actual_sampled = zeros(nMovieFrames,1);
cross_entropy_actual_lp = zeros(nMovieFrames,1);
cross_entropy_actual_hp = zeros(nMovieFrames,1);
diff_lp = zeros(nMovieFrames,1);
diff_hp = zeros(nMovieFrames,1);
diff_sampled = zeros(nMovieFrames,1);
interval = 5;
for frame = 1 : interval : nMovieFrames
    % get the attention maps
   hp_flow_img = read(hp_flow_movie, frame);
   lp_flow_img = read(lp_flow_movie, frame); 
   
   % index which subject's data are good for this frame
   x_f = mean_x_binocular(frame + origMovieOffset,:);
   y_f = mean_y_binocular(frame + origMovieOffset,:);
   good_data_for_this_frame = find(x_f + y_f);
   num_good_subjects = length(good_data_for_this_frame);
   
   % Get only the good fixations for this frame
   x_fixations_i = mean_x_binocular(frame + origMovieOffset,good_data_for_this_frame);
   y_fixations_i = mean_y_binocular(frame + origMovieOffset,good_data_for_this_frame);
   
   % compute the random sampled data using the distribution of good samples
   sampled_x_fixations = zeros(1,num_good_subjects);
   sampled_y_fixations = zeros(1,num_good_subjects);
   for i = 1:num_good_subjects
       idx = (round(rand() * (distribution_size-1) + 1));
       sampled_x_fixations(i) = x_distribution(idx);
       sampled_y_fixations(i) = y_distribution(idx);
   end
   
   % create a sigma and weight matrix for the number of good subjects
   this_sigma = sigmas(:,:,1:num_good_subjects);
   this_p = ones(1,num_good_subjects) / num_good_subjects;
   
   % create a mixture model of the eye-movements
   actual_mus = [y_fixations_i; x_fixations_i]';
   sampled_mus = [sampled_y_fixations; sampled_x_fixations]';
   actual_gmm = gmdistribution(actual_mus, this_sigma, this_p);
   sampled_gmm = gmdistribution(sampled_mus, this_sigma, this_p);
   
   % create the mixture model as a pdf
   actual_y = pdf(actual_gmm, grid);
   actual_y_small_img = reshape(actual_y,[movie_height_small movie_width_small]);
   actual_y_big_img = im2double(imresize(actual_y_small_img, [movie_height movie_width]));
   
   sampled_y = pdf(sampled_gmm, grid);
   sampled_y_small_img = reshape(sampled_y,[movie_height_small movie_width_small]);
   sampled_y_big_img = im2double(imresize(sampled_y_small_img, [movie_height movie_width]));
   
   lp_flow_y = im2double(lp_flow_img(:,:,2));
   hp_flow_y = im2double(hp_flow_img(:,:,2));
   
   % normalization
   actual_y_big_img = normalize_matrix(actual_y_big_img);
   sampled_y_big_img = normalize_matrix(sampled_y_big_img);
   lp_flow_y = normalize_matrix(lp_flow_y);
   hp_flow_y = normalize_matrix(hp_flow_y);
   
   % rejection sampling from the probabilistic map
   min_prob = 0.00;
   fixations_lp = zeros(distribution_num_subjects,2);
    for sub = 1 : distribution_num_subjects
        x = round(rand()*(size(lp_flow_y,2)-1)+1);
        y = round(rand()*(size(lp_flow_y,1)-1)+1);
        prob_xy = lp_flow_y(y,x);
        while(prob_xy < rand() + min_prob)
            x = round(rand()*(size(lp_flow_y,2)-1)+1);
            y = round(rand()*(size(lp_flow_y,1)-1)+1);
            prob_xy = lp_flow_y(y,x);
        end
        fixations_lp(sub,1) = y;
        fixations_lp(sub,2) = x;
    end

    fixations_hp = zeros(distribution_num_subjects,2);
    for sub = 1 : distribution_num_subjects
        x = round(rand()*(size(hp_flow_y,2)-1)+1);
        y = round(rand()*(size(hp_flow_y,1)-1)+1);
        prob_xy = hp_flow_y(y,x);
        while(prob_xy < rand() + min_prob)
            x = round(rand()*(size(hp_flow_y,2)-1)+1);
            y = round(rand()*(size(hp_flow_y,1)-1)+1);
            prob_xy = hp_flow_y(y,x);
        end
        fixations_hp(sub,1) = y;
        fixations_hp(sub,2) = x;
    end

    if show
    figure(2); clf;
    imagesc(lp_flow_y);
    hold on;
    plot(fixations_lp(:,2), fixations_lp(:,1), 'r+', 'MarkerSize', 14);
    hold off;
    end
    lp_predicted_gmm = gmdistribution(fixations_lp/scalar, sigmas_predictive, p_predictive);
   
   % create the mixture model as a pdf
   lp_predicted_y = pdf(lp_predicted_gmm, grid);
   lp_predicted_y_small_img = reshape(lp_predicted_y,[movie_height_small movie_width_small]);
   lp_predicted_y_big_img = im2double(imresize(lp_predicted_y_small_img, [movie_height movie_width]));
   lp_predicted_y_big_img = normalize_matrix(lp_predicted_y_big_img);
   
   hp_predicted_gmm = gmdistribution(fixations_hp/scalar, sigmas_predictive, p_predictive);
   
   % create the mixture model as a pdf
   hp_predicted_y = pdf(hp_predicted_gmm, grid);
   hp_predicted_y_small_img = reshape(hp_predicted_y,[movie_height_small movie_width_small]);
   hp_predicted_y_big_img = im2double(imresize(hp_predicted_y_small_img, [movie_height movie_width]));
   hp_predicted_y_big_img = normalize_matrix(hp_predicted_y_big_img);
   

   
   % calculate stats
   entropy_lp(frame) = calculate_entropy(lp_predicted_y,lp_predicted_y);
   entropy_hp(frame) = calculate_entropy(hp_predicted_y,hp_predicted_y);
   
   entropy_actual(frame) = calculate_entropy(actual_y,actual_y);
   entropy_sampled(frame) = calculate_entropy(sampled_y,sampled_y);
   
   cross_entropy_actual_sampled(frame) = calculate_entropy(actual_y,sampled_y);
   cross_entropy_actual_lp(frame) = calculate_entropy(actual_y,lp_predicted_y);
   cross_entropy_actual_hp(frame) = calculate_entropy(actual_y,hp_predicted_y);
   
   diff_sampled(frame) = cross_entropy_actual_sampled(frame) - entropy_actual(frame);
   diff_lp(frame) = cross_entropy_actual_lp(frame) - entropy_actual(frame);
   diff_hp(frame) = cross_entropy_actual_hp(frame) - entropy_actual(frame);
   
   % plot images
   if show
   figure(1),
   subplot 221
   colormap('jet'), imagesc(hp_predicted_y_big_img), title('high pass flow'), axis('image'), 
   subplot 222
   colormap('jet'), imagesc(lp_predicted_y_big_img), title('low pass flow'), axis('image'), 
   subplot 223
   imagesc(actual_y_big_img), title('actual eye-movements'), axis('image')
   subplot 224
   imagesc(sampled_y_big_img), title('sampled eye-movements'), axis('image')
   
   drawnow
   end
   
   figure(3)
    plot(abs(diff_sampled(1:interval:frame))), hold on, 
    plot(abs(diff_lp(1:interval:frame)), 'r'), 
    legend({'Baseline', 'Flow'})
end

save([movie_name '_workspace'], ...
    'entropy_lp', 'entropy_hp',...
    'entropy_actual', 'entropy_sampled', ...
    'cross_entropy_actual_sampled', ...
    'cross_entropy_actual_lp', ...
    'cross_entropy_actual_hp', ...
    'diff_sampled', ...
    'diff_lp', ...
    'diff_hp');
