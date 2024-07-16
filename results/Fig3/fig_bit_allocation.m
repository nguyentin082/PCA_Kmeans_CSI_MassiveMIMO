clear; clc;

% Load data
Bs{1} = load('bitAllocation-BTot512-CR16.mat').Bs;
Bs{2} = load('bitAllocation-BTot1024-CR16.mat').Bs;
Bs{3} = load('bitAllocation-BTot1536-CR16.mat').Bs;
Bs{4} = load('bitAllocation-BTot2048-CR16.mat').Bs;

% Create subplots with larger figure window
figure('DefaultAxesFontSize',14);
set(gcf, 'Position', get(0, 'Screensize')); % Maximize figure window

% Set overall title for the figure
sgtitle('Bit allocation to the principal components for four different values of B.', 'FontSize', 16, 'FontWeight', 'bold');


for i = 1:numel(Bs)
    subplot(2, 2, i);
    bar(Bs{i}, 'FaceColor', [0 0.4470 0.7410], 'EdgeColor', 'none'); % Change to bar style plot
    title(['B = ' num2str(512*i)]);
    xlabel('Principal components');
    ylabel('Bits');
    xlim([1 numel(Bs{i})]); % Set x-axis limits to fit the data
    ylim([0 max(Bs{i})+2]); % Set y-axis limits to fit the data
    grid on; % Turn on grid
end


