clear; clc;

nmse_values_db = zeros(1, 8);  % Tạo mảng để lưu các giá trị NMSE theo thang 10*log10(NMSE)

for i = 2:8
    data = load(['nmse-BTot',num2str(256*i),'-CR16.mat']).nmse;
    nmse_values_db(i) = mean(10 * log10(data));  % Tính giá trị trung bình NMSE theo thang 10*log10
end

% Hiển thị các giá trị NMSE trung bình theo thang 10*log10
for i = 2:8
    fprintf('10*log10(NMSE) for B = %d: %f \n', 256*i, nmse_values_db(i));
end

% Vẽ biểu đồ CDF
figure('DefaultAxesFontSize',14);
LineW = 1.5;
hold on;

p2 = cdfplot(10*log10(load(['nmse-BTot512-CR16.mat']).nmse));
p3 = cdfplot(10*log10(load(['nmse-BTot768-CR16.mat']).nmse));
p4 = cdfplot(10*log10(load(['nmse-BTot1024-CR16.mat']).nmse));
p5 = cdfplot(10*log10(load(['nmse-BTot1280-CR16.mat']).nmse));
p6 = cdfplot(10*log10(load(['nmse-BTot1536-CR16.mat']).nmse));
p7 = cdfplot(10*log10(load(['nmse-BTot1792-CR16.mat']).nmse));
p8 = cdfplot(10*log10(load(['nmse-BTot2048-CR16.mat']).nmse));

set(p2, 'linewidth', LineW, 'DisplayName','B = 512');
set(p3, 'linewidth', LineW, 'DisplayName','B = 768');
set(p4, 'linewidth', LineW, 'DisplayName','B = 1024');
set(p5, 'linewidth', LineW, 'DisplayName','B = 1280');
set(p6, 'linewidth', LineW, 'DisplayName','B = 1536');
set(p7, 'linewidth', LineW, 'DisplayName','B = 1792');
set(p8, 'linewidth', LineW, 'DisplayName','B = 2048');

title('NMSE CDFs for different values of B.');
set(gca,'XLim',[-22,0],'XTick',-22:2:0);
xlabel('10log_{10}(NMSE)');
ylabel('CDF');
legend('location','southeast');
xtickangle(0)
saveas(gcf,'cdf-nmse-CR16.png')
