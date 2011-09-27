function movie_names = getDiemMovieNames(diem_number)

path = ['/Users/pkmital/diem/data/DIEM/Experiments/deploy/diem' num2str(diem_number) '/library/audio/*.wav'];

files = dir(path);

for i = 1:length(files)
   movie_names{i} = files(i).name(1:end-4); 
end
