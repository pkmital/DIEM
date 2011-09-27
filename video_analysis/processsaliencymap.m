function processSaliencyMap(movie_name)

[video_object] = getMovieFrames(movie_name);
info = getinfo(video_object);

load xvid_max_bitrate_codecparameters;

vw1 = videoWriter([movie_name '_flow.avi'], ...
    'width', info.width, ...
    'height', info.height, ...
    'fps', info.fps, ...
    'codecParams', xvid_max_bitrate_codecparameters, ...
    'codec', 'xvid');

vw3 = videoWriter([movie_name '_lpflow.avi'], ...
    'width', info.width, ...
    'height', info.height, ...
    'fps', info.fps, ...
    'codecParams', xvid_max_bitrate_codecparameters, ...
    'codec', 'xvid');

flow_algorithm = 2;
alpha = 0.015;          
ratio = 0.75;
minWidth = 50;
nOuterFPIterations = 3;
nInnerFPIterations = 1;
nCGIterations = 10;
V = [];
V_lp = [];
V_prev = [];
V2 = [];
img_buf = [];
para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nCGIterations];
%%
i = 1;
start_frame = 5;
while(i < start_frame)
    next(video_object);
    img = im2double(getframe(video_object));
    img_buf(:,:,:,mod(i, start_frame) + 1) = img;
    i = i + 1; 
end
fprintf('processing %s\n', movie_name);
while(next(video_object))
    fprintf('%d, ', i);
    img2 = im2double(getframe(video_object));
    img_buf(:,:,:,1) = [];
    img_buf(:,:,:,5) = img2;
    
    im1 = imresize(img,0.5,'bicubic');
    im2 = imresize(img2,0.5,'bicubic');
    
    [vx,vy,warpI2] = Coarse2FineTwoFrames(im1,im2,para);
    V = sqrt(vx.^2 + vy.^2);
    
    im2 = imresize(img_buf(:,:,:,1),0.5,'bicubic');
    [vx,vy,warpI2] = Coarse2FineTwoFrames(im1,im2,para);
    V_lp = sqrt(vx.^2 + vy.^2);

    if(i ~= start_frame)
        V_lp = V_prev*0.5 + V_lp*0.5;
        V = V_prev*0.5 + V*0.5;
    end
    V_prev = V;
    V = imresize(V, 2.0, 'bicubic');
    % model the flow map 
    V_sc = imresize(V, 0.05, 'bicubic');
    [x,y] = meshgrid(1:size(V_sc,2), 1:size(V_sc,1));
    r=ksrmv([x(:) y(:)], V_sc(:), [202 202]);
    P = reshape(r.f, size(V_sc));
    P = imresize(P, 20, 'bicubic');
    
    V_lp = imresize(V_lp, 2.0, 'bicubic');
    V_sc = imresize(V_lp, 0.05, 'bicubic');
    r=ksrmv([x(:) y(:)], V_sc(:), [202 202]);
    P_lp = reshape(r.f, size(V_sc));
    P_lp = imresize(P_lp, 20, 'bicubic');
    
    %%
%     if ~(isa(V,'double') || isa(V,'single')); V = im2single(V); end
%     gh = imfilter(V,fspecial('sobel')  /8,'replicate'); 
%     gv = imfilter(V,fspecial('sobel')' /8,'replicate'); 
%     G = gh+gv;
%     G = G ./ max(G(:));
    %%
    
    V = V ./ max(V(:));
    V_lp = V_lp ./ max(V_lp(:));
    P = P ./ max(P(:));
    P_lp = P_lp ./ max(P_lp(:));
    
     figure(1)
 	  colormap('jet'),
     imagesc(P),
     axis('image');
%     A = getframe;
%     addframe(vw1, A.cdata);
    addframe(vw1, P);

    
     figure(3)
 	  colormap('jet'),
     imagesc(P_lp),
     axis('image');
%     A = getframe;
%     addframe(vw3, A.cdata);
    addframe(vw3, P_lp);

    
    
    
    img = img2;
    i = i + 1;
end

vw1 = close(vw1);
vw3 = close(vw3);
close(video_object);

end