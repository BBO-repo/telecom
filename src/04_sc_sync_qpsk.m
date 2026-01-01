%% Level 4: Single-Carrier QPSK with Timing/Frequency Synchronization
%
% This script demonstrates QPSK with synchronization:
%   - QPSK modulation with preamble
%   - Timing synchronization (correlation-based)
%   - Frequency offset estimation (FFT-based)
%   - Frequency offset correction
%   - Frame synchronization
%   - Performance under sync errors
%

clear all;
close all;
clc;

%% Configuration Parameters
num_bits = 5000;               % Number of data bits
preamble_length = 64;          % Preamble length (symbols)
snr_db = 15;                   % SNR in dB
freq_offset_hz = 0.01;         % Frequency offset (normalized)
fs = 1;                        % Sampling frequency (normalized)

% Add paths
addpath('./utils');
addpath('./algorithms/modulation');
addpath('./algorithms/demodulation');
addpath('./algorithms/sync');

fprintf('=== Level 4: QPSK with Synchronization ===\n');
fprintf('Frequency offset: %.4f (normalized)\n', freq_offset_hz);
fprintf('SNR: %d dB\n', snr_db);

%% Transmitter
% Generate random data
tx_data_bits = generate_data(num_bits);

% Create preamble (known sequence)
preamble_bits = repmat([1, 0], 1, preamble_length);  % Alternating pattern
preamble_symbols = qpsk_modulate(preamble_bits);

% QPSK modulation of data
tx_data_symbols = qpsk_modulate(tx_data_bits);

% Frame structure: preamble + data
tx_frame = [preamble_symbols; tx_data_symbols];

% Add random delay (simulating unknown start)
delay_samples = 100;
tx_with_delay = [zeros(delay_samples, 1); tx_frame];

%% Channel
% Add frequency offset
t = (0:length(tx_with_delay)-1)' / fs;
tx_with_offset = tx_with_delay .* exp(1j * 2 * pi * freq_offset_hz * t);

% Add AWGN
rx_signal = add_awgn(tx_with_offset, snr_db);

%% Receiver
fprintf('Performing synchronization...\n');

% Step 1: Timing synchronization
[frame_start, correlation] = timing_sync(rx_signal, preamble_symbols);
fprintf('Estimated frame start: sample %d (true: %d)\n', frame_start, delay_samples + 1);

% Step 2: Frequency offset estimation
% Use first part of preamble
preamble_samples = rx_signal(frame_start : frame_start + preamble_length - 1);
estimated_freq_offset = freq_offset_estimate(preamble_samples, preamble_length/2, fs);
fprintf('Estimated frequency offset: %.6f (true: %.6f)\n', estimated_freq_offset, freq_offset_hz);

% Step 3: Frequency offset correction
rx_corrected = freq_offset_correct(rx_signal, estimated_freq_offset, fs);

% Step 4: Extract frame (using estimated timing)
rx_frame = rx_corrected(frame_start : frame_start + length(tx_frame) - 1);

% Extract data (skip preamble)
rx_data_symbols = rx_frame(preamble_length + 1 : end);

% Ensure we have the right length
min_length = min(length(rx_data_symbols), length(tx_data_symbols));
rx_data_symbols = rx_data_symbols(1:min_length);
tx_data_symbols = tx_data_symbols(1:min_length);

%% Demodulation
rx_bits = qpsk_demodulate(rx_data_symbols);
tx_bits_for_comp = tx_data_bits(1:length(rx_bits));

%% Performance Analysis
ber = calculate_ber(tx_bits_for_comp, rx_bits);
fprintf('BER: %.2e\n', ber);

%% Visualization
figure('Position', [100, 100, 1400, 800]);

% Timing correlation
subplot(2, 3, 1);
plot(correlation, 'LineWidth', 2);
hold on;
plot([frame_start, frame_start], ylim, 'r--', 'LineWidth', 2);
plot([delay_samples+1, delay_samples+1], ylim, 'g--', 'LineWidth', 2);
grid on;
xlabel('Sample Index', 'FontSize', 11);
ylabel('Correlation', 'FontSize', 11);
title('Timing Synchronization', 'FontSize', 12, 'FontWeight', 'bold');
legend('Correlation', 'Estimated Start', 'True Start', 'Location', 'best');

% Constellation: With frequency offset
subplot(2, 3, 2);
rx_before_correction = rx_signal(frame_start:frame_start+length(preamble_symbols)-1);
scatter(real(rx_before_correction), imag(rx_before_correction), 30, 'filled', 'MarkerFaceAlpha', 0.6);
grid on;
xlabel('In-Phase (I)', 'FontSize', 11);
ylabel('Quadrature (Q)', 'FontSize', 11);
title('Before Frequency Correction', 'FontSize', 12, 'FontWeight', 'bold');
axis equal;

% Constellation: After frequency correction
subplot(2, 3, 3);
scatter(real(rx_data_symbols), imag(rx_data_symbols), 30, 'filled', 'MarkerFaceAlpha', 0.6);
hold on;
scatter(real(tx_data_symbols), imag(tx_data_symbols), 100, 'rx', 'LineWidth', 2);
grid on;
xlabel('In-Phase (I)', 'FontSize', 11);
ylabel('Quadrature (Q)', 'FontSize', 11);
title('After Frequency Correction', 'FontSize', 12, 'FontWeight', 'bold');
legend('Received', 'Transmitted', 'Location', 'best');
axis equal;

% Frequency offset estimation error
subplot(2, 3, 4);
freq_error = abs(estimated_freq_offset - freq_offset_hz);
bar(1, freq_error, 'FaceColor', [0.8, 0.2, 0.2]);
grid on;
ylabel('Frequency Offset Error', 'FontSize', 11);
title('Frequency Offset Estimation Error', 'FontSize', 12, 'FontWeight', 'bold');
xticklabels({''});

% Timing error
subplot(2, 3, 5);
timing_error = abs(frame_start - (delay_samples + 1));
bar(1, timing_error, 'FaceColor', [0.2, 0.2, 0.8]);
grid on;
ylabel('Timing Error (samples)', 'FontSize', 11);
title('Timing Synchronization Error', 'FontSize', 12, 'FontWeight', 'bold');
xticklabels({''});

% Preamble correlation detail
subplot(2, 3, 6);
plot(frame_start-20:frame_start+20, correlation(frame_start-20:frame_start+20), ...
    'o-', 'LineWidth', 2, 'MarkerSize', 6);
hold on;
plot([frame_start, frame_start], ylim, 'r--', 'LineWidth', 2);
grid on;
xlabel('Sample Index', 'FontSize', 11);
ylabel('Correlation', 'FontSize', 11);
title('Timing Correlation (Detail)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Correlation', 'Estimated Start', 'Location', 'best');

sgtitle('Level 4: QPSK with Timing and Frequency Synchronization', ...
    'FontSize', 16, 'FontWeight', 'bold');

fprintf('\n=== Simulation Complete ===\n');

