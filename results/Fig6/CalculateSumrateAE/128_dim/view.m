clc; clear;

% Define B values
B_values = [512, 1024, 1536, 2048];

% Load data
HDL_test = load('HDL_test.mat').HDL_test;

% Load the reconstructed channel matrices for each B value
data = load('H_predict_complex_all_B_values.mat');
all_H_predict_complex = data.all_H_predict_complex;

% Initialize cell array for reconstructed channel matrices
H_reconstructed = cell(1, length(B_values));

% Assign reconstructed channel matrices to H_reconstructed
H_reconstructed{1} = all_H_predict_complex{1};
H_reconstructed{2} = all_H_predict_complex{2};
H_reconstructed{3} = all_H_predict_complex{3};
H_reconstructed{4} = all_H_predict_complex{4};

fprintf('Size of H_reconstructed{1}: %s\n', mat2str(size(H_reconstructed{1})));
ch = HDL_test(:, :, 1);
ch_h_1 = H_reconstructed{1}(:, :, 1);
ch_h_2 = H_reconstructed{2}(:, :, 1);
ch_h_3 = H_reconstructed{3}(:, :, 1);
ch_h_4 = H_reconstructed{4}(:, :, 1);