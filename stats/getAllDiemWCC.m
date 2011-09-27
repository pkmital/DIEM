% function getAllDIEMWCC

wccs = {};
num_movies = 25;
for i = 1 : num_movies
    fprintf('processing movie %d/%d: %s\n', i, num_movies, movie_names{i});
    num_frames = length(gmmodels{i});
    wccs{i} = zeros(num_frames,1);
    for f = 1 : num_frames
        if(isempty(gmmodels{i}{f}.sigma))
            wccs{i}(f) = Inf;
        else
            sigmas = squeeze(gmmodels{i}{f}.sigma(1,1,:));
            weights = gmmodels{i}{f}.weight';
            wccs{i}(f) = sum(sigmas .* weights);
        end
    end
end