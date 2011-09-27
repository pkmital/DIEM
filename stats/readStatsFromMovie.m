function [Stats clusters covs] = readStatsFromMovie(directory)

if(nargin <1)
    directory = 'stats';
end
% load files in the directory
files = dir(directory);

clusters = [];
covs = zeros(26,500);
for i = 3 : size(files,1)
    disp(['Reading ' files(i).name]);
    [S cs] = readStats([directory '/' files(i).name]);
    Stats{i-2} = S;
    sub = length(cs);
    covs(i-2,1:sub) = cs(1:sub);
    clusters(i-2,1:length(Stats{i-2}.Centers(:))) = Stats{i-2}.Centers(:);
end

