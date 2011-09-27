
movie_names = dir('avis/ed_scenes/*.avi');

for mv = 1 : length(movie_names)

    name = movie_names(mv).name(1:end-4);
    % this funky 'not_movie_name' is just because there is a edmmw, and a
    % edmmw2.  so if i put edmmw alone, i'll get fixations for edmmw2 as well....
    [video_object] = getMovieFrames(name, [name '2']);  
    
    info = getinfo(video_object);
    width = info.width;
    height = info.height;    
    
    seek(video_object, 2);
    img2=getframe(video_object);
    
    close(video_object);
    
    

    % Get the distribution of binocular eye-fixations
%     try
    % this funky 'not_movie_name' is just because there is a edmmw, and a
    % edmmw2.  so if i put edmmw alone, i'll get fixations for edmmw2 as well....
        [x_fixations y_fixations] = ...
        getBinocularDistribution(name, width, height, [name '2']);
    
        x_fx(mv,1:498,1:14) = x_fixations(1:498,1:14);
        y_fx(mv,1:498,1:14) = y_fixations(1:498,1:14);
    

        gmmmodel = getGMM(x_fixations(1:498,1:14), y_fixations(1:498,1:14), 1, 8, width, height);
        
        h=figure(1);
        clf
        hold on,
        histogram=hist3([x_fx(find(x_fx & y_fx)) y_fx(find(x_fx & y_fx))],[round(height/12),round(width/12)],'edgecolor','none');
        a=imagesc(imresize(imfilter(histogram',fspecial('gaussian',5, 5)), [height,width]));
        axis image
        maximize(h)
        
        heat_map = heat_map(:) ./ max(heat_map(:));
        a=cat(3,im2double(heat_map).*im2double(img(:,:,1)),im2double(heat_map).*im2double(img(:,:,2)),im2double(heat_map).*im2double(img(:,:,3)));
        heat_map = reshape(heat_map, size(img(:,:,1)));
        a=cat(3,im2double(heat_map).*im2double(img(:,:,1)),im2double(heat_map).*im2double(img(:,:,2)),im2double(heat_map).*im2double(img(:,:,3)));
        imshow(a)
        
        title(['Binocular fixations for ' movie_name ' (' num2str(length(x_fixations(1,:)) * length(x_fixations(:,1))) ' fixations)'])
        hold off
        
        pause;
%     catch e
%         disp(e)
%         disp(e.message)
%         return
%     end

    % close(video_object)
    
end