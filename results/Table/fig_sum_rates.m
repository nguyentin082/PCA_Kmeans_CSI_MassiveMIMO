clc; clear;

% Define B values
B_values = [512, 1024, 1536, 2048];

% Load avg_sum_rates.mat (5x9) (row 5 is perfect channel)
load('avg_sum_rates.mat'); % Đảm bảo rằng tệp avg_sum_rates.mat ở cùng thư mục với mã này

% Tạo các giá trị SNR
SNR_values = -30:5:10; % Các giá trị SNR từ -10 đến 30 dB

% Tạo hình vẽ 2x2 subplot
figure;
for i = 1:4
    subplot(2, 2, i);
    hold on;
    plot(SNR_values, avg_sum_rates(5, :), 'k-', 'LineWidth', 2); % Perfect Channel
    plot(SNR_values, avg_sum_rates(i, :), 'r', 'LineWidth', 2); % B value
    title(['B = ', num2str(B_values(i))]);
    xlabel('SNR (dB)');
    ylabel('Average Sum Rate (bits/channel use)');
    legend('Perfect Channel', ['PCA'], 'Location', 'Best');
    grid on;
    hold off;
end
