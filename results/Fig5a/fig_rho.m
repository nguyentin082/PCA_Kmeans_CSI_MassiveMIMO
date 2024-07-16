clear; clc;

% Load rho data
configs = {'BTot1024Na32Nc80', 'BTot1024Na32Nc160', 'BTot1024Na64Nc80', 'BTot1024Na64Nc160', ...
           'BTot512Na32Nc80', 'BTot512Na32Nc160', 'BTot512Na64Nc80', 'BTot512Na64Nc160'};
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

% Define custom colors for each line to match the provided image
customColors = [0, 0.4470, 0.7410; % Blue
                0.8500, 0.3250, 0.0980; % Orange
                0.9290, 0.6940, 0.1250; % Yellow
                0.4940, 0.1840, 0.5560; % Purple
                0, 0.4470, 0.7410; % Blue
                0.8500, 0.3250, 0.0980; % Orange
                0.9290, 0.6940, 0.1250; % Yellow
                0.4940, 0.1840, 0.5560; % Purple
               ];

% Plot CDFs with custom colors
p = gobjects(1, numel(configs));
for i = 1:numel(configs)
    if contains(configs{i}, '512')
        p(i) = cdfplot(10 * log10(1 - rho{i}));
        set(p(i), 'LineWidth', LineW, 'DisplayName', strrep(configs{i}, 'BTot', 'B = '), ...
                  'LineStyle', '--', 'Color', customColors(i, :));
    else
        p(i) = cdfplot(10 * log10(1 - rho{i}));
        set(p(i), 'LineWidth', LineW, 'DisplayName', strrep(configs{i}, 'BTot', 'B = '), ...
                  'Color', customColors(i, :));
    end
end

% Customize plot
set(gca, 'XLim', [-22, 0], 'XTick', -22:2:0);
xlabel('10log_{10}(1-\rho)');
ylabel('CDF');
legend(p, 'Location', 'southeast');
title('RHO CDFs for different CSI dimensions.', 'FontSize', 16, 'FontWeight', 'bold');
xtickangle(0);

% Get the legend handle
lgd = findobj(gcf, 'Type', 'Legend');

% Process legend text
for i = 1:numel(lgd.String)
    lgd.String{i} = regexprep(lgd.String{i}, 'B = (\d+)', 'B = $1,'); % Add comma after B =
    lgd.String{i} = strrep(lgd.String{i}, 'Na', ' Na = '); % Add Na =
    lgd.String{i} = strrep(lgd.String{i}, 'Nc', ', Nc = '); % Add Nc =
end

% Print average values of 10log10(1-rho)
for i = 1:numel(configs)
    fprintf('10log10(1-rho) for %s: %f \n', configs{i}, avg_10log10_1_minus_rho(i));
end

% Save plot
saveas(gcf, '(differentBtotNaNc)cdf-rho-CR16.png');
