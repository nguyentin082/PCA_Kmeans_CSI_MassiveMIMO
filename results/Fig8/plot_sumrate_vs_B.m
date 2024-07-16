clc; clear;

% Define B values
B_values = [512, 768, 1024, 1280, 1536, 1792, 2048];
B_values_for_AE512 = [512, 1024, 1536, 2048];

% Load avg_sum_rates.mat for PCA CR=16,32,64
load('PCA/avg_sum_rates_CR16.mat'); 
avg_sum_rates_PCA_CR16 = avg_sum_rates;
load('PCA/avg_sum_rates_CR32.mat'); 
avg_sum_rates_PCA_CR32 = avg_sum_rates; 
load('PCA/avg_sum_rates_CR64.mat'); 
avg_sum_rates_PCA_CR64 = avg_sum_rates; 

% Load avg_sum_rates.mat for AE128,256,512
load('AE/128/avg_sum_rates.mat'); 
avg_sum_rates_AE128 = avg_sum_rates(1:7, 2);
load('AE/256/avg_sum_rates.mat'); 
avg_sum_rates_AE256 = avg_sum_rates(1:7, 2);
load('AE/512/avg_sum_rates.mat'); 
avg_sum_rates_AE512 = avg_sum_rates(1:4, 2);

% Custom colors
customColors = [0, 0.4470, 0.7410; % Blue
                0.8500, 0.3250, 0.0980]; % Orange

% Plotting the data
figure;
hold on;

% AE plots with custom color
plot(B_values, avg_sum_rates_AE128, 'Color', customColors(2,:), 'LineWidth', 1.5, 'DisplayName', 'AE128');
plot(B_values, avg_sum_rates_AE256, 'Color', customColors(2,:), 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', 'AE256');
plot(B_values_for_AE512, avg_sum_rates_AE512, 'Color', customColors(2,:), 'LineStyle', ':', 'LineWidth', 1.5, 'DisplayName', 'AE512');

% PCA plots with custom color
plot(B_values, avg_sum_rates_PCA_CR16, 'Color', customColors(1,:), 'LineWidth', 1.5, 'DisplayName', 'PCA, \eta = 16');
plot(B_values, avg_sum_rates_PCA_CR32, 'Color', customColors(1,:), 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', 'PCA, \eta = 32');
plot(B_values, avg_sum_rates_PCA_CR64, 'Color', customColors(1,:), 'LineStyle', ':', 'LineWidth', 1.5, 'DisplayName', 'PCA, \eta = 64');

% Labels and title
xlabel('B');
ylabel('Average sum rate [bits/channel use]');
title('Average sum rate with zero-forcing beamforming vs feedback length B');

% Legend and grid
legend('show', 'Location', 'SouthEast');
grid on;
hold off;

% Set axis limits and x-ticks
xlim([512, 2048]);
ylim([25, 48]);
set(gca, 'XTick', [512, 768, 1024, 1280, 1536, 1792, 2048]);
