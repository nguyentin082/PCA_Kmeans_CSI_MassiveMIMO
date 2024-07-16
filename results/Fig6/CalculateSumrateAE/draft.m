clc; clear;

% Define B values
B_values = [512, 1024, 1536, 2048];

% Initialize cell array for reconstructed channel matrices
H_reconstructed = cell(1, length(B_values));

% Load the reconstructed channel matrices for each B value
H_reconstructed{1} = load('H_predict_complex_all_B_values.mat').all_H_predict_complex{1};
H_reconstructed{2} = load('H_predict_complex_all_B_values.mat').all_H_predict_complex{2};
H_reconstructed{3} = load('H_predict_complex_all_B_values.mat').all_H_predict_complex{3};
H_reconstructed{4} = load('H_predict_complex_all_B_values.mat').all_H_predict_complex{4};

% Load data
HDL_test = load('HDL_test.mat').HDL_test;

% Define SNR values in dB
snr_values = -30:5:10; % SNR values in dB

% Initialize cell array to store average sum-rate for each B
average_sumrate = cell(1, length(B_values));

% Loop through each B value
for b_idx = 1:length(B_values)
    % Get reconstructed channel matrix for current B value
    H_reconst = H_reconstructed{b_idx};
    
    % Initialize array to store average sum-rate for each SNR
    avg_sumrate_snr = zeros(1, length(snr_values));
    
    % Loop through each SNR value
    for snr_idx = 1:length(snr_values)
        % Convert SNR from dB to linear scale
        SNR_dB = snr_values(snr_idx);
        SNR_linear = 10^(SNR_dB / 10);
        
        % Calculate sum-rate for each test sample
        sum_rate = zeros(1, size(HDL_test, 3));
        
        for t = 1:size(HDL_test, 3)
            % Get original and reconstructed channel matrices for current sample
            H_ori = HDL_test(:, :, t);
            H_recon = H_reconst(:, :, t);
            
            % Calculate SNR for each subcarrier
            SNR = SNR_linear * abs(H_recon).^2;
            
            % Calculate rate for each subcarrier
            R = log2(1 + SNR);
            
            % Sum-rate for current sample
            sum_rate(t) = sum(R(:));
        end
        
        % Average sum-rate for current SNR
        avg_sumrate_snr(snr_idx) = mean(sum_rate);
    end
    
    % Store average sum-rate for current B
    average_sumrate{b_idx} = avg_sumrate_snr;
end

% Plot average sum-rate vs SNR for each B value
figure;
hold on;
colors = ['r', 'g', 'b', 'k'];
for b_idx = 1:length(B_values)
    plot(snr_values, average_sumrate{b_idx}, 'Color', colors(b_idx), 'DisplayName', ['B = ', num2str(B_values(b_idx))]);
end
xlabel('SNR (dB)');
ylabel('Average Sum-rate (bps/Hz)');
title('Average Sum-rate vs. SNR for different B values');
legend show;
grid on;
hold off;
