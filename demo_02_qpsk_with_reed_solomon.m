%% Demo 2: QPSK with Basic Error Correction (Reed-Solomon)
%
% This script demonstrates QPSK modulation with Reed-Solomon error correction:
%   - QPSK modulation/demodulation
%   - Reed-Solomon encoding/decoding
%   - AWGN channel
%   - BER comparison with and without coding
%   - Performance curves (BER vs SNR)
%

clear all;
close all;
clc;

%% Configuration Parameters
num_bits = 1000;               % Number of bits to transmit
snr_db_range = 0:2:15;         % SNR range in dB
num_trials = 10;               % Number of trials per SNR point

% Reed-Solomon code parameters
n = 7;                         % Codeword length
k = 4;                         % Message length
code_rate = k / n;             % Code rate

% Add paths
addpath('./utils');
addpath('./algorithms/modulation');
addpath('./algorithms/demodulation');
addpath('./algorithms/coding');

%% Initialize BER storage
ber_uncoded = zeros(size(snr_db_range));
ber_coded = zeros(size(snr_db_range));

fprintf('=== Demo 2: QPSK with Reed-Solomon Coding ===\n');
fprintf('Code rate: %.2f (n=%d, k=%d)\n', code_rate, n, k);
fprintf('Simulating BER vs SNR...\n');

%% Main Simulation Loop
for snr_idx = 1:length(snr_db_range)
    snr_db = snr_db_range(snr_idx);
    errors_uncoded = 0;
    errors_coded = 0;
    total_bits_uncoded = 0;
    total_bits_coded = 0;

    % Adjust SNR for coded case (coding reduces effective SNR)
    snr_coded_db = snr_db + 10*log10(code_rate);

    for trial = 1:num_trials
        %% Uncoded System
        tx_bits = generate_data(num_bits);

        % QPSK modulation
        tx_symbols = qpsk_modulate(tx_bits);

        % Channel
        rx_symbols = add_awgn(tx_symbols, snr_db);

        % Demodulation
        rx_bits_uncoded = qpsk_demodulate(rx_symbols);

        % Count errors
        errors_uncoded = errors_uncoded + sum(tx_bits ~= rx_bits_uncoded);
        total_bits_uncoded = total_bits_uncoded + length(tx_bits);

        %% Coded System
        % Convert bits to symbols for RS encoding
        % For (7,4) RS code in GF(8), each symbol is 3 bits (2^3 = 8)
        bits_per_symbol = 3;  % GF(2^3) = GF(8)
        max_symbol_value = 2^bits_per_symbol - 1;  % 0-7
        
        % Pad bits to make length multiple of (k * bits_per_symbol)
        bits_per_block = k * bits_per_symbol;  % 4 symbols * 3 bits = 12 bits per block
        num_blocks = ceil(length(tx_bits) / bits_per_block);
        tx_bits_padded = [tx_bits, zeros(1, num_blocks * bits_per_block - length(tx_bits))];
        
        % Convert bits to symbols (groups of 3 bits -> symbol 0-7)
        num_symbols = length(tx_bits_padded) / bits_per_symbol;
        tx_rs_symbols = zeros(1, num_symbols);
        for i = 1:num_symbols
            bit_start = (i-1) * bits_per_symbol + 1;
            bit_end = i * bits_per_symbol;
            bit_group = tx_bits_padded(bit_start:bit_end);
            % Convert binary to decimal (0-7)
            tx_rs_symbols(i) = sum(bit_group .* 2.^(bits_per_symbol-1:-1:0));
        end
        
        % Reed-Solomon encoding
        tx_rs_encoded = rs_encode(tx_rs_symbols, n, k);
        
        % Convert encoded symbols back to bits
        tx_bits_coded = [];
        for i = 1:length(tx_rs_encoded)
            symbol = tx_rs_encoded(i);
            % Convert decimal to binary (MSB first, ensure 3 bits)
            symbol_bits = zeros(1, bits_per_symbol);
            for j = 1:bits_per_symbol
                symbol_bits(j) = mod(floor(symbol / 2^(bits_per_symbol - j)), 2);
            end
            tx_bits_coded = [tx_bits_coded, symbol_bits];
        end
        
        % Pad to make length multiple of 2 for QPSK (2 bits per QPSK symbol)
        if mod(length(tx_bits_coded), 2) ~= 0
            tx_bits_coded = [tx_bits_coded, 0];
        end

        % QPSK modulation
        tx_symbols_coded = qpsk_modulate(tx_bits_coded);

        % Channel (with adjusted SNR)
        rx_symbols_coded = add_awgn(tx_symbols_coded, snr_coded_db);

        % Demodulation
        rx_bits_coded = qpsk_demodulate(rx_symbols_coded);
        
        % Convert bits back to RS symbols
        % Truncate to multiple of bits_per_symbol
        rx_bits_coded = rx_bits_coded(1:floor(length(rx_bits_coded)/bits_per_symbol)*bits_per_symbol);
        num_rx_symbols = length(rx_bits_coded) / bits_per_symbol;
        rx_rs_encoded = zeros(1, num_rx_symbols);
        for i = 1:num_rx_symbols
            bit_start = (i-1) * bits_per_symbol + 1;
            bit_end = i * bits_per_symbol;
            bit_group = rx_bits_coded(bit_start:bit_end);
            % Convert binary to decimal, clamp to valid range
            symbol_value = sum(bit_group .* 2.^(bits_per_symbol-1:-1:0));
            rx_rs_encoded(i) = min(max(symbol_value, 0), max_symbol_value);
        end
        
        % Reed-Solomon decoding
        rx_rs_decoded = rs_decode(rx_rs_encoded, n, k);
        
        % Convert decoded symbols back to bits
        rx_bits_decoded = [];
        for i = 1:length(rx_rs_decoded)
            symbol = rx_rs_decoded(i);
            % Convert decimal to binary (MSB first, ensure 3 bits)
            symbol_bits = zeros(1, bits_per_symbol);
            for j = 1:bits_per_symbol
                symbol_bits(j) = mod(floor(symbol / 2^(bits_per_symbol - j)), 2);
            end
            rx_bits_decoded = [rx_bits_decoded, symbol_bits];
        end
        
        % Truncate to original length
        rx_bits_decoded = rx_bits_decoded(1:length(tx_bits));

        % Count errors
        errors_coded = errors_coded + sum(tx_bits ~= rx_bits_decoded);
        total_bits_coded = total_bits_coded + length(tx_bits);
    end

    % Calculate BERs
    ber_uncoded(snr_idx) = errors_uncoded / total_bits_uncoded;
    if total_bits_coded > 0
        ber_coded(snr_idx) = errors_coded / total_bits_coded;
    else
        ber_coded(snr_idx) = 1;
    end

    fprintf('SNR = %d dB: Uncoded BER = %.2e, Coded BER = %.2e\n', ...
        snr_db, ber_uncoded(snr_idx), ber_coded(snr_idx));
end

%% Theoretical BER for QPSK
snr_linear = 10.^(snr_db_range/10);
ber_qpsk_theoretical = 0.5 * erfc(sqrt(snr_linear));

%% Visualization
figure('Position', [100, 100, 1200, 500]);

% BER comparison
subplot(1, 2, 1);
semilogy(snr_db_range, ber_uncoded, 'o-', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'Uncoded QPSK');
hold on;
semilogy(snr_db_range, ber_coded, 's-', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'RS Coded QPSK');
semilogy(snr_db_range, ber_qpsk_theoretical, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Theoretical QPSK');
grid on;
xlabel('SNR (dB)', 'FontSize', 12);
ylabel('Bit Error Rate (BER)', 'FontSize', 12);
title('BER Performance: Coded vs Uncoded', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'southwest');
ylim([1e-5, 1]);

% Coding gain at BER = 1e-3
[~, idx_target] = min(abs(ber_uncoded - 1e-3));
if idx_target > 0 && idx_target <= length(snr_db_range)
    snr_uncoded_target = snr_db_range(idx_target);
    [~, idx_coded] = min(abs(ber_coded - 1e-3));
    if idx_coded > 0 && idx_coded <= length(snr_db_range)
        snr_coded_target = snr_db_range(idx_coded);
        coding_gain = snr_uncoded_target - snr_coded_target;
        fprintf('Coding gain at BER=1e-3: %.2f dB\n', coding_gain);
    end
end

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
           'String', 'QPSK with Reed-Solomon Coding', ...
           'FontSize', 16, 'FontWeight', 'bold', ...
           'HorizontalAlignment', 'center', ...
           'EdgeColor', 'none');

fprintf('\n=== Simulation Complete ===\n');

