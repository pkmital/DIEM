function entropy_value = calculate_entropy(matrix1, matrix2)
entropy_value=Inf;
matrix1 = matrix1(:);
matrix2 = matrix2(:);
size(matrix1), size(matrix2)
if(any(size(matrix1) ~= size(matrix2)))
    fprintf('Matrices must be the same size!\nMatrix 1: %d, %d\nMatrix 2: %d, %d', size(matrix1), size(matrix2));
    return;
end

indices = ~isinf(matrix1) & ~isnan(matrix1) & (matrix1 > 0) & ...
          ~isinf(matrix2) & ~isnan(matrix2) & (matrix2 > 0);
      
entropy_value = sum(matrix1 .* log(matrix2));