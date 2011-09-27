diem_number = 2;
stats_folder = '/Users/pkmital/diem/matlab/stats/';
    
movie_sizes = getDiemMovieSizes(diem_number);
num_movies = length(movie_sizes);

entropies{num_movies} = [];

for movie_i = 1:num_movies
    fprintf('processing movie %d for entropies\n', movie_i);
    
    % load([stats_folder 'diem' num2str(diem_number) '_' num2str(movie_i) '_gmmmodels'], 'gmmodels');
    
    num_frames = length(gmmodels{movie_i});
    entropy = zeros(num_frames,1);
    
    % get the data vector
    [i,j]=ind2sub([movie_sizes{movie_i}.height, ...
                   movie_sizes{movie_i}.width], ...
                  1:movie_sizes{movie_i}.width* ...
                  movie_sizes{movie_i}.height);
    x = cat(2,(i)',(j)');

    for frame_i = 1 : num_frames
        if(size(gmmodels{movie_i}{frame_i}.sigma,1) ~= 0)
        
            clusters = size(gmmodels{movie_i}{frame_i}.weight,2);
            mus = [];
            for c = 1 : clusters
                mus(c,:) = gmmodels{movie_i}{frame_i}.mu(:,c);
            end
            sigmas = [];
            if(size(gmmodels{movie_i}{frame_i}.sigma,3) > 0)
                sigmas = gmmodels{movie_i}{frame_i}.sigma(1,1,:);
                sigmas(2,2,:) = sigmas(1,1,:);
            end
            entropy(frame_i) = get_entropy(...
                           x, ...
                           mus, ...
                           sigmas, ...
                           gmmodels{movie_i}{frame_i}.weight');
        else
            entropy(frame_i) = 0;
        end
        
    end
    entropies{movie_i} = entropy;
    save(['entropies_diem' num2str(diem_number) '_movie' num2str(movie_i)], 'entropies');
end