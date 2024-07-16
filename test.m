clc; clear;

matrix_10x8 = rand(10, 8);


disp(matrix_10x8);

% Tạo ma trận 3x2x6 bằng cách sử dụng reshape
matrix_4x2x5x2 = reshape(matrix_10x8, 4, 2, 5, 2);


matrix_10x8888888 = reshape(matrix_4x2x5x2, 10 ,8);

