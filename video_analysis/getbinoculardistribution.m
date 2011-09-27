% Parag K. Mital
% DIEM 2009
function [mean_x_binocular mean_y_binocular] = getBinocularDistribution(movie_name, width, height, not_movie_name, age_group)
% Parses the event eye-data for only binocular fixation data. 
% Expects movie_name, width, height.

if(nargin < 4)
    not_movie_name = '';
end

if(nargin < 5)
    age_group = '';
end

    screen_width = 800;
    screen_height = 600;

    offset_x = (screen_width - width) / 2;
    offset_y = (screen_height - height) / 2;

if ~isempty(age_group)
    %   read data from eye files
    [left_x left_y left_dil left_flag right_x right_y right_dil right_flag] = ...
    readEventEyeDataFromDirectory(['event_data/' movie_name '/' age_group '/'], movie_name, not_movie_name);
else
    [left_x left_y left_dil left_flag right_x right_y right_dil right_flag] = ...
    readEventEyeDataFromDirectory(['event_data/scenes/dynamic/orig/' ], movie_name, not_movie_name);
end

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


% % plot the fixation distribution
% figure(1),
% plot(left_x_fixations,left_y_fixations,'b.')
% axis('image'),set(gca,'ydir','reverse'),hold on, title(['Fixation Distribution for ' strrep(movie_name,'_',' ')]),
% plot(right_x_fixations,right_y_fixations,'r.'),
% legend({'Left','Right'})
% hold off