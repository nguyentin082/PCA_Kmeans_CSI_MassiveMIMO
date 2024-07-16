% Input:
% H_train [64 x 160 x 5,000]
% H_test [64 x 160 x 2,000]

clear; clc;
rng(47);

% Parameters
na = 64;                % # of BS antennas
nc = 160;               % # of OFDM subcarriers
nTrain = 5000;          % # of training samples
nTest = 2000;           % # of test samples
CR = 16;                % Compression ratio
BTot = 2048;           % Total feedback bits 
snrTrain = 10;          % Noise level in training samples. Value in linear units: -1=infdB or 1=0dB, 10=10dB, 1000=30dB
snrTest = 10;           % Noise level in test samples. Value in linear units: -1=infdB or 1=0dB, 10=10dB, 1000=30dB
quantization = true;    % Quantize or not the compressed CSI
reduce_overhead = true; % Reduce or not the offloading overhead

%% Import and preprocess data
fprintf('Importing and preprocessing data...\n')

H_train = load('H_train.mat').H_train;% load file va luu gia tri vao bien
H_test = load('H_test.mat').H_test;

% UL Training
HUL_train_n = H_train;
Lambda = squeeze(1 ./ mean(abs(HUL_train_n).^2,[1 2]));% tính trung bình bình phương giá trị tuyệt đối của ma trận kênh HUL_train_n hoặc HDL_test_n trên các chiều không gian (chiều 1 và 2), sau đó nghịch đảo của giá trị trung bình này được tính. Mục đích của Lambda là để chuẩn hóa dữ liệu kênh bằng cách điều chỉnh mức năng lượng trung bình của các tín hiệu kênh, giúp dữ liệu phù hợp hơn cho các bước huấn luyện hoặc thử nghiệm tiếp theo.
if snrTrain ~= -1% MUC DICH: xử lý một tập dữ liệu (H_train) bằng cách thêm nhiễu Gaussian trắng (HN) và cập nhật giá trị của Lambda dựa trên dữ liệu đã xử lý (HUL_train_n)
    nPower = 1./(Lambda * snrTrain);% tinh cong suat nhieu
    HN = bsxfun(@times,randn(na,nc,nTrain) + 1i * randn(na,nc,nTrain),reshape(sqrt(nPower/2),1,1,[]));% nhieu Gauss (HN) duoc tao nen bang cach nhan một ma trận ngẫu nhiên phức voi ma trận (1,1,nTrain) chứa giá trị sqrt(nPower/2)
    HUL_train_n = H_train + HN;% ma tran kenh co nhieu
    Lambda = squeeze(1 ./ mean(abs(HUL_train_n).^2,[1 2]));% Tinh lai Lambda
end
HUL_train_n = bsxfun(@times,HUL_train_n,reshape(sqrt(Lambda),1,1,[]));% nhân ma trận HUL_train_n với ma trận sqrt(Lambda) đã được định dạng lại thành kích thước (1,1,nTrain)
HUL_train_compl_tmp = reshape(HUL_train_n,na*nc,nTrain).'; %_tmp% "H~train"  % thay đổi hình dạng của ma trận HUL_train_n từ kích thước (na, nc, nTrain) thành ma trận 2D có kích thước (nTrain, na*nc)
HUL_train_compl_tmp_mean = mean(HUL_train_compl_tmp); % "Muy"
HUL_train_compl = bsxfun(@minus, HUL_train_compl_tmp, HUL_train_compl_tmp_mean); %"Htrain" trừ phần tử giữa ma trận H~train voi Muy

% DL Testing
HDL_test_n = H_test;
Lambda = squeeze(1 ./ mean(abs(HDL_test_n).^2,[1 2]));% Unknown
HDL_test = bsxfun(@times,HDL_test_n,reshape(sqrt(Lambda),1,1,[]));%nhân từng phần tử của HDL_test_n với mảng sqrt(Lambda) đã được định hình lại thành kích thước (1,1,nTest)
if snrTest ~= -1% MUC DICH: thêm nhiễu Gaussian vào ma trận H_test để tạo ra HDL_test_n với công suất nhiễu dựa trên snrTest. Sau đó, nó cập nhật Lambda bằng cách tính nghịch đảo của giá trị trung bình bình phương phần tuyệt đối của HDL_test_n qua các chiều 1 và 2.
    for q = 1:nTest
        nPower = mean(abs(H_test(:,:,q)).^2,'all')/snrTest;
        HDL_test_n(:,:,q) = H_test(:,:,q) + sqrt(nPower/2) * (randn(na,nc) + 1i * randn(na,nc));
    end
    Lambda = squeeze(1 ./ mean(abs(HDL_test_n).^2,[1 2]));
end
HDL_test_n = bsxfun(@times,HDL_test_n,reshape(sqrt(Lambda),1,1,[]));%  nhân từng phần tử của HDL_test_n với mảng sqrt(Lambda) đã được định dạng lại thành kích thước (1,1,nTest). Kết quả là ma trận HDL_test_n được điều chỉnh theo giá trị của sqrt(Lambda) trên chiều thứ ba (nTest).
HDL_test_compl_tmp = reshape(HDL_test_n,na*nc,nTest).'; %_tmp % đổi hình dạng của HDL_test_n từ kích thước (na, nc, nTest) thành ma trận 2D có kích thước (nTest, na*nc)
HDL_test_compl = bsxfun(@minus, HDL_test_compl_tmp, HUL_train_compl_tmp_mean); % trừ đi giá trị trung bình tương ứng của các cột trong HUL_train_compl_tmp_mean.

%% Learn Compression (PCA training)
fprintf('Training PCA...\n')

coeff_ori = pca(HUL_train_compl);% "V" Kết quả trả về ma trận coeff_ori, chứa các vectơ riêng (hay thành phần chính) theo cột của ma trận. Các thành phần chính này mô tả hướng của phương sai tối đa trong dữ liệu HUL_train_compl.

%% Reduce Offloading Overhead
if reduce_overhead
    fprintf('Reducing offloading overhead...\n')

    coeff = zeros(size(coeff_ori));
    for i = 1:size(coeff,2)% lặp qua từng cột của ma trận coeff
        pcDFT = fftn(reshape(coeff_ori(:,i),sqrt(na),sqrt(na),nc));%  định dạng lại cột i của coeff_ori thành ma trận 3D và áp dụng biến đổi Fourier 3D để chuyển nó vào không gian tần số, tạo ra ma trận pcDFT.
        pcDFT = pcDFT(:);% "FNp làm phẳng ma trận pcDFT thành một vector cột 1D.
        mask = zeros(size(pcDFT));
        [~,locs] = maxk(abs(pcDFT),na*nc/CR);% tìm na * nc / CR phần tử lớn nhất trong pcDFT
        mask(locs) = 1;%  tạo ra một binary mask đánh dấu những phần tử đó.
        pcDFT = pcDFT .* mask;% F~Np
        coeff_tmp = ifftn(reshape(pcDFT,sqrt(na),sqrt(na),nc));% "V~Np"  định dạng lại pcDFT thành ma trận 3D rồi áp dụng phép chuyển đổi Fourier ngược để chuyển dữ liệu từ không gian tần số về không gian thời gian
        coeff(:,i) = coeff_tmp(:);%  đặt giá trị của coeff_tmp (đã được chuyển thành mảng cột 1D) vào cột i của ma trận coeff
    end
    coeff = func_gram_schmidt(coeff(:,1:500));% "V^Np" trực giao hóa các cột từ 1 đến 500 của coeff bằng cách sử dụng hàm func_gram_schmidt
else
    coeff = coeff_ori;% khong reduce parameters
end

%% Learn Quantization (k-means clustering training)
warning('off', 'stats:kmeans:FailedToConverge')

if quantization
    fprintf('Training k-means clustering...\n')

    zUL_train = HUL_train_compl * coeff;% Ztrain = Htrain * V
    zUL_train_entries = cat(3,real(zUL_train), imag(zUL_train));% tạo ra một ma trận 3D bằng cách xếp chồng hai phần thực và ảo của zUL_train theo chiều thứ ba.
    
    importances = var(zUL_train);%  tính phương sai của từng cột trong zUL_train

    Bs = func_allocate_bits(BTot, importances, zUL_train_entries);% "Vector b"
    C = length(Bs);

    zUL_train_entries_scaled = zeros(nTrain,C,2);% ma tran 0 kích thước (nTrain, C, 2)
    for i = 1:C
        zUL_train_entries_scaled(:,i,:) = zUL_train_entries(:,i,:) / sqrt(importances(i));% chuẩn hóa từng cột của zUL_train_entries bằng cách chia cho căn bậc hai của giá trị tầm quan trọng tương ứng
    end
    nTrainKMeans = min(nTrain, round(1e5/C));% kmeans is trained on 1e5 samples %  tính số mẫu huấn luyện (nTrainKMeans) để sử dụng cho K-Means bằng cách chọn giá trị nhỏ hơn giữa nTrain và round(1e5 / C)
    zUL_train_entriesCSCG = reshape(zUL_train_entries_scaled(1:nTrainKMeans,1:C,:),nTrainKMeans*C,2);% định dạng lại một phần dữ liệu zUL_train_entries_scaled thành một ma trận 2D với nTrainKMeans * C hàng và 2 cột
    quantLevelsCSCG = cell(1,Bs(1));%  tạo ra một cell array có Bs(1) phần tử
    for i = 1:Bs(1)% phân cụm K-Means trên dữ liệu zUL_train_entriesCSCG với số lượng cụm tăng dần từ 2^1 đến 2^Bs(1) và lưu centroids của mỗi lần phân cụm vào cell array quantLevelsCSCG.
        [~, quantLevelsCSCG{i}] = kmeans(zUL_train_entriesCSCG,2^i);
    end
    
    quantLevels = cell(1,C);% tạo ra một cell array có kích thước 1 x C
    for i = 1:C
        quantLevels{i} = quantLevelsCSCG{Bs(i)} * (sqrt(importances(i)));% điều chỉnh các mức lượng tử theo giá trị tầm quan trọng và lưu trữ chúng trong quantLevels.
    end
end

%% Testing
fprintf('Testing...\n')

coeff = coeff(:,1:C); % "VNp hoac V^Np"  trích xuất các cột từ 1 đến C của ma trận coeff
zDL = HDL_test_compl * coeff;% "Ztrain hoac Z^train" phép nhân ma trận giữa HDL_test_compl và coef

if quantization% MUC DICH: thay thế từng phần tử trong zDL bằng mức lượng tử gần nhất từ quantLevels. Nó lặp qua từng phần tử của zDL, tính sự khác biệt giữa phần tử đó và các mức lượng tử, rồi thay thế phần tử bằng mức lượng tử gần nhất từ quantLevels tương ứngx
    for i = 1:size(zDL,1)% Lặp qua từng hàng trong zDL.
        for j = 1:size(zDL,2)% Lặp qua từng cột trong zDL.
            [~,vecIdx] = (min(abs(zDL(i,j) - (quantLevels{j}(:,1) + 1i * quantLevels{j}(:,2))))); %  tìm chỉ số (vecIdx) của mức lượng tử gần nhất cho phần tử zDL(i, j) bằng cách tính sự khác biệt giữa zDL(i, j) và các mức lượng tử trong quantLevels{j} và tìm giá trị nhỏ nhất của sự khác biệt đó.
            zDL(i,j) = quantLevels{j}(vecIdx,1) + 1i * quantLevels{j}(vecIdx,2);%  thay thế giá trị của zDL(i, j) bằng mức lượng tử gần nhất từ quantLevels{j}, bao gồm phần thực và phần ảo của mức lượng tử đó.
        end
    end
end
HDL_reconst_tmp = zDL * coeff';% h^DL
HDL_reconst = bsxfun(@plus, HDL_reconst_tmp, HUL_train_compl_tmp_mean);% H^DL
HDL_ori_reconst = reshape(HDL_reconst.',na,nc,nTest);% định dạng lại ma trận chuyển vị HDL_reconst thành mảng ba chiều (3D) có kích thước (na, nc, nTest)

%% Assessing performance
fprintf('Assessing performance...\n')

nmse = zeros(nTest,1);
rho = zeros(nTest,1);

for i = 1:nTest% tính toán và lưu trữ giá trị NMSE và hệ số tương quan giữa kênh ban đầu và kênh tái cấu trúc cho từng mẫu kiểm tra
    ch = HDL_test(:,:,i); %Đại diện cho ma trận kênh ban đầu, tức là ma trận kênh trước khi được nén hoặc xử lý.
    ch_h = HDL_ori_reconst(:,:,i);%Đại diện cho ma trận kênh tái cấu trúc, tức là ma trận kênh sau khi đã được nén và tái cấu trúc lại. Đây là kết quả sau khi áp dụng quá trình nén và giải nén lên ma trận kênh ban đầu.
    nmse(i) = func_nmse(ch_h,ch);
    rho(i) = func_rho(ch_h,ch);
end

figure;
LineW = 1.5;
hold on;
p1 = cdfplot(10*log10(nmse));
p2 = cdfplot(10*log10(1-rho));
set(p1, 'linewidth', LineW);
set(p2, 'linewidth', LineW);
set(gca,'XLim',[-22,0],'XTick',-22:2:0);
legend('CDF 10log(NMSE)','CDF 10log(1-RHO)','location','southeast');

save(['bitAllocation-BTot',num2str(BTot),'-CR',num2str(CR),'.mat'],'Bs')




