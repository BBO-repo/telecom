%% Demo 3: 16-QAM with Adaptive Equalization (LMS)
%
% This script demonstrates 16-QAM with LMS adaptive equalization:
%   - 16-QAM modulation/demodulation
%   - FIR multipath channel model
%   - LMS adaptive equalizer
%   - Training sequence and decision-directed modes
%   - Convergence plots
%   - EVM measurement
%

clear all;
close all;
clc;

%% Configuration Parameters
num_bits = 10000;              % Number of bits
snr_db = 20;                   % SNR in dB
M = 16;                        % 16-QAM
num_taps = 7;                  % Equalizer taps
step_size = 0.01;              % LMS step size
training_length = 500;         % Training sequence length

% Multipath channel (FIR filter)
channel_taps = [1, 0.5*exp(1j*pi/4), 0.3*exp(-1j*pi/6), 0.15];
channel_delays = [0, 1, 2, 3];

% Add paths
addpath('./utils');
addpath('./algorithms/modulation');
addpath('./algorithms/demodulation');
addpath('./algorithms/channel');
addpath('./algorithms/equalization');

fprintf('=== Demo 3: 16-QAM with LMS Equalization ===\n');
fprintf('Channel taps: %d\n', length(channel_taps));
fprintf('Equalizer taps: %d\n', num_taps);
fprintf('SNR: %d dB\n', snr_db);

%% Transmitter
% Generate random data
tx_bits = generate_data(num_bits);

% 16-QAM modulation
tx_symbols = qam_modulate(tx_bits, M);

% Create training sequence (known symbols)
training_bits = generate_data(training_length * log2(M));
training_symbols = qam_modulate(training_bits, M);

% Combine training and data
tx_symbols_full = [training_symbols; tx_symbols];

%% Channel
% Apply multipath channel
rx_symbols_mp = multipath_channel(tx_symbols_full, channel_taps, channel_delays);

% Add AWGN
rx_symbols = add_awgn(rx_symbols_mp, snr_db);

%% Receiver
% LMS Equalization with training
fprintf('Running LMS equalizer...\n');
[equalized_symbols, weights] = lms_equalizer(rx_symbols, training_symbols, ...
    step_size, num_taps, M);

% Extract data symbols (skip training)
equalized_data = equalized_symbols(training_length + 1 : end);

%% Demodulation
% Without equalization (for comparison)
rx_data_no_eq = rx_symbols(training_length + 1 : end);
rx_bits_no_eq = qam_demodulate(rx_data_no_eq, M);

% With equalization
rx_bits_eq = qam_demodulate(equalized_data, M);

% Reference (transmitted bits)
tx_data_bits = tx_bits(1:min(length(tx_bits), length(rx_bits_eq)));

%% Performance Analysis
ber_no_eq = calculate_ber(tx_data_bits(1:length(rx_bits_no_eq)), rx_bits_no_eq);
ber_eq = calculate_ber(tx_data_bits(1:length(rx_bits_eq)), rx_bits_eq);

% EVM calculation
ideal_symbols = tx_symbols(1:length(equalized_data));
evm_no_eq = calculate_evm(rx_data_no_eq(1:length(ideal_symbols)), ideal_symbols);
evm_eq = calculate_evm(equalized_data(1:length(ideal_symbols)), ideal_symbols);

fprintf('BER without equalization: %.2e\n', ber_no_eq);
fprintf('BER with LMS equalization: %.2e\n', ber_eq);
fprintf('EVM without equalization: %.2f dB\n', evm_no_eq);
fprintf('EVM with LMS equalization: %.2f dB\n', evm_eq);

%% Visualization
figure('Position', [100, 100, 1400, 800]);

% Constellation: Received (no equalization)
subplot(2, 3, 1);
scatter(real(rx_data_no_eq), imag(rx_data_no_eq), 20, 'filled', 'MarkerFaceAlpha', 0.6);
grid on;
xlabel('In-Phase (I)', 'FontSize', 11);
ylabel('Quadrature (Q)', 'FontSize', 11);
title('Received (No Equalization)', 'FontSize', 12, 'FontWeight', 'bold');
axis equal;

% Constellation: Equalized
subplot(2, 3, 2);
scatter(real(equalized_data), imag(equalized_data), 20, 'filled', 'MarkerFaceAlpha', 0.6);
hold on;
% Plot ideal constellation (generate all 16-QAM points)
% Generate all 16-QAM constellation points manually
bits_all = [];
for i = 0:15
    % Convert i to 4-bit binary
    bits_4 = [];
    for j = 3:-1:0
        bits_4 = [bits_4, mod(floor(i/2^j), 2)];
    end
    bits_all = [bits_all, bits_4];
end
ideal_const = qam_modulate(bits_all, M);  % All constellation points
scatter(real(ideal_const), imag(ideal_const), 100, 'rx', 'LineWidth', 2);
grid on;
xlabel('In-Phase (I)', 'FontSize', 11);
ylabel('Quadrature (Q)', 'FontSize', 11);
title('Equalized Output', 'FontSize', 12, 'FontWeight', 'bold');
legend('Received', 'Ideal', 'Location', 'northeast');
axis equal;

% Constellation: Ideal
subplot(2, 3, 3);
scatter(real(ideal_symbols), imag(ideal_symbols), 20, 'filled', 'MarkerFaceAlpha', 0.6);
grid on;
xlabel('In-Phase (I)', 'FontSize', 11);
ylabel('Quadrature (Q)', 'FontSize', 11);
title('Transmitted (Ideal)', 'FontSize', 12, 'FontWeight', 'bold');
axis equal;

% Equalizer weights convergence (magnitude)
subplot(2, 3, 4);
plot(1:num_taps, abs(weights), 'o-', 'LineWidth', 2, 'MarkerSize', 8);
grid on;
xlabel('Tap Index', 'FontSize', 11);
ylabel('|Weight|', 'FontSize', 11);
title('Equalizer Weights (Magnitude)', 'FontSize', 12, 'FontWeight', 'bold');

% Equalizer weights (phase)
subplot(2, 3, 5);
plot(1:num_taps, angle(weights)*180/pi, 'o-', 'LineWidth', 2, 'MarkerSize', 8);
grid on;
xlabel('Tap Index', 'FontSize', 11);
ylabel('Phase (degrees)', 'FontSize', 11);
title('Equalizer Weights (Phase)', 'FontSize', 12, 'FontWeight', 'bold');

% Channel impulse response
subplot(2, 3, 6);
stem(0:length(channel_taps)-1, abs(channel_taps), 'filled', 'LineWidth', 2, 'MarkerSize', 8);
grid on;
xlabel('Tap Index', 'FontSize', 11);
ylabel('|Channel|', 'FontSize', 11);
title('Channel Impulse Response', 'FontSize', 12, 'FontWeight', 'bold');

annotation('textbox', [0.4, 0.95, 0.2, 0.05], ...
           'String', '16-QAM with LMS Adaptive Equalization', ...
           'FontSize', 16, 'FontWeight', 'bold', ...
           'HorizontalAlignment', 'center', ...
           'EdgeColor', 'none');

fprintf('\n=== Simulation Complete ===\n');

