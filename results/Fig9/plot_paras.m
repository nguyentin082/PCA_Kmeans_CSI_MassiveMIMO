clc; clear;

% Các giá trị giả định cho sum rate với các mô hình học máy khác nhau
B_values = [512, 768, 1024, 1280, 1536, 1792, 2048];

% Đường dẫn tới thư mục chứa các tệp tin
folder_path = ''; % Đảm bảo đường dẫn tới thư mục chứa các tệp tin

% LOAD PCA data
PCA_eta16 = zeros(1, length(B_values));
PCA_eta32 = zeros(1, length(B_values));
PCA_eta64 = zeros(1, length(B_values));

for index = 1:length(B_values)
    filename = sprintf('%s(PCAparas)CR16-BTot%d.mat', folder_path, B_values(index));
    PCA_eta16(index) = load(filename).N_O_pca;
end
for index = 1:length(B_values)
    filename = sprintf('%s(PCAparas)CR32-BTot%d.mat', folder_path, B_values(index));
    PCA_eta32(index) = load(filename).N_O_pca;
end
for index = 1:length(B_values)
    filename = sprintf('%s(PCAparas)CR64-BTot%d.mat', folder_path, B_values(index));
    PCA_eta64(index) = load(filename).N_O_pca;
end

% Load AE data
AE_128_encoder = double(load('encoder_params_dim128.mat').encoder_params);
AE_256_encoder = double(load('encoder_params_dim256.mat').encoder_params);
AE_512_encoder = double(load('encoder_params_dim512.mat').encoder_params);

AE_128_decoder = double(load('decoder_params_dim128.mat').decoder_params);
AE_256_decoder = double(load('decoder_params_dim256.mat').decoder_params);
AE_512_decoder = double(load('decoder_params_dim512.mat').decoder_params);

% AE upper bound and lower bound
AE_128_upper = AE_128_encoder;
AE_256_upper = AE_256_encoder + AE_128_encoder;
AE_512_upper = AE_512_encoder + AE_256_encoder+ AE_128_encoder;
AE_128_lower = AE_128_encoder;
AE_256_lower = AE_256_encoder;
AE_512_lower = AE_512_encoder;

% Màu sắc khác nhau cho PCA và AE
colors = [
    0 0.4470 0.7410;  % PCA màu xanh dương
    0.8500 0.3250 0.0980;  % AE128 màu cam
    0.9290 0.6940 0.1250;  % AE256 màu vàng
    0.4940 0.1840 0.5560;  % AE512 màu tím
];

% Vẽ biểu đồ
figure;
hold on;

% Vẽ PCA data
semilogy(B_values, PCA_eta16, '-^', 'LineWidth', 1.5, 'Color', colors(1,:), 'DisplayName', 'PCA, \eta=16');
semilogy(B_values, PCA_eta32, '--o', 'LineWidth', 1.5, 'Color', colors(1,:), 'DisplayName', 'PCA, \eta=32');
semilogy(B_values, PCA_eta64, '-.x', 'LineWidth', 1.5, 'Color', colors(1,:), 'DisplayName', 'PCA, \eta=64');

% Vẽ AE data
AE_upper = [AE_128_upper * ones(1, 1), AE_256_upper * ones(1, 3), AE_512_upper * ones(1, 3)];
AE_lower = [AE_128_lower * ones(1, 1), AE_256_lower * ones(1, 3), AE_512_lower * ones(1, 3)];

semilogy(B_values, AE_upper, '-o', 'LineWidth', 1.5, 'Color', colors(2,:), 'DisplayName', 'AE Upper bound');
semilogy(B_values, AE_lower, '--o', 'LineWidth', 1.5, 'Color', colors(2,:), 'DisplayName', 'AE Lower bound');

% Định dạng biểu đồ
xlabel('Feedback Length B');
ylabel('Number of offloaded model parameters');
title('Number of offloaded model parameters vs feedback length B');

% Chia legend thành 2 cột với cột đầu tiên chứa 3 phần tử của PCA và cột sau chứa các phần tử còn lại của AE
legend({'PCA, \eta=16', 'PCA, \eta=32', 'PCA, \eta=64', ...
    'AE, Upper bound', 'AE, Lower bound'}, ...
    'Location', 'southeast', 'NumColumns', 2);

grid on;

% Đặt các giá trị trên trục y và thiết lập thang đo logarithmic
set(gca, 'YScale', 'log');
ylim([4*10^4 2.5*10^6]);

% Chỉ hiển thị các giá trị B trên trục x
set(gca, 'XTick', B_values);

hold off;
