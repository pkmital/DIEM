function [gmmodel] = getGMM(xdata_allframes, ydata_allframes, min_clusters, max_clusters, width, height)
%getGMM return the GMM from data in xdata_allframes, and ydata_allframes,
% with the number of clusters defined in min_clusters, and max_clusters,
% and the possible values of x and y defined by width and height (e.g. the
% movie_width and movie_height).  
%
% Parag K Mital
% Copyright 2011, Parag K Mital

gmmodel = {};
dims = 2;
show_plot = 0;

numframes = size(xdata_allframes,1);
gmmodel{numframes} = struct('mu', [], 'sigma', [], 'weight', []);  
fprintf('Processing %d frames for GMM using model selection\n', numframes);

for frame = 1 : numframes
    
    gmmodel{frame} = struct('mu', [], 'sigma', [], 'weight', []);  
                    
    xdata = xdata_allframes(frame,:);
    ydata = ydata_allframes(frame,:);    
            
    if size(xdata,2) ~= 1
        xdata = reshape(xdata, [length(xdata),1]);
    end
    if size(ydata,2) ~= 1
        ydata = reshape(ydata, [length(ydata),1]);
    end
    
    %  0 data are interpreted as blinks (not modeled!) 
    idx = find(xdata > 0 .* ydata > 0);
    xdata = xdata(idx);
    ydata = ydata(idx);
    
    if( length(xdata) <= max_clusters )
        fprintf('Not enough data to perform model selection for %d data points and %d clusters.\n', ...
            length(xdata), max_clusters);
        continue;
    end
    
    % do the model selection via BIC by iterating over the number of clusters
    minBIC = Inf;
    bestModel = min_clusters;        
      
    for clusters = min_clusters : max_clusters

        [label, model, llh] = emgm([xdata, ydata]', clusters, 'spherical');

        N_p = clusters*(dims+1+1);   % + double(clusters)*(dims + dims*(dims+1.)/2.);
        BIC = -2 * llh(end) + 0.5*N_p*log(double(length(xdata)));
        
        if(BIC < minBIC && size(model.mu,2) == clusters)
           bestModel = clusters;
           minBIC = BIC;
           
           gmmodel{frame}.mu = model.mu;
           gmmodel{frame}.sigma = model.Sigma;
           gmmodel{frame}.weight = model.weight;
        end  % end bic        
    end % end clusters
    
    % gmmodel{frame}
    
    if show_plot
        formatFigure(1);
        xlim([0 width]);
        ylim([0 height]);
        axis('image');
        title(['Frame ', num2str(frame)]);
        hold on,
        plot(xdata(:, 1), ydata(:, 1), 'b.'); hold on;
        
        for c = 1 : bestModel
            mean_xy = [ gmmodel{frame}.mu(1,c); ...
                        gmmodel{frame}.mu(2,c)];
            [x, y] = errorellipse(mean_xy, gmmodel{frame}.sigma(:,:,c), 1, 100);
            patch('Faces', 1:length(x), 'Vertices', [x;y]', 'FaceColor', [repmat(1-gmmodel{frame}.weight(c),1,3)],...
                'EdgeColor','k',...
                'FaceAlpha', 0.8,...
                'AmbientStrength', 0.5,...
                'DiffuseStrength', 0.1,...
                'SpecularColorReflectance', 1,...
                'SpecularExponent', 0.5,...
                'SpecularStrength', 0.5);
            
        end
%         pause
    end
end

