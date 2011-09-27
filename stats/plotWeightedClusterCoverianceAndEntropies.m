% function plotWeightedClusterCoverianceAndEntropies

output_directory = ['output/entropy'];
mkdir(output_directory);
num_movies = 25;

for i = 1 : num_movies
   devs = wccs{i};
   infs = isinf(devs);
   devs_norm = devs ./ max(devs(~infs));
   h=formatFigure(1); plot(1 - devs_norm), hold on, plot(1 - entropies{i}./3,'r')
   file_name = strrep(movie_names{i}, '_', ' ');
   title(file_name, 'FontWeight', 'bold', 'FontSize', 14),
   legend({'Weighted Cluster Covariance', 'Entropy'}), 
   ylim([0.0 1.0]),
   xlabel('Time (frames)', 'FontWeight', 'bold', 'FontSize', 14);
   ylabel('Inverse Amplitude', 'FontWeight', 'bold', 'FontSize', 14);
   hold off
   
   print(h,'-dpdf',sprintf('-r%d',300),[output_directory '/' movie_names{i}, '_entropy_wccs.pdf']);
   
end

save([output_directory '/entropy_data']);