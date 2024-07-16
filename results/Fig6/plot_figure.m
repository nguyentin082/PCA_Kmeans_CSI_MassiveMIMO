clc; clear;

% Define B values
B_values = [512, 1024, 1536, 2048];

% Load avg_sum_rates.mat for PCA and Perfect
load('CalculateSumratePCAandPerfect/avg_sum_rates.mat'); % Đảm bảo rằng tệp avg_sum_rates.mat ở cùng thư mục với mã này
avg_sum_rates_PCA_and_Perfect = avg_sum_rates; % Lưu trữ kết quả vào một biến riêng biệt

% Load avg_sum_rates.mat for AE256
load('CalculateSumrateAE/avg_sum_rates.mat'); % Đảm bảo rằng tệp avg_sum_rates.mat ở cùng thư mục với mã này
avg_sum_rates_AE256 = avg_sum_rates; % Lưu trữ kết quả vào một biến riêng biệt

% Load avg_sum_rates.mat for AE512
load('CalculateSumrateAE/512_dim/avg_sum_rates.mat'); % Đảm bảo rằng tệp avg_sum_rates.mat ở cùng thư mục với mã này
avg_sum_rates_AE512 = avg_sum_rates; % Lưu trữ kết quả vào một biến riêng biệt

% Load avg_sum_rates.mat for AE128
load('CalculateSumrateAE/128_dim/avg_sum_rates.mat'); % Đảm bảo rằng tệp avg_sum_rates.mat ở cùng thư mục với mã này
avg_sum_rates_AE128 = avg_sum_rates; % Lưu trữ kết quả vào một biến riêng biệt

% Combine to 1 matrix
combined_avg_sum_rates = [avg_sum_rates_PCA_and_Perfect; avg_sum_rates_AE128; avg_sum_rates_AE256; avg_sum_rates_AE512];

% Tạo các giá trị SNR
SNR_values = -30:5:10; % Các giá trị SNR từ -30 đến 10 dB

% Define colors using RGB values
color_PCA = [0, 114, 188] / 255; % Màu xanh dương đậm
color_AE128 = [77, 175, 74] / 255; % Màu xanh lá cây
color_AE256 = [228, 26, 28] / 255; % Màu đỏ
color_AE512 = [255, 127, 0] / 255;
color_Perfect = [0, 0, 0]; % Màu đen

% Tạo hình vẽ 2x2 subplot
figure;
sgtitle('Average sum rate with zero-forcing beamforming for four different values of B.', 'FontSize', 16, 'FontWeight', 'bold');
for i = 1:4
    subplot(2, 2, i);
    hold on;
    plot(SNR_values, combined_avg_sum_rates(5, :), 'Color', color_Perfect, 'LineWidth', 2); % Perfect Channel
    plot(SNR_values, combined_avg_sum_rates(i, :), '-', 'Color', color_PCA, 'LineWidth', 2); % PCA
    plot(SNR_values, combined_avg_sum_rates(5+i, :), '-.', 'Color', color_AE128, 'LineWidth', 2); % AE128
    plot(SNR_values, combined_avg_sum_rates(10+i, :), '--', 'Color', color_AE256, 'LineWidth', 2); % AE256
    plot(SNR_values, combined_avg_sum_rates(15+i, :), ':', 'Color', color_AE512, 'LineWidth', 2); % AE512
    title(['B = ', num2str(B_values(i))]);
    xlabel('SNR (dB)');
    ylabel('Average Sum Rate (bits/channel use)');
    legend('Perfect Channel', 'PCA', 'AE128', 'AE256', 'AE512', 'Location', 'northwest');
    xlim([5 10]); % Set x-axis limits
    ylim([20 50]); % Set y-axis limits
    grid on;
    hold off;
end
