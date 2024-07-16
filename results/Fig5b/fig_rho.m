clear; clc;

% Load rho data
configs = {'BTot1536Ntrain5000', 'BTot1536Ntrain3000', 'BTot1536Ntrain2000', 'BTot1536Ntrain1500', ...
           'BTot512Ntrain5000', 'BTot512Ntrain3000', 'BTot512Ntrain2000', 'BTot512Ntrain1500'};
rho = cell(1, numel(configs));
avg_10log10_1_minus_rho = zeros(1, numel(configs));

for i = 1:numel(configs)
    data = load(['rho-' configs{i} '-CR16.mat']).rho;
    rho{i} = data;
    avg_10log10_1_minus_rho(i) = mean(10 * log10(1 - data));  % Tính giá trị trung bình 10*log10(1-rho)
end

% Plot settings
LineW = 1.5;
figure('DefaultAxesFontSize', 14);
hold on;

% Define custom colors for each line
customColors = [0, 0.4470, 0.7410; % Blue
                0.8500, 0.3250, 0.0980; % Orange
                0.9290, 0.6940, 0.1250; % Yellow
                0.4940, 0.1840, 0.5560; % Purple
                0, 0.4470, 0.7410; % Blue
                0.8500, 0.3250, 0.0980; % Orange
                0.9290, 0.6940, 0.1250; % Yellow
                0.4940, 0.1840, 0.5560; % Purple
               ];

p = zeros(1, numel(configs)); % Preallocate legend handles
legendEntries = cell(1, numel(configs));
for i = 1:numel(configs)
    [f, x] = ecdf(10*log10(1 - rho{i}));
    
    % Extract B and Ntrain values
    [tokens, ~] = regexp(configs{i}, 'BTot(\d+)Ntrain(\d+)', 'tokens', 'match');
    B_value = str2double(tokens{1}{1});  % Extracting B value
    Ntrain_value = str2double(tokens{1}{2});  % Extracting Ntrain value
    
    % Determine line style
    if B_value == 1536
        lineStyle = '-.'; % Dotted line for B = 1536
    else
        lineStyle = '-';  % Solid line for other values
    end
    
    % Plot the data
    p(i) = plot(x, f, 'Color', customColors(mod(i-1, size(customColors, 1)) + 1, :), 'LineStyle', lineStyle, 'LineWidth', LineW);
    
    % Create legend entry
    legendEntries{i} = sprintf('B = %d, Ntrain = %d', B_value, Ntrain_value);
end

% Customize plot
set(gca, 'XLim', [-23, 0], 'XTick', -22:2:0);
xlabel('10log_{10}(1-\rho)');
ylabel('CDF');
legend(p, legendEntries, 'Location', 'southeast');
title('RHO CDFs for different number of training samples.', 'FontSize', 16, 'FontWeight', 'bold');
xtickangle(0);

% Add grid
grid on;

% Print average values of 10log10(1-rho)
for i = 1:numel(configs)
    fprintf('10log10(1-rho) for %s: %f \n', configs{i}, avg_10log10_1_minus_rho(i));
end

% Save plot
saveas(gcf, '(differentBtotNtrain)cdf-rho-CR16.png');
