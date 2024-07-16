clear; clc;

rho_values_db = zeros(1, 8);  % Tạo mảng để lưu các giá trị 10*log10(1-rho)

for i = 2:8
    data = load(['rho-BTot',num2str(256*i),'-CR16.mat']).rho;
    rho_values_db(i) = mean(10 * log10(1 - data));  % Tính giá trị trung bình 10*log10(1-rho)
end

% Hiển thị các giá trị 10*log10(1-rho) trung bình
for i = 2:8
    fprintf('10*log10(1-rho) for B = %d: %f \n', 256*i, rho_values_db(i));
end

% Vẽ biểu đồ CDF
figure('DefaultAxesFontSize',14);
LineW = 1.5;
hold on;

p2 = cdfplot(10*log10(1 - load(['rho-BTot512-CR16.mat']).rho));
p3 = cdfplot(10*log10(1 - load(['rho-BTot768-CR16.mat']).rho));
p4 = cdfplot(10*log10(1 - load(['rho-BTot1024-CR16.mat']).rho));
p5 = cdfplot(10*log10(1 - load(['rho-BTot1280-CR16.mat']).rho));
p6 = cdfplot(10*log10(1 - load(['rho-BTot1536-CR16.mat']).rho));
p7 = cdfplot(10*log10(1 - load(['rho-BTot1792-CR16.mat']).rho));
p8 = cdfplot(10*log10(1 - load(['rho-BTot2048-CR16.mat']).rho));

set(p2, 'linewidth', LineW, 'DisplayName','B = 512');
set(p3, 'linewidth', LineW, 'DisplayName','B = 768');
set(p4, 'linewidth', LineW, 'DisplayName','B = 1024');
set(p5, 'linewidth', LineW, 'DisplayName','B = 1280');
set(p6, 'linewidth', LineW, 'DisplayName','B = 1536');
set(p7, 'linewidth', LineW, 'DisplayName','B = 1792');
set(p8, 'linewidth', LineW, 'DisplayName','B = 2048');

title('RHO CDFs for different values of B.');
set(gca,'XLim',[-22,0],'XTick',-22:2:0);
xlabel('10log_{10}(1-\rho)');
ylabel('CDF');
legend('location','southeast');
xtickangle(0)
saveas(gcf,'cdf-rho-CR16.png')
