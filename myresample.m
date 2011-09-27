function [out out_mean out_dev] = myresample(in, out_length, ratio, start_offset)

if(nargin < 4)
    start_offset = 0;
end

%fprintf('size of in: %d, resampling to %d\n', length(in), out_length) 
in(isnan(in)) = median(in(~isnan(in)));
out = zeros(out_length,1);
out_mean = zeros(out_length,1);
out_dev = zeros(out_length,1);

for i = 1 : out_length
    idx1 = max(1,round(i*ratio + start_offset*ratio));
    out_mean(i) = mean(in(max(floor(i*ratio + start_offset*ratio)-26, 1) : ...
                          min(ceil(i*ratio + start_offset*ratio), length(in)-1)));
    out_dev(i) = std(in(max(floor(i*ratio + start_offset*ratio)-26, 1) : ...
                        min(ceil(i*ratio + start_offset*ratio), length(in)-1)));
    out(i) = in(min(idx1,length(in)-1));
    if(isnan(out(i)))
        fprintf('Found NaN for idx: %d/%d\n', idx1, length(in)-1);
    end
end