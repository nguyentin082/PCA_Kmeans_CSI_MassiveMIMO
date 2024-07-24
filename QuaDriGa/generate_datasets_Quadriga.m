%% Outdoor Scenario
% This script implements an outdoor scenario where a BS is connected to nRxs static UEs.

addpath 'C:\Users\dangt\Downloads\QuaDRiGa_2020.11.03_v2.4.0\quadriga_src'

clear; close all; clc;
rng(1);

fDL = 2.62e9; % [Hz]
fUL = 2.5e9; % 2.48e9; % [Hz]

f0 = (fDL + fUL) / 2; %2.45e9; % [Hz]

B = 8e6; % [Hz]
nAntX = 8;
nAntY = 8;
nc = 160; % Number of subcarriers
nRxs = 1000; % Number of users
radius = 100; % [m]
minRadius = 20;
plotFigs = true; % boolean
singleFreq = true; % boolean
nPaths = -1; % Number of paths to consider

%% Layout Setup

l = qd_layout;                                          % Create new layout
l.simpar.center_frequency = f0;                         % Set center frequency to 2.4 GHz

l.no_rx = nRxs;                                         % Set number of MTs

l.randomize_rx_positions(radius, 1.5, 1.5, 0,[], minRadius); % 1.5 m Rx height
l.set_scenario('3GPP_38.901_UMi_NLOS');                  % Use NLOS scenario

l.tx_position(3) = 20;                                  % 20 m tx height
l.tx_array = qd_arrayant('3gpp-3d', nAntX, nAntY, f0);  % M x N BS antenna

l.rx_array = qd_arrayant('omni');                       % Omni-directional MT antenna

%% Visualization

if plotFigs
    l.visualize([],[],0);
    view(30, 60);
    %saveas(gcf,'my_scenario_single_freq.png')
end

%% Channel Coefficients Generation

rng(3);
c = l.get_channels;

%% Postprocessing

if singleFreq % chỉ sử dụng một tần số duy nhất (tần số trung tâm)
    H = single(zeros(nAntX*nAntY,nc,nRxs));
    for iRx = 1:nRxs
        H(:,:,iRx) = squeeze(c(iRx,1).fr(B,nc));
    end
else %  sử dụng hai tần số (tải lên và tải xuống)
    BTot = abs(fDL - fUL) + B;
    Df = B / nc;
    ncTot = BTot / Df;
    carriers = [1:nc ncTot-nc+1:ncTot]/ncTot;
    HTmp = single(zeros(nAntX*nAntY,2*nc,nRxs));
    %%
    if nPaths ~= -1 % Lọc các đường truyền yếu
        for iRx = 1:nRxs
            cMat = squeeze(c(iRx,1).coeff);
            pathPowers = sum(abs(cMat).^2);
            pathPowersSort = sort(pathPowers,'descend');
            pathPowersTh = pathPowersSort(nPaths);
            for i = 1:length(pathPowers)
                if pathPowers(i) < pathPowersTh
                    cMat(:,i) = 0;
                end
            end
            c(iRx,1).coeff(1,:,:) = cMat;
        end
    end
    %%
    for iRx = 1:nRxs % Lấy hệ số kênh cho hai tần số
        HTmp(:,:,iRx) = squeeze(c(iRx,1).fr(BTot,carriers));
    end
    H = single(zeros(nAntX*nAntY,nc,nRxs,2));
    H(:,:,:,1) = HTmp(:,0*nc+1:1*nc,:);
    H(:,:,:,2) = HTmp(:,1*nc+1:2*nc,:);
end

% In ra kích thước của H
disp(size(H));

% Lấy và in ra một phần tử ngẫu nhiên trong H
randomEntry = H(randi(size(H, 1)), randi(size(H, 2)), randi(size(H, 3)));
disp(randomEntry);

save('H-UMi_NLOS.mat','H')