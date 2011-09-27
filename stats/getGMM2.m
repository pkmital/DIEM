% function [gmmodel] = getGMM(xdata_allframes, ydata_allframes, min_clusters, max_clusters, width, height)
% Performs gmm w/ model selection on the 2dimensional data, x,ydata

% getGMM(x_fixations(1:498,1:14), y_fixations(1:498,1:14), 1, 8, width, height);

xdata_allframes = x_fixations(1:498,1:14);
ydata_allframes = y_fixations(1:498,1:14);
min_clusters = 1;
max_clusters = 8;
width = 720;
height = 576;
dims = 2;

show_plot = 0;
show_plot2 = 1;
numframes = size(xdata_allframes,1);
gmmodel = {};
for frame = 1 : numframes
    
    xdata = xdata_allframes(frame,:);
    ydata = ydata_allframes(frame,:);    
            
    if size(xdata,2) ~= 1
        xdata = reshape(xdata, [length(xdata),1]);
    end
    if size(ydata,2) ~= 1
        ydata = reshape(ydata, [length(ydata),1]);
    end
    
    %  0 data are interpreted as blinks (not modeled!) 
    idx = find(xdata & ydata);
    xdata = xdata(idx);
    ydata = ydata(idx);
    
    if( length(xdata) >= max_clusters )
        fprintf('Not enough data to perform model selection on %d clusters.  Resizing max to half data vector: %d\n', ...
            max_clusters, floor(length(xdata) / 2));
        max_clusters = floor(length(xdata) / 2);
    end
    
    % do the model selection via BIC by iterating over the number of clusters
    minBIC = Inf;
    bestModel = min_clusters;
    gmmodel{frame} = struct( 'Cluster', ...
                struct( 'Mean', ...
                        struct('X', 0, 'Y', 0), ...
                        'Covariance', 0, ...
                        'Weight', 0));    
        
    if show_plot            
        figure(1), clf
        xlim([0 width]);
        ylim([0 height]);
        axis('image');
        plot(xdata(:, 1), ydata(:, 1), 'b.'); hold on;
    end
    
    for clusters = min_clusters : max_clusters
        
        options=zeros(1,18);
        options(1)=0;                % Don't display the error while running
        options(14)=50;             % Maximum number of training iterations

        newmix = gmm(2, clusters, 'spherical');
        newmix = gmminit(newmix, [xdata, ydata], options);
        [newmix, options, errlog] = gmmem(newmix, [xdata, ydata], options);
                
        %llikes = sum(log(gmmprob(newmix, [xdata, ydata])));
        llikes = -sum(dempot([xdata, ydata], newmix));

        N_p = (double(clusters)-1.) + double(clusters)*(dims + dims*(dims+1.)/2.);
        BIC = -2. * llikes + N_p*log(double(length(xdata)));
        
        if(BIC < minBIC)
           bestModel = clusters;
           minBIC = BIC;
           
           gmmmodel{frame}.model = newmix;
           for c = 1 : clusters
               gmmodel{frame}.Cluster(c).Mean.X = newmix.centres(c,1);
               gmmodel{frame}.Cluster(c).Mean.Y = newmix.centres(c,2);
               gmmodel{frame}.Cluster(c).Covariance = newmix.covars(c);
               gmmodel{frame}.Cluster(c).Weight = newmix.priors(c);
           end
           for c = clusters+1 : max_clusters
               gmmodel{frame}.Cluster(c).Mean.X = [];
               gmmodel{frame}.Cluster(c).Mean.Y = [];
               gmmodel{frame}.Cluster(c).Covariance = [];
               gmmodel{frame}.Cluster(c).Weight = [];
               gmmodel{frame}.Cluster(c) = [];
           end
        end  % end bic        
    end % end clusters
    
            
    if show_plot2
        figure(2), clf, 
        xlim([0 width]);
        ylim([0 height]);
        axis('image');
        title(['Frame ', num2str(frame)]);
        hold on,
        plot(xdata(:, 1), ydata(:, 1), 'b.'); hold on;
        
        for c = 1 : bestModel
            [x, y] = errorellipse([gmmodel{frame}.Cluster(c).Mean.X; gmmodel{frame}.Cluster(c).Mean.Y], ...
                [gmmodel{frame}.Cluster(c).Covariance 0; 0 gmmodel{frame}.Cluster(c).Covariance], 1, 100);
            plot(x, y, 'r'); hold on;
        end
%         pause
    end
end

