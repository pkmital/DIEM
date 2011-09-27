function [E] = get_entropy(x, mus, sigmas, weight)
%GET_ENTROPY return the entropy of a gaussian mixture model
% e = get_entropy(x, mus, sigmas, weight) requires the sampling locations 
% in x, the matrix of mus 2 x C, where C is the number of clusters, the
% matrix of covariances in sigmas as 2 x 2 x C, and the mixing proportions
% in weight as a 1 x C vector
%
% Parag K Mital
% Copyright 2011, Parag K Mital


% construct the distribution
obj = gmdistribution(mus, sigmas, weight);

% find the probability
p = pdf(obj,x);

% remove zero entries in p 
p(p==0 | isinf(p) | isnan(p)) = [];

% normalize p so that sum(p) is one.
p = p ./ sum(p(:));

E = -sum(p.*log2(p));

% closed form solution of a single gaussian's differential entropy:
% http://mathworld.wolfram.com/DifferentialEntropy.html
% entropy = log(sqrt(2*pi*exp(1))^2*det([sig_x,0;0,sig_y])); %1/2*log(2*pi*exp(1)*sig_x*sig_y);