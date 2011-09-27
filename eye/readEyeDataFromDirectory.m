function [xs x2s ys y2s xMs yMs numFrames] = readEyeDataFromDirectory(directory)
% Expects a string, directory, with the name of the directory containing
% only .txt files of eye data formatted as:
%
% [frame] [left-eye-x] [left-eye-y] [right-eye-x] [right-eye-y] [left-eye-dil] [right-eye-dil]
%
% a value of '_' in the x,y data corresponds to a blink or no-data and will
% be represented as a '-1' in the outdata
%
% Returns a number of eye-files by number of frames matrix in
% each of xs,ys, and x2s,y2s pairs of eye data

files = dir(directory);
numFiles = size(files,1) - 2;   % '.' and '..' are files too...
numFrames = 0;

xs = zeros(numFiles,1);
ys = zeros(numFiles,1);
x2s = zeros(numFiles,1);
y2s = zeros(numFiles,1);
xMs = zeros(numFiles,1);
yMs = zeros(numFiles,1);

for i =  1 : numFiles
    currentFile = strcat(directory, files(i+2).name);
    [frame, x, y, x2, y2, dil, dil2] = textread(currentFile, '%d %s %s %s %s %s %s');
    numFrames = frame(end);
    for j = 1 : numFrames
        % Left Eye
        if(isempty(str2num(cell2mat(x(j)))) || ... 
            isempty(str2num(cell2mat(y(j)))))
        	xs(i,j) = -1.;
            ys(i,j) = -1.;
        else
            xs(i,j) = str2num(cell2mat(x(j)));
            ys(i,j) = str2num(cell2mat(y(j)));
        end
        % Right Eye
        if(isempty(str2num(cell2mat(x2(j)))) || ...
            isempty(str2num(cell2mat(y2(j)))))
        	x2s(i,j) = -1.;
            y2s(i,j) = -1.;
        else
            x2s(i,j) = str2num(cell2mat(x2(j)));
            y2s(i,j) = str2num(cell2mat(y2(j)));
        end
        % Mean of both
        if(isempty(str2num(cell2mat(x(j)))) || ... 
            isempty(str2num(cell2mat(y(j)))) || ...
            isempty(str2num(cell2mat(x2(j)))) || ...
            isempty(str2num(cell2mat(y2(j)))))
            xMs(i,j) = -1.;
            yMs(i,j) = -1.;
        else
            xMs(i,j) = (str2num(cell2mat(x(j)))+str2num(cell2mat(x2(j))))/2.;
            yMs(i,j) = (str2num(cell2mat(y(j)))+str2num(cell2mat(y2(j))))/2.;
        end
    end
end