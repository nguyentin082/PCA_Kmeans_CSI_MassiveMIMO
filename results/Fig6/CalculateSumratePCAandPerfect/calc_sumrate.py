import numpy as np
from scipy.io import loadmat
from numpy.linalg import svd, inv

# Define B values
B_values = [512, 1024, 1536, 2048]
num_users = 8  # K = 8
num_subcarriers = 128  # Giả định số lượng subcarriers là 128
snr_db = np.arange(0, 21, 5)  # SNR từ 0 đến 20 dB
snr_linear = 10**(snr_db / 10)

# Load the reconstructed channel matrices for each B value
H_reconstructed = []
H_reconstructed.append(loadmat('HDL_ori_reconst-BTot512-Ntrain2000-CR16.mat')['HDL_ori_reconst'])
H_reconstructed.append(loadmat('HDL_ori_reconst-BTot1024-Ntrain2000-CR16.mat')['HDL_ori_reconst'])
H_reconstructed.append(loadmat('HDL_ori_reconst-BTot1536-Ntrain2000-CR16.mat')['HDL_ori_reconst'])
H_reconstructed.append(loadmat('HDL_ori_reconst-BTot2048-Ntrain2000-CR16.mat')['HDL_ori_reconst'])

# Load ground truth channel
HDL_test = loadmat('HDL_test.mat')['HDL_test']

# Convert the channel matrices to complex type if needed
H_reconstructed = [h.astype(np.complex128) for h in H_reconstructed]
HDL_test = HDL_test.astype(np.complex128)

# Function to calculate the sum rate
def calculate_sum_rate(H_reconstructed, snr_linear):
    num_test_samples = H_reconstructed.shape[2]
    sum_rate = np.zeros(len(snr_linear))

    for idx, snr in enumerate(snr_linear):
        for i in range(num_test_samples):
            H = H_reconstructed[:, :, i]
            sum_rate[idx] += zero_forcing_sum_rate(H, snr)
        sum_rate[idx] /= num_test_samples

    return sum_rate

# Function to calculate the sum rate using zero-forcing and water-filling
def zero_forcing_sum_rate(H, snr):
    total_sum_rate = 0

    for k in range(num_subcarriers):
        H_k = H[:, k, :]  # Correct the dimensions to (num_antennas, num_users)
        H_k_inv = inv(H_k.conj().T @ H_k + np.eye(num_users) * (1/snr))
        W = H_k @ H_k_inv
        U, S, V = svd(W)
        power_alloc = water_filling_power_allocation(S, snr)
        total_sum_rate += np.sum(np.log2(1 + S**2 * power_alloc))

    return total_sum_rate / num_subcarriers

# Function to perform water-filling power allocation
def water_filling_power_allocation(S, snr):
    num_users = len(S)
    power_alloc = np.zeros(num_users)
    mu = (1 + np.sum(1/S**2)) / (num_users + snr)
    for i in range(num_users):
        power_alloc[i] = max(0, mu - (1/S[i]**2))
    return power_alloc

# Calculate sum rates for each B value and SNR
sum_rates = []
for H in H_reconstructed:
    sum_rates.append(calculate_sum_rate(H, snr_linear))

# Plot the results
import matplotlib.pyplot as plt

plt.figure()
for i, B in enumerate(B_values):
    plt.plot(snr_db, sum_rates[i], label=f'B = {B}')
plt.xlabel('SNR (dB)')
plt.ylabel('Average Sum Rate (bps/Hz)')
plt.title('Average Sum Rate vs. SNR for Different Values of B')
plt.legend()
plt.grid(True)
plt.show()