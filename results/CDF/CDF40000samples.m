clc; clear;

%% DEFINE PARAMETERS
nTest_AE = 5000;  % Number of test samples for AE
nTest_PCA = 2000; % Number of test samples for PCA
B_value = 2048;   % Single B value

%% Load true channel data
HDL_test = load('HDL_test.mat').HDL_test;

%% Load and process data from AE
data = load('H_predict_complex_all_B_values_40000samples.mat');
all_H_predict_complex = data.all_H_predict_complex;

% Initialize cell array for reconstructed channel matrices
H_reconstructed_AE512 = all_H_predict_complex{1};  % AE512 with B=2048
H_reconstructed_AE256 = all_H_predict_complex{2};  % AE256 with B=2048
H_reconstructed_AE128 = all_H_predict_complex{3};  % AE128 with B=2048

%% Load NMSE and RHO calculated by PCA
nmse_PCA = load(['nmse-BTot', num2str(B_value), '-CR16.mat']).nmse;
rho_PCA = load(['rho-BTot', num2str(B_value), '-CR16.mat']).rho;

%% Assessing performance for AE and PCA
fprintf('Assessing performance...\n')

% NMSE figure
figure;
LineW = 1.5;

% NMSE for AE and PCA
nmse_AE128 = zeros(nTest_AE,1);
nmse_AE256 = zeros(nTest_AE,1);
nmse_AE512 = zeros(nTest_AE,1);
for i = 1:nTest_AE
    ch = HDL_test(:,:,i); 
    ch_h128 = H_reconstructed_AE128(:,:,i);
    ch_h256 = H_reconstructed_AE256(:,:,i);
    ch_h512 = H_reconstructed_AE512(:,:,i);
    nmse_AE128(i) = func_nmse(ch_h128, ch);
    nmse_AE256(i) = func_nmse(ch_h256, ch);
    nmse_AE512(i) = func_nmse(ch_h512, ch);
end

subplot(1, 2, 1);
hold on;
p1 = cdfplot(10*log10(nmse_PCA));
p2 = cdfplot(10*log10(nmse_AE128));
p3 = cdfplot(10*log10(nmse_AE256));
p4 = cdfplot(10*log10(nmse_AE512));
set([p1, p2, p3, p4], 'LineWidth', LineW);
set(gca, 'XLim', [-22, 0], 'XTick', -22:2:0);
xlabel('10log_{10}(NMSE)');
ylabel('CDF');
legend('PCA', 'AE128', 'AE256', 'AE512', 'Location', 'northwest');
title(sprintf('NMSE for B=%d', B_value));
hold off;

% RHO figure
rho_AE128 = zeros(nTest_AE,1);
rho_AE256 = zeros(nTest_AE,1);
rho_AE512 = zeros(nTest_AE,1);
for i = 1:nTest_AE
    ch = HDL_test(:,:,i); 
    ch_h128 = H_reconstructed_AE128(:,:,i);
    ch_h256 = H_reconstructed_AE256(:,:,i);
    ch_h512 = H_reconstructed_AE512(:,:,i);
    rho_AE128(i) = func_rho(ch_h128, ch);
    rho_AE256(i) = func_rho(ch_h256, ch);
    rho_AE512(i) = func_rho(ch_h512, ch);
end

subplot(1, 2, 2);
hold on;
p1 = cdfplot(10*log10(1-rho_PCA));
p2 = cdfplot(10*log10(1-rho_AE128));
p3 = cdfplot(10*log10(1-rho_AE256));
p4 = cdfplot(10*log10(1-rho_AE512));
set([p1, p2, p3, p4], 'LineWidth', LineW);
set(gca, 'XLim', [-22, 0], 'XTick', -22:2:0);
xlabel('10log_{10}(1-\rho)');
ylabel('CDF');
legend('PCA', 'AE128', 'AE256', 'AE512', 'Location', 'northwest');
title(sprintf('RHO for B=%d', B_value));
hold off;