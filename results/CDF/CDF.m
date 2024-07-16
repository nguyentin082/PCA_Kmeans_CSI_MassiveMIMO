clc; clear;

%% DEFINE PARAMETERS
nTest_AE = 5000;  % Number of test samples for AE
nTest_PCA = 2000; % Number of test samples for PCA
B_values = [512, 1024, 1536, 2048];  % Array of B values

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

%% Load NMSE and RHO calculated by PCA
nmse_PCA = cell(1, length(B_values));
rho_PCA = cell(1, length(B_values));
for i = 1:length(B_values)
    nmse_PCA{i} = load(['nmse-BTot', num2str(512 * i), '-CR16.mat']).nmse;
    rho_PCA{i} = load(['rho-BTot', num2str(512 * i), '-CR16.mat']).rho;
end

%% Assessing performance for AE and PCA
fprintf('Assessing performance...\n')

% NMSE figure
figure;
LineW = 1.5;
for b_index = 1:length(B_values)
    nmse_AE = zeros(nTest_AE,1);
    for i = 1:nTest_AE
        ch = HDL_test(:,:,i); 
        ch_h = H_reconstructed_AE{b_index}(:,:,i);
        nmse_AE(i) = func_nmse(ch_h, ch);
    end

    subplot(2, 2, b_index);
    hold on;
    p1 = cdfplot(10*log10(nmse_AE));
    p2 = cdfplot(10*log10(nmse_PCA{b_index}));
    set(p1, 'LineWidth', LineW);
    set(p2, 'LineWidth', LineW);
    set(gca, 'XLim', [-22, 0], 'XTick', -22:2:0);
    xlabel('10log_{10}(NMSE)');
    ylabel('CDF');
    legend('CDF NMSE AE', 'CDF NMSE PCA', 'Location', 'southeast');
    title(sprintf('NMSE for B=%d', B_values(b_index)));
    hold off;
end

% RHO figure
figure;
for b_index = 1:length(B_values)
    rho_AE = zeros(nTest_AE,1);
    for i = 1:nTest_AE
        ch = HDL_test(:,:,i); 
        ch_h = H_reconstructed_AE{b_index}(:,:,i);
        rho_AE(i) = func_rho(ch_h, ch);
    end

    subplot(2, 2, b_index);
    hold on;
    p1 = cdfplot(10*log10(1-rho_AE));
    p2 = cdfplot(10*log10(1-rho_PCA{b_index}));
    set(p1, 'LineWidth', LineW);
    set(p2, 'LineWidth', LineW);
    set(gca, 'XLim', [-22, 0], 'XTick', -22:2:0);
    xlabel('10log_{10}(1-\rho)');
    ylabel('CDF');
    legend('CDF 1-RHO AE', 'CDF 1-RHO PCA', 'Location', 'southeast');
    title(sprintf('RHO for B=%d', B_values(b_index)));
    hold off;
end

% Functions
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
