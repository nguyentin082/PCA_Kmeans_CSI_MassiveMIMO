clc; clear;

% Parameters
nTest = 5000; % Number of test samples
na = 64; % Number of antennas
nc = 160; % Number of subcarriers
K = 8; % Number of users

% SNR values
snr_values = -30:5:10; % SNR values in dB

% Define B values
B_values = [512, 1024, 1536, 2048];

% Initialize cell array for reconstructed channel matrices
H_reconstructed = cell(1, length(B_values));

HUL_train_compl_tmp_mean = load('HUL_train_compl_tmp_mean.mat').HUL_train_compl_tmp_mean;

% Load the reconstructed channel matrices for each B value
file_names = {'H_test_real_predict2bit.mat', 'H_test_real_predict4bit.mat', ...
              'H_test_real_predict6bit.mat', 'H_test_real_predict8bit.mat'};
for i = 1:length(B_values)
    H_reconstructed{i} = load(file_names{i}).H_test_real_predict;
    fprintf('Size of H_reconstructed{%d} (B = %d): %s\n', i, B_values(i), mat2str(size(H_reconstructed{i})));
end

% Load data
HDL_test = load('HDL_test.mat').HDL_test;

% Initialize figure
figure;

% Initialize NMSE and RHO storage for all B values
all_nmse = cell(1, length(B_values));
all_rho = cell(1, length(B_values));

for b_idx = 1:length(B_values)
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

    % Initialize NMSE and correlation arrays
    nmse = zeros(nTest,1);
    rho = zeros(nTest,1);

    % Tính toán NMSE và hệ số tương quan cho mỗi mẫu kiểm tra
    for i = 1:nTest
        ch = HDL_test(:,:,i); % Ma trận kênh ban đầu
        ch_h = H_predict_complex(:,:,i); % Ma trận kênh tái cấu trúc
        nmse(i) = func_nmse(ch_h, ch);
        rho(i) = func_rho(ch_h, ch);
    end
    
    % Store NMSE and RHO for the current B value
    all_nmse{b_idx} = nmse;
    all_rho{b_idx} = rho;
end

% Plot NMSE CDF
subplot(1, 2, 1);
hold on;
for b_idx = 1:length(B_values)
    p1 = cdfplot(10*log10(all_nmse{b_idx}));
    set(p1, 'DisplayName', ['B = ', num2str(B_values(b_idx))], 'LineWidth', 1.5);
end
xlabel('10log(NMSE)');
ylabel('CDF');
legend('show', 'location', 'southeast');
title('CDF of 10log(NMSE)');

% Plot RHO CDF
subplot(1, 2, 2);
hold on;
for b_idx = 1:length(B_values)
    p2 = cdfplot(10*log10(1 - all_rho{b_idx}));
    set(p2, 'DisplayName', ['B = ', num2str(B_values(b_idx))], 'LineWidth', 1.5);
end
xlabel('10log(1-RHO)');
ylabel('CDF');
legend('show', 'location', 'southeast');
title('CDF of 10log(1-RHO)');

%% FUNCTION
function nmse_h = func_nmse(h_hat, h)
    nmse_h = (norm(h_hat-h, 'fro')/norm(h, 'fro'))^2;
end

function rho_h = func_rho(h_hat, h)
    rho_i = 0;
    for i = 1:size(h,2)
        rho_i = rho_i + abs(h_hat(:,i)'*h(:,i)) / (norm(h_hat(:,i)) * norm(h(:,i)));
    end
    rho_h = rho_i / size(h,2);
end
