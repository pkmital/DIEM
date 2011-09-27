function gmmodels = getDiemGMMs(diem_number, mean_x, mean_y, movie_names, movie_sizes)

if(nargin < 5)
    movie_sizes = getDiemMovieSizes(diem_number);
end

if(nargin < 4)
    movie_names = getDiemMovieNames(diem_number);
end

if(nargin < 3)
    [mean_x mean_y] = readDiemEyeMovements(diem_number);
end

% load('diem_eye_data');

for i = 1 : length(mean_x)-1
    fprintf('Processing %s\n', movie_names{i});
    gmmodels{i} = getGMM(mean_x{i}, mean_y{i}, 1, 5, movie_sizes{i}.width, movie_sizes{i}.height);
    save(['diem' num2str(diem_number) '_' num2str(i), '_gmmmodels']);
end
