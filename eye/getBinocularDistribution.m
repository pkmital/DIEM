% Parag K. Mital
% DIEM 2009
function [mean_x_binocular mean_y_binocular] = getBinocularDistribution(path, movie_name, width, height, show_plot)
% Parses the event eye-data for only binocular fixation data. 
% Expects movie_name, width, height.
if(nargin < 5)
    show_plot = 0;
end
screen_width = 1280;
screen_height = 960;

offset_x = (screen_width - width) / 2;
offset_y = (screen_height - height) / 2;

[left_x left_y left_dil left_flag right_x right_y right_dil right_flag] = ...
    readEventEyeDataFromDirectory(path, movie_name);

% correct for monitor resolution and video placement (centered)
left_x = left_x - offset_x;
left_y = left_y - offset_y;
right_x = right_x - offset_x;
right_y = right_y - offset_y;

disp('Parsing input data for fixations...');
% flag == 1 means a fixation
left_fixations = left_flag == 1;
right_fixations = right_flag == 1;

% both left and right eyes fixation = binocular fixation data
binocular_fixations = left_fixations & right_fixations;

% find only data in the range of the movie
left_x_inrange = left_x < width & left_x > 0;
left_y_inrange = left_y < height & left_y > 0;
right_x_inrange = right_x < width & right_x > 0;
right_y_inrange = right_y < height & right_y > 0;

% set non-fixated data to 0. 
% accept only data that is within the image coornidates
left_x_binocular = left_x .* (binocular_fixations & left_x_inrange & left_y_inrange);
left_y_binocular = left_y .* (binocular_fixations & left_x_inrange & left_y_inrange);
right_x_binocular = right_x .* (binocular_fixations & right_x_inrange & right_y_inrange);
right_y_binocular = right_y .* (binocular_fixations & right_x_inrange & right_y_inrange);

% calculate mean of left/right
mean_x_binocular = (left_x_binocular + right_x_binocular) / 2;
mean_y_binocular = (left_y_binocular + right_y_binocular) / 2;

if(show_plot)
    % plot the fixation distribution
    formatFigure(1),
    plot(mean_x_binocular,mean_y_binocular,'b+')
    axis('image'),set(gca,'ydir','reverse'), title(['Fixation Distribution for ' strrep(movie_name,'_',' ')]),
    hold off
end