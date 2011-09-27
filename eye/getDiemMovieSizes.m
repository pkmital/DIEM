function movie_sizes = getDiemMovieSizes(diem_number)

path = ['/Users/pkmital/diem/data/DIEM/Experiments/deploy/diem' num2str(diem_number) '/library/audio/*.wav'];

files = dir(path);

for i = 1:length(files)
   movie_name = files(i).name(1:end-4);
   movie_name_space = strrep(movie_name, '_', ' ');
   tokens = tokenize(movie_name_space);
   size = sscanf(tokens{end}, '%dx%d');
   movie_sizes{i}.width = size(1);
   movie_sizes{i}.height = size(2);
end
