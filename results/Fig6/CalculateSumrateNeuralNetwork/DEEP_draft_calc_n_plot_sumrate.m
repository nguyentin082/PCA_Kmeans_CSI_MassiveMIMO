clc; clear;

% Define B values
B_values = [512, 1024, 1536, 2048];
total_power = 1; % Total power constraint

% Load HUL_train_compl_tmp_mean
HUL_train_compl_tmp_mean = load('HUL_train_compl_tmp_mean.mat').HUL_train_compl_tmp_mean;

% Initialize cell array for reconstructed channel matrices
H_reconstructed = cell(1, length(B_values));

% Load the reconstructed channel matrices for each B value and process
for i = 1:length(B_values)
    % Create the filename based on the current B value
    filename = sprintf('HDL_test_reconst_single_complex-nSample10000-Btot%d-Dim64-Epochs1000.mat', B_values(i));
    
    % Load the file
    H_reconstructed{i} = load(filename).HDL_test_reconst_single_complex;
    
    % Reshape the reconstructed channel matrix from 64x160x2000 to 2000x10240
    H_reconstructed_reshaped = reshape(H_reconstructed{i}, 2000, []);
    
    % Add HUL_train_compl_tmp_mean to the reshaped reconstructed channel matrix
    H_reconstructed_with_mean = bsxfun(@plus, H_reconstructed_reshaped, HUL_train_compl_tmp_mean);
    
    % Reshape back to 64x160x2000
    H_reconstructed{i} = reshape(H_reconstructed_with_mean, 64, 160, 2000);
    
    % Convert back to complex single if needed
    H_reconstructed{i} = single(H_reconstructed{i});
end


% Load data
HDL_test = load('HDL_test.mat').HDL_test;
%%%%%% HDL_test and each H_reconstructed have the same size (64x160x2000 matrix)

% Parameters
nTest = 2000; % Number of test samples
na = 64; % Number of antennas
nc = 160; % Number of subcarriers
K = 8; % Number of users

% SNR values
snr_values = -30:5:10; % SNR values in dB

% Initialize array for storing average sum rates
avg_sum_rates = zeros(length(B_values) + 1, length(snr_values)); % Add one row for perfect channel

% Loop over each B value
for i = 1:length(B_values)
    % Loop over each SNR value
    for j = 1:length(snr_values)
        % Initialize array for storing sum rates for each simulation
        sum_rates = zeros(1, nTest);
        
        % Loop over each simulation
        for k = 1:nTest
            % Randomly select K downlink channels
            selected_channels = randperm(nTest, K);
            
            % Extract the selected downlink channels
            H_selected = H_reconstructed{i}(:, :, selected_channels);
            
            % Initialize the sum rate for this simulation
            sum_rate_temp = 0;
            
            % Loop over each subcarrier
            for subcarrier = 1:nc
                % Extract the channel for the current subcarrier
                H_subcarrier = H_selected(:, subcarrier, :);
                
                % Reshape H_subcarrier for computation
                H_subcarrier = reshape(H_subcarrier, [na, K]);
                
                % Apply zero-forcing beamforming
                W = pinv(H_subcarrier);
                
                % Calculate the noise power
                noise_power = sum(abs(W).^2, 2) / (10^(snr_values(j)/10));
                
                % Apply water-filling power allocation
                p_alloc = waterfilling(noise_power, total_power);
                
                % Calculate the signal power
                signal_power = abs(diag(W * H_subcarrier)).^2 .* p_alloc;
                
                % Calculate the sum rate for this subcarrier
                sum_rate_temp = sum_rate_temp + sum(log2(1 + signal_power ./ noise_power));
            end
            
            % Normalize by the number of subcarriers
            sum_rates(k) = sum_rate_temp / nc;
        end
        
        % Calculate the average sum rate over all simulations
        avg_sum_rates(i, j) = mean(sum_rates);
        % Hiển thị giá trị của `avg_sum_rates(i, j)`
        disp(['avg_sum_rates(', num2str(i), ', ', num2str(j), ') = ', num2str(avg_sum_rates(i, j))]);
    end
end



% Save avg_sum_rates to a .mat file
save('avg_sum_rates.mat', 'avg_sum_rates');

% Plot the average sum rates
figure;
hold on;
for i = 1:length(B_values)
    plot(snr_values, avg_sum_rates(i, :), 'DisplayName', ['B = ' num2str(B_values(i))]);
end
plot(snr_values, avg_sum_rates(end, :), '--k', 'DisplayName', 'Perfect Channel'); % Perfect channel
hold off;
xlabel('SNR (dB)');
ylabel('Average Sum Rate (bits/channel use)');
legend('show');
title('Average Sum Rate vs SNR for PCA');
grid on;



% Function for water-filling power allocation
function p_alloc = waterfilling(noise_power, total_power)
    % Sắp xếp noise power theo thứ tự tăng dần
    [sorted_noise, idx] = sort(noise_power);
    
    % Khởi tạo phân bổ công suất
    p_alloc = zeros(size(noise_power));
    
    % Khởi tạo remaining power
    remaining_power = total_power;
    
    % Số lượng người dùng
    K = length(noise_power);
    
    % Thực hiện water-filling
    water_level = 0;
    for i = 1:K
        water_level = (remaining_power + sum(sorted_noise(1:i))) / i;
        if i < K && water_level < sorted_noise(i+1)
            break;
        end
    end
    
    % Phân bổ công suất
    for j = 1:i
        p_alloc(idx(j)) = water_level - sorted_noise(j);
    end
end
