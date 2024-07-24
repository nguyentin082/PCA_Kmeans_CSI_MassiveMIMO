clc; clear;

% Parameters
nTest = 5000; % Number of test samples
na = 64; % Number of antennas
nc = 160; % Number of subcarriers
K = 8; % Number of users

% SNR values
snr_values = -30:5:10; % SNR values in dB

% Initialize cell array for reconstructed channel matrices
H_reconstructed = cell(1, 3);

HUL_train_compl_tmp_mean = load('HUL_train_compl_tmp_mean.mat').HUL_train_compl_tmp_mean;

% Load the reconstructed channel matrices for each B value
file_names = {'AE512trainwith40000samples(B=2048)/H_test_real_predict4bit.mat', 'AE256trainwith40000samples(B=2048)/H_test_real_predict8bit.mat', ...
              'AE128trainwith40000samples(B=2048)/H_test_real_predict16bit.mat'};
for i = 1:3
    H_reconstructed{i} = load(file_names{i}).H_test_real_predict;
    fprintf('Size of H_reconstructed{%d} (B = 2048): %s\n', i, mat2str(size(H_reconstructed{i})));
end

% Load data
HDL_test = load('HDL_test.mat').HDL_test;

% Initialize cell array to store processed H_predict_complex for all B values
all_H_predict_complex = cell(1, 3);

for b_idx = 1:3
    % Giả sử H_test_real_predict đã được dự đoán và có kích thước (nTest, na, nc, 2)
    H_real_predict = H_reconstructed{b_idx}(:,:,:,1); % Phần thực
    H_imag_predict = H_reconstructed{b_idx}(:,:,:,2); % Phần ảo

    % Tạo ma trận phức
    H_predict_complex = H_real_predict + 1i * H_imag_predict;

    % Chuyển vị ma trận để khớp với cấu trúc ban đầu
    H_predict_complex = permute(H_predict_complex, [2, 3, 1]); % Đổi vị trí các chiều từ (nTest, na, nc) thành (na, nc, nTest)

    % Cộng lại giá trị trung bình
    H_predict_complex = reshape(H_predict_complex, na * nc, nTest).'; % Chuyển về kích thước (nTest, na*nc)
    H_predict_complex = bsxfun(@plus, H_predict_complex, HUL_train_compl_tmp_mean); % Cộng lại giá trị trung bình
    H_predict_complex = reshape(H_predict_complex.', na, nc, nTest); % Chuyển về kích thước (na, nc, nTest)

    % Store processed H_predict_complex for the current B value
    all_H_predict_complex{b_idx} = H_predict_complex;
end

% Save all_H_predict_complex to a .mat file for later use
save('H_predict_complex_all_B_values_40000samples.mat', 'all_H_predict_complex', '-v7.3');
