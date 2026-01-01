%% Level 1: Basic Single-Carrier BPSK System
%
% This script demonstrates a basic BPSK communication system with:
%   - Binary data generation
%   - BPSK modulation
%   - AWGN channel
%   - Coherent BPSK demodulation
%   - BER calculation and analysis
%

clear all;
close all;
clc;

%% Configuration Parameters
num_bits = 10000;              % Number of bits to transmit
snr_db_range = 0:2:15;         % SNR range in dB for BER curve
num_trials = 100;              % Number of trials per SNR point

% Add paths to functions
addpath('./utils');
addpath('./algorithms/modulation');
addpath('./algorithms/demodulation');

%% Initialize BER storage
ber_results = zeros(size(snr_db_range));

fprintf('=== Level 1: Basic BPSK System ===\n');
fprintf('Simulating BER vs SNR...\n');

%% Main Simulation Loop
for snr_idx = 1:length(snr_db_range)
    snr_db = snr_db_range(snr_idx);
    errors = 0;
    total_bits = 0;

    % Multiple trials for better statistics
    for trial = 1:num_trials
        %% Transmitter
        % Generate random binary data
        tx_bits = generate_data(num_bits);

        % BPSK modulation
        tx_symbols = bpsk_modulate(tx_bits);

        %% Channel
        % Add AWGN
        rx_symbols = add_awgn(tx_symbols, snr_db);

        %% Receiver
        % BPSK demodulation
        rx_bits = bpsk_demodulate(rx_symbols);

        %% Performance Analysis
        % Calculate errors
        errors = errors + sum(tx_bits ~= rx_bits);
        total_bits = total_bits + length(tx_bits);
    end

    % Calculate BER
    ber_results(snr_idx) = errors / total_bits;

    fprintf('SNR = %d dB, BER = %.2e\n', snr_db, ber_results(snr_idx));
end

%% Theoretical BER for BPSK (for comparison)
snr_linear = 10.^(snr_db_range/10);
ber_theoretical = 0.5 * erfc(sqrt(snr_linear));

%% Visualization
figure('Position', [100, 100, 1200, 500]);

% BER curve
subplot(1, 2, 1);
semilogy(snr_db_range, ber_results, 'o-', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'Simulated');
hold on;
semilogy(snr_db_range, ber_theoretical, 'r--', 'LineWidth', 2, 'DisplayName', 'Theoretical');
grid on;
xlabel('SNR (dB)', 'FontSize', 12);
ylabel('Bit Error Rate (BER)', 'FontSize', 12);
title('BPSK BER Performance', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'southwest');
ylim([1e-5, 1]);

% Constellation diagram (for one trial at 10 dB SNR)
subplot(1, 2, 2);
tx_bits = generate_data(1000);
tx_symbols = bpsk_modulate(tx_bits);
rx_symbols = add_awgn(tx_symbols, 10);
scatter(real(rx_symbols), imag(rx_symbols), 20, 'filled', 'MarkerFaceAlpha', 0.6);
hold on;
scatter(real(tx_symbols), imag(tx_symbols), 100, 'rx', 'LineWidth', 2);
grid on;
xlabel('In-Phase (I)', 'FontSize', 12);
ylabel('Quadrature (Q)', 'FontSize', 12);
title('BPSK Constellation (SNR = 10 dB)', 'FontSize', 14, 'FontWeight', 'bold');
legend('Received', 'Transmitted', 'Location', 'northeast');
axis equal;
annotation('textbox', [0.4, 0.95, 0.2, 0.05], ...
           'String', 'Basic BPSK System', ...
           'FontSize', 16, 'FontWeight', 'bold', ...
           'HorizontalAlignment', 'center', ...
           'EdgeColor', 'none');

fprintf('\n=== Simulation Complete ===\n');
fprintf('Final BER at %d dB SNR: %.2e\n', snr_db_range(end), ber_results(end));

