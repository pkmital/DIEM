% Parag K. Mital
% University of Edinburgh
% John M. Henderson's Visual Cognition Lab
% DIEM 2008-2010
%
% Read the stats file output for a single movie from CARPE into a stucture
% fileIn should be a path to the file (.txt)
% Stats is a stucture with fields as indicated in source file
function [Stats covs] = readStats(fileIn)

Stats = struct(...
    'Centers', 0, ...
    'Likelihood', 0, ...
    'BIC', 0, ...
    'Frame', []);

fid = fopen(fileIn, 'r');
if fid < 0
    fprintf('error reading %s. returned %d\n', fileIn, fid);
end
frame = fscanf(fid, '%ld\n');
while(size(frame) == 1)
    Stats.Centers(frame) = fscanf(fid, 'clusters: %ld\n');
    Stats.Likelihood(frame) = fscanf(fid, 'likelihood: %lg\n');
    Stats.BIC(frame) = fscanf(fid, 'BIC: %lg\n');
    Stats.Frame{frame} = ...
        struct( 'Cluster', ...
                struct( 'Mean', ...
                        struct('X', 0, 'Y', 0), ...
                        'Covariance', 0, ...
                        'Weight', 0));
    for c = 1 : Stats.Centers(frame)
        means = fscanf(fid, 'mean: %lg %lg\n');
        if(size(means,1) < 1)
            disp(num2str(frame));
            pause;
        end
        Stats.Frame{frame}.Cluster(c).Mean.X = means(1);
        Stats.Frame{frame}.Cluster(c).Mean.Y = means(2);
        Stats.Frame{frame}.Cluster(c).Covariance = fscanf(fid, 'covar: %lg\n');
        covs(frame) = Stats.Frame{frame}.Cluster(c).Covariance;
        Stats.Frame{frame}.Cluster(c).Weight = fscanf(fid, 'weight: %lg\n');
    end
    
    frame = fscanf(fid, '%ld\n');
end

fclose(fid);