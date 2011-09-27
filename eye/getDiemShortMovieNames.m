function movie_names = getDiemShortMovieNames(diem_number)

path = ['/Users/pkmital/diem/data/DIEM/Experiments/deploy/diem' num2str(diem_number) '/library/audio/*.wav'];

files = dir(path);

for i = 1:length(files)
   full_name = files(i).name(1:end-4); 
   short_name = sscanf(full_name(end:-1:1), '%*[^_] _ %s');
   movie_names{i} = short_name(end:-1:1);
end
