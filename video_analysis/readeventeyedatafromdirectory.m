% Parag K. Mital
% DIEM 2009
function [left_x left_y left_dil left_flag right_x right_y right_dil right_flag] = readEventEyeDataFromDirectory(directory, movie_name, not_movie_name)
% Return the parsed eye-data in the given directory of a given movie 
% Expects a string with the name of the directory containing only .txt 
% files and the movie_name which is a token to match to the file name
%
% eye data is formatted as:
% [frame] [left-eye-x] [left-eye-y] [left-eye-flag] [left-eye-dil] [right-eye-x] [right-eye-y] [right-eye-flag] [right-eye-dil]
%
% a value of '0' in the x,y data corresponds to a blink or no-data and will
% be represented as a '0' in the outdata
%
% Returns a number of eye-files by number of frames matrix

% not movie name
if(nargin < 3)
    not_movie_name = '';
end

% append directory tag
if(directory(end) ~= '/' && directory(end) ~= '\')
    directory(end+1) = '/';
end

% load files in the directory
files = dir(directory);
num_files = size(files,1) - 2;   % '.' and '..' are files too...

% setup storage
left_x = [];
left_y = [];
left_dil = [];
left_flag = [];
right_x = [];
right_y = [];
right_dil = [];
right_flag = [];

% number of files read matching 'movie_name'
count = 0;
min_eyefiles = Inf;
for i =  1 : num_files
    current_file = strcat(directory, files(i+2).name);
    if(~isempty(strfind(current_file,movie_name)) && isempty(strfind(current_file, not_movie_name)))
        count = count + 1;
%         [arg1, left_x(:,count), left_y(:,count), left_dil(:,count), left_flag(:,count), ...
%             right_x(:,count), right_y(:,count), right_dil(:,count), right_flag(:,count)] = ...
%             textread(current_file, '%d %f %f %f %d %f %f %f %d');
        fprintf('Reading %s...', current_file);
        [arg1, left_x_i, left_y_i, left_dil_i, left_flag_i, ...
            right_x_i, right_y_i, right_dil_i, right_flag_i] = ...
            textread(current_file, '%d %f %f %f %d %f %f %f %d');
        fprintf('found %d frames.\n', arg1(end));
%        disp(['Reading ',current_file, '...found ', num2str(arg1(end)), ' frames']);
        min_eyefiles = min(min_eyefiles, arg1(end));
        
        left_x(1:arg1(end),count) = left_x_i; left_y(1:arg1(end),count) = left_y_i;
        left_dil(1:arg1(end),count) = left_dil_i; left_flag(1:arg1(end),count) = left_flag_i;
        right_x(1:arg1(end),count) = right_x_i; right_y(1:arg1(end),count) = right_y_i;
        right_dil(1:arg1(end),count) = right_dil_i; right_flag(1:arg1(end),count) = right_flag_i;
    end
end

% remove extra frames
left_x = left_x(1:min_eyefiles,:);
left_y = left_y(1:min_eyefiles,:);
left_dil = left_dil(1:min_eyefiles,:);
left_flag = left_flag(1:min_eyefiles,:);
right_x = right_x(1:min_eyefiles,:);
right_y = right_y(1:min_eyefiles,:);
right_dil = right_dil(1:min_eyefiles,:);
right_flag = right_flag(1:min_eyefiles,:);

disp(['Read ', num2str(count), ' files for the movie, ', movie_name, '.']);