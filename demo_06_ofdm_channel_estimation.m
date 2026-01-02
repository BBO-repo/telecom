%% Demo 6: OFDM with Channel Estimation & Equalization
%
% This script demonstrates OFDM with channel estimation:
%   - OFDM with pilot symbols
%   - Channel estimation (LS/MMSE)
%   - One-tap frequency-domain equalization
%   - Multipath fading channel
%   - Comparison of estimation methods
%   - Channel response visualization
%

clear all;
close all;
clc;

%% Configuration Parameters
N = 64;                        % FFT size
cp_length = 16;                % Cyclic prefix length
M = 16;                        % 16-QAM
num_ofdm_symbols = 50;         % Number of OFDM symbols
pilot_spacing = 4;             % Pilot spacing (every Nth subcarrier)
snr_db = 20;                   % SNR in dB

% Multipath channel (frequency-selective)
num_taps = 4;
channel_taps = [1, 0.7*exp(1j*pi/4), 0.5*exp(-1j*pi/6), 0.3];
channel_delays = [0, 1, 2, 3];

% Add paths
addpath('./utils');
addpath('./algorithms/modulation');
addpath('./algorithms/demodulation');
addpath('./algorithms/channel');
addpath('./algorithms/equalization');

fprintf('=== Demo 6: OFDM with Channel Estimation ===\n');
fprintf('FFT size: %d\n', N);
fprintf('Pilot spacing: %d\n', pilot_spacing);
fprintf('SNR: %d dB\n', snr_db);

%% Generate pilot positions
pilot_indices = 1:pilot_spacing:N;  % Equally spaced pilots
num_pilots = length(pilot_indices);
data_indices = setdiff(1:N, pilot_indices);
num_data = length(data_indices);

%% Transmitter
% Generate random data bits
bits_per_data_symbol = log2(M) * num_data;
tx_bits = generate_data(num_ofdm_symbols * bits_per_data_symbol);

% QAM modulation
tx_qam_data = qam_modulate(tx_bits, M);

% Create OFDM symbols with pilots
freq_symbols = zeros(N, num_ofdm_symbols);
for sym_idx = 1:num_ofdm_symbols
    % Data symbols
    data_start = (sym_idx - 1) * num_data + 1;
    data_end = sym_idx * num_data;
    freq_symbols(data_indices, sym_idx) = tx_qam_data(data_start:data_end);
    
    % Pilot symbols (known: BPSK, alternating)
    pilot_values = (1 - 2*mod(sym_idx, 2)) * ones(num_pilots, 1);
    freq_symbols(pilot_indices, sym_idx) = pilot_values;
end

% OFDM modulation
tx_signal = ofdm_modulate(freq_symbols, cp_length);

%% Channel
% Apply multipath channel (time domain)
rx_signal_mp = multipath_channel(tx_signal, channel_taps, channel_delays);

% Add AWGN
rx_signal = add_awgn(rx_signal_mp, snr_db);

%% Receiver
% OFDM demodulation
rx_freq_symbols = ofdm_demodulate(rx_signal, N, cp_length);

% True channel frequency response (for comparison)
H_true_freq = fft([channel_taps, zeros(1, N - length(channel_taps))].', N);

%% Channel Estimation
% Extract pilot symbols
rx_pilots = rx_freq_symbols(pilot_indices, :);
tx_pilots = freq_symbols(pilot_indices, :);

% LS channel estimation at pilot positions
H_pilots_ls = ls_channel_est(rx_pilots, tx_pilots);
H_pilots_ls_avg = mean(H_pilots_ls, 2);  % Average over symbols

% MMSE channel estimation at pilot positions
H_pilots_mmse = mmse_channel_est(rx_pilots, tx_pilots, snr_db);
H_pilots_mmse_avg = mean(H_pilots_mmse, 2);

% Interpolate to all subcarriers
H_est_ls = pilot_interpolation(H_pilots_ls_avg, pilot_indices, N, 'linear');
H_est_mmse = pilot_interpolation(H_pilots_mmse_avg, pilot_indices, N, 'linear');

%% Equalization
% Extract data symbols
rx_data_symbols = rx_freq_symbols(data_indices, :);
rx_data_vector = rx_data_symbols(:);

% Equalize using LS estimate
% Repeat channel estimate for each OFDM symbol
H_data_ls = H_est_ls(data_indices);
H_data_ls_repeated = repmat(H_data_ls, num_ofdm_symbols, 1);
eq_data_ls = zf_equalizer(rx_data_vector, H_data_ls_repeated);

% Equalize using MMSE estimate
% Repeat channel estimate for each OFDM symbol
H_data_mmse = H_est_mmse(data_indices);
H_data_mmse_repeated = repmat(H_data_mmse, num_ofdm_symbols, 1);
eq_data_mmse = mmse_equalizer(rx_data_vector, H_data_mmse_repeated, snr_db);

%% Demodulation
rx_bits_ls = qam_demodulate(eq_data_ls, M);
rx_bits_mmse = qam_demodulate(eq_data_mmse, M);

% Performance
min_length = min(length(tx_bits), length(rx_bits_ls));
ber_ls = calculate_ber(tx_bits(1:min_length), rx_bits_ls(1:min_length));
ber_mmse = calculate_ber(tx_bits(1:min_length), rx_bits_mmse(1:min_length));

fprintf('BER with LS estimation: %.2e\n', ber_ls);
fprintf('BER with MMSE estimation: %.2e\n', ber_mmse);

%% Visualization
figure('Position', [100, 100, 1400, 900]);

% Channel frequency response: True vs Estimates
subplot(2, 3, 1);
plot(1:N, abs(H_true_freq), 'k-', 'LineWidth', 2, 'DisplayName', 'True');
hold on;
plot(pilot_indices, abs(H_pilots_ls_avg), 'bo', 'MarkerSize', 8, ...
    'DisplayName', 'LS (Pilots)');
plot(1:N, abs(H_est_ls), 'b--', 'LineWidth', 1.5, 'DisplayName', 'LS (Interpolated)');
plot(1:N, abs(H_est_mmse), 'r--', 'LineWidth', 1.5, 'DisplayName', 'MMSE (Interpolated)');
grid on;
xlabel('Subcarrier Index', 'FontSize', 11);
ylabel('|H(f)|', 'FontSize', 11);
title('Channel Frequency Response (Magnitude)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'northeast');

subplot(2, 3, 2);
plot(1:N, angle(H_true_freq)*180/pi, 'k-', 'LineWidth', 2, 'DisplayName', 'True');
hold on;
plot(pilot_indices, angle(H_pilots_ls_avg)*180/pi, 'bo', 'MarkerSize', 8, ...
    'DisplayName', 'LS (Pilots)');
plot(1:N, angle(H_est_ls)*180/pi, 'b--', 'LineWidth', 1.5, 'DisplayName', 'LS (Interpolated)');
plot(1:N, angle(H_est_mmse)*180/pi, 'r--', 'LineWidth', 1.5, 'DisplayName', 'MMSE (Interpolated)');
grid on;
xlabel('Subcarrier Index', 'FontSize', 11);
ylabel('Phase (degrees)', 'FontSize', 11);
title('Channel Frequency Response (Phase)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'northeast');

% Constellation: Without equalization
subplot(2, 3, 3);
rx_unequalized = rx_data_vector(1:min(500, length(rx_data_vector)));
scatter(real(rx_unequalized), imag(rx_unequalized), 20, 'filled', ...
    'MarkerFaceAlpha', 0.6);
grid on;
xlabel('In-Phase (I)', 'FontSize', 11);
ylabel('Quadrature (Q)', 'FontSize', 11);
title('Before Equalization', 'FontSize', 12, 'FontWeight', 'bold');
axis equal;

% Constellation: LS equalization
subplot(2, 3, 4);
eq_ls_plot = eq_data_ls(1:min(500, length(eq_data_ls)));
scatter(real(eq_ls_plot), imag(eq_ls_plot), 20, 'filled', ...
    'MarkerFaceAlpha', 0.6);
grid on;
xlabel('In-Phase (I)', 'FontSize', 11);
ylabel('Quadrature (Q)', 'FontSize', 11);
title('LS Equalization', 'FontSize', 12, 'FontWeight', 'bold');
axis equal;

% Constellation: MMSE equalization
subplot(2, 3, 5);
eq_mmse_plot = eq_data_mmse(1:min(500, length(eq_data_mmse)));
scatter(real(eq_mmse_plot), imag(eq_mmse_plot), 20, 'filled', ...
    'MarkerFaceAlpha', 0.6);
grid on;
xlabel('In-Phase (I)', 'FontSize', 11);
ylabel('Quadrature (Q)', 'FontSize', 11);
title('MMSE Equalization', 'FontSize', 12, 'FontWeight', 'bold');
axis equal;

% Channel impulse response
subplot(2, 3, 6);
stem(0:length(channel_taps)-1, abs(channel_taps), 'filled', ...
    'LineWidth', 2, 'MarkerSize', 8);
grid on;
xlabel('Tap Index', 'FontSize', 11);
ylabel('|h[n]|', 'FontSize', 11);
title('Channel Impulse Response', 'FontSize', 12, 'FontWeight', 'bold');

annotation('textbox', [0.4, 0.95, 0.2, 0.05], ...
           'String', 'OFDM with Channel Estimation and Equalization', ...
           'FontSize', 16, 'FontWeight', 'bold', ...
           'HorizontalAlignment', 'center', ...
           'EdgeColor', 'none');

fprintf('\n=== Simulation Complete ===\n');

