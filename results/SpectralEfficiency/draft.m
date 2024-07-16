clc; clear;

% Define B values
B_values = [512, 1024, 1536, 2048];
SNR_dB = 0:5:30; % Define SNR range in dB
SNR = 10.^(SNR_dB/10); % Convert SNR from dB to linear scale

%% Load true channel data
HDL_test = load('HDL_test.mat').HDL_test;

%% Load and process data from AE
data = load('H_predict_complex_all_B_values.mat');
all_H_predict_complex = data.all_H_predict_complex;

% Initialize cell array for reconstructed channel matrices
H_reconstructed_AE = cell(1, length(B_values));
% Assign reconstructed channel matrices to H_reconstructed_AE
for i = 1:length(B_values)
    H_reconstructed_AE{i} = all_H_predict_complex{i};
end

%%
% Number of antennas and subcarriers
[~, ~, num_samples] = size(HDL_test);

% Initialize arrays to store spectral efficiency
SE_perfect = zeros(length(SNR), 1);
SE_reconstructed = zeros(length(SNR), length(B_values));

% Loop over each SNR value
for snr_idx = 1:length(SNR)
    % Compute spectral efficiency for perfect channel
    SE_perfect(snr_idx) = mean(log2(1 + SNR(snr_idx) * abs(HDL_test(:)).^2), 'all');
    
    % Compute spectral efficiency for reconstructed channels
    for b_idx = 1:length(B_values)
        SE_reconstructed(snr_idx, b_idx) = mean(log2(1 + SNR(snr_idx) * abs(H_reconstructed_AE{b_idx}(:)).^2), 'all');
    end
end

% Plot spectral efficiency
figure;
hold on;
plot(SNR_dB, SE_perfect, 'k-', 'LineWidth', 2, 'DisplayName', 'Perfect Channel');
for b_idx = 1:length(B_values)
    plot(SNR_dB, SE_reconstructed(:, b_idx), 'LineWidth', 2, 'DisplayName', ['B = ' num2str(B_values(b_idx))]);
end
hold off;
xlabel('SNR (dB)');
ylabel('Spectral Efficiency (bits/s/Hz)');
title('Spectral Efficiency vs. SNR for Different Feedback Bits');
legend('show');
grid on;
