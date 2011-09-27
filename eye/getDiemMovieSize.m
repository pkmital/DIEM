function [width height] = getDiemMovieSize(movie_name)

width = 0;
height = 0;

for diem_number = 1 : 5

    path = ['/Users/pkmital/diem/data/DIEM/Experiments/deploy/diem' num2str(diem_number) '/library/audio/*.wav'];

    files = dir(path);

    for i = 1:length(files)
       this_movie_name = files(i).name(1:end-4);
       if(strcmp(movie_name, this_movie_name) == 1)
           movie_name_space = strrep(movie_name, '_', ' ');
           tokens = tokenize(movie_name_space);
           size = sscanf(tokens{end}, '%dx%d');
           width = size(1);
           height = size(2);
           return;
       end
    end


end