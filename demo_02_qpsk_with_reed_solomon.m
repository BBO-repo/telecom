%% Demo 2: QPSK Modulation System
%
% This script demonstrates QPSK modulation and demodulation:
%   - QPSK modulation/demodulation
%   - AWGN channel
%   - BER performance analysis
%   - Performance curves (BER vs SNR)
%   - Constellation visualization
%

clear all;
close all;
clc;

%% Configuration Parameters
num_bits = 1000;               % Number of bits to transmit
snr_db_range = 0:2:15;         % SNR range in dB
num_trials = 10;               % Number of trials per SNR point

% Add paths
addpath('./utils');
addpath('./algorithms/modulation');
addpath('./algorithms/demodulation');

%% Initialize BER storage
ber_qpsk = zeros(size(snr_db_range));

fprintf('=== Demo 2: QPSK Modulation System ===\n');
fprintf('Simulating BER vs SNR...\n');

%% Main Simulation Loop
for snr_idx = 1:length(snr_db_range)
    snr_db = snr_db_range(snr_idx);
    errors = 0;
    total_bits = 0;

    for trial = 1:num_trials
        % Generate data
        tx_bits = generate_data(num_bits);

        % QPSK modulation
        tx_symbols = qpsk_modulate(tx_bits);

        % Channel
        rx_symbols = add_awgn(tx_symbols, snr_db);

        % Demodulation
        rx_bits = qpsk_demodulate(rx_symbols);

        % Count errors
        errors = errors + sum(tx_bits ~= rx_bits);
        total_bits = total_bits + length(tx_bits);
    end

    % Calculate BER
    ber_qpsk(snr_idx) = errors / total_bits;

    fprintf('SNR = %d dB: BER = %.2e\n', snr_db, ber_qpsk(snr_idx));
end

%% Theoretical BER for QPSK
snr_linear = 10.^(snr_db_range/10);
ber_qpsk_theoretical = 0.5 * erfc(sqrt(snr_linear));

%% Visualization
figure('Position', [100, 100, 1200, 500]);

% BER performance
subplot(1, 2, 1);
semilogy(snr_db_range, ber_qpsk, 'o-', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'Simulated QPSK');
hold on;
semilogy(snr_db_range, ber_qpsk_theoretical, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Theoretical QPSK');
grid on;
xlabel('SNR (dB)', 'FontSize', 12);
ylabel('Bit Error Rate (BER)', 'FontSize', 12);
title('QPSK BER Performance', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'southwest');
ylim([1e-5, 1]);

% Constellation diagram
subplot(1, 2, 2);
tx_bits = generate_data(1000);
tx_symbols = qpsk_modulate(tx_bits);
rx_symbols = add_awgn(tx_symbols, 10);
scatter(real(rx_symbols), imag(rx_symbols), 20, 'filled', 'MarkerFaceAlpha', 0.6);
hold on;
scatter(real(tx_symbols), imag(tx_symbols), 100, 'rx', 'LineWidth', 2);
grid on;
xlabel('In-Phase (I)', 'FontSize', 12);
ylabel('Quadrature (Q)', 'FontSize', 12);
title('QPSK Constellation (SNR = 10 dB)', 'FontSize', 14, 'FontWeight', 'bold');
legend('Received', 'Transmitted', 'Location', 'northeast');
axis equal;

annotation('textbox', [0.4, 0.95, 0.2, 0.05], ...
           'String', 'QPSK Modulation System', ...
           'FontSize', 16, 'FontWeight', 'bold', ...
           'HorizontalAlignment', 'center', ...
           'EdgeColor', 'none');

fprintf('\n=== Simulation Complete ===\n');
