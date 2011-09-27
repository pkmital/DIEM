function [entropy] = get_entropy(width, height, mu_x, mu_y, sig_x, sig_y, weight)

% 1xdxk for covariance
sigs = reshape(cat(3,[sig_x;sig_y]),[1,2,length(sig_x)]);
% construct the distribution
obj = gmdistribution([mu_x,mu_y], sigs, weight);

% get the data vector
% histogram based entropy calculation
[i,j]=ind2sub([height,width], 1:4:width*height);
x = cat(2,(i)',(j)');

% find the probability
p_x=pdf(obj,x);

% normalize 0-1
p_x = p_x ./ ( sum(p_x) );
p_x = p_x( ~isnan(p_x) & ~isinf(p_x) & (p_x >0) );

entropy = -sum(p_x(:).*log(p_x(:)));

% closed form solution of a single gaussian's differential entropy:
% http://mathworld.wolfram.com/DifferentialEntropy.html
% entropy = log(sqrt(2*pi*exp(1))^2*det([sig_x,0;0,sig_y])); %1/2*log(2*pi*exp(1)*sig_x*sig_y);