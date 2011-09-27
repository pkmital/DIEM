function features = getDiemEdits(diem_number)

if(nargin == 0)
    diem_number = 1;
end

feature_dir = ['/Users/pkmital/diem/data/DIEM/cinematic_features/diem' num2str(diem_number)];
files = dir([feature_dir '/*.txt']);
features{length(files)} = {};

for file_i = 1 : length(files);
    fid = fopen([feature_dir '/' files(file_i).name]);
    features{file_i} = textscan(fid, '%d %d %d %d %d %d %d %d %d %d %d');
    fclose(fid);
end
