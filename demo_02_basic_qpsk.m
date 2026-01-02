%% Demo 2: QPSK Modulation System with Hamming FEC
%
% This script demonstrates QPSK modulation and demodulation with (7,4) Hamming FEC:
%   - QPSK modulation/demodulation
%   - (7,4) Hamming forward error correction
%   - AWGN channel
%   - BER performance analysis (coded vs uncoded)
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
addpath('./algorithms/coding');

%% Initialize BER storage
ber_qpsk_uncoded = zeros(size(snr_db_range));
ber_qpsk_coded = zeros(size(snr_db_range));

fprintf('=== Demo 2: QPSK Modulation System with Hamming FEC ===\n');
fprintf('Simulating BER vs SNR (coded and uncoded)...\n');

%% Main Simulation Loop
for snr_idx = 1:length(snr_db_range)
    snr_db = snr_db_range(snr_idx);
    errors_uncoded = 0;
    errors_coded = 0;
    total_bits_uncoded = 0;
    total_bits_coded = 0;

    for trial = 1:num_trials
        % Generate original data bits
        tx_data_bits = generate_data(num_bits);

        %% Uncoded path (for comparison)
        % QPSK modulation
        tx_symbols_uncoded = qpsk_modulate(tx_data_bits);

        % Channel
        rx_symbols_uncoded = add_awgn(tx_symbols_uncoded, snr_db);

        % Demodulation
        rx_bits_uncoded = qpsk_demodulate(rx_symbols_uncoded);

        % Count errors (compare with original data bits)
        errors_uncoded = errors_uncoded + sum(tx_data_bits ~= rx_bits_uncoded);
        total_bits_uncoded = total_bits_uncoded + length(tx_data_bits);

        %% Coded path (with Hamming FEC)
        % Hamming encoding
        tx_encoded_bits = hamming_encode(tx_data_bits);

        % QPSK modulation
        tx_symbols_coded = qpsk_modulate(tx_encoded_bits);

        % Channel
        rx_symbols_coded = add_awgn(tx_symbols_coded, snr_db);

        % Demodulation
        rx_encoded_bits = qpsk_demodulate(rx_symbols_coded);

        % Hamming decoding (with error correction)
        rx_decoded_bits = hamming_decode(rx_encoded_bits);

        % Truncate decoded bits to match original length (in case of padding)
        if length(rx_decoded_bits) > length(tx_data_bits)
            rx_decoded_bits = rx_decoded_bits(1:length(tx_data_bits));
        end

        % Count errors (compare decoded bits with original data bits)
        errors_coded = errors_coded + sum(tx_data_bits ~= rx_decoded_bits);
        total_bits_coded = total_bits_coded + length(tx_data_bits);
    end

    % Calculate BER
    ber_qpsk_uncoded(snr_idx) = errors_uncoded / total_bits_uncoded;
    ber_qpsk_coded(snr_idx) = errors_coded / total_bits_coded;

    fprintf('SNR = %d dB: Uncoded BER = %.2e, Coded BER = %.2e\n', ...
            snr_db, ber_qpsk_uncoded(snr_idx), ber_qpsk_coded(snr_idx));
end

%% Theoretical BER for QPSK
snr_linear = 10.^(snr_db_range/10);
% Convert SNR to Eb/No (QPSK has 2 bits per symbol: Eb = Es/2)
% SNR (linear) = Es/No = 2*Eb/No, therefore Eb/No = SNR/2
ebno_linear = snr_linear / 2;
ber_qpsk_theoretical = 0.5 * erfc(sqrt(ebno_linear));

% Note: Theoretical BER for coded QPSK with (7,4) Hamming is more complex
% and depends on the error correction capability. The coded performance
% shows improvement at low to moderate SNR due to error correction.

%% Visualization
figure('Position', [100, 100, 1200, 500]);

% BER performance
subplot(1, 2, 1);
semilogy(snr_db_range, ber_qpsk_uncoded, 'o-', 'LineWidth', 2, 'MarkerSize', 8, ...
         'DisplayName', 'Simulated QPSK (Uncoded)', 'Color', [0.2 0.6 0.8]);
hold on;
semilogy(snr_db_range, ber_qpsk_coded, 's-', 'LineWidth', 2, 'MarkerSize', 8, ...
         'DisplayName', 'Simulated QPSK (Hamming Coded)', 'Color', [0.8 0.4 0.2]);
semilogy(snr_db_range, ber_qpsk_theoretical, 'r--', 'LineWidth', 1.5, ...
         'DisplayName', 'Theoretical QPSK (Uncoded)');
grid on;
xlabel('SNR (dB)', 'FontSize', 12);
ylabel('Bit Error Rate (BER)', 'FontSize', 12);
title('QPSK BER Performance: Coded vs Uncoded', 'FontSize', 14, 'FontWeight', 'bold');
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
           'String', 'QPSK with Hamming FEC', ...
           'FontSize', 16, 'FontWeight', 'bold', ...
           'HorizontalAlignment', 'center', ...
           'EdgeColor', 'none');

fprintf('\n=== Simulation Complete ===\n');
