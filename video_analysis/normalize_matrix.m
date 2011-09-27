function normalized_matrix = normalize_matrix(in)

[r,c,d] = size(in);

in_clean = in(~isnan(in) & ~isinf(in));
min_in = min(in_clean(:));
max_in = max(in_clean(:));

normalized_matrix = (in - min_in) / (max_in-min_in);