clc; clear;

% Define B values
B_values = [512, 768, 1024, 1280, 1536, 1792, 2048];

% Load the average sum rates
load('5000/avg_sum_rates.mat'); 
avg_sum_rates_AE256_5000 = avg_sum_rates(1:7, 2);
load('40000/avg_sum_rates.mat'); 
avg_sum_rates_AE256_40000 = avg_sum_rates(1:7, 2);

% Custom colors
customColors = [0.4940, 0.1840, 0.5560; % Purple
                0.8500, 0.3250, 0.0980]; % Red

% Plotting the data
figure;
hold on;

% AE plots with custom color
plot(B_values, avg_sum_rates_AE256_40000, 'Color', customColors(2,:), 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', 'AE256 (train with 40000 samples)');
plot(B_values, avg_sum_rates_AE256_5000, 'Color', customColors(1,:), 'LineWidth', 1.5, 'DisplayName', 'AE256 (train with 5000 samples)');

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
ylim([26, 46]);
set(gca, 'XTick', B_values);
