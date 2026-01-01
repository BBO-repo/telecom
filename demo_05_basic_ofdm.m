%% Level 5: Basic OFDM System
%
% This script demonstrates a basic OFDM system:
%   - OFDM modulation (IFFT)
%   - Cyclic prefix addition
%   - OFDM demodulation (FFT)
%   - Subcarrier QAM mapping (16-QAM)
%   - AWGN channel
%   - BER vs SNR performance
%

clear all;
close all;
clc;

%% Configuration Parameters
N = 64;                        % FFT size (number of subcarriers)
cp_length = 16;                % Cyclic prefix length
M = 16;                        % 16-QAM modulation
num_ofdm_symbols = 100;        % Number of OFDM symbols
snr_db_range = 0:2:20;         % SNR range for BER curve
num_trials = 10;               % Trials per SNR point

% Add paths
addpath('./utils');
addpath('./algorithms/modulation');
addpath('./algorithms/demodulation');

fprintf('=== Level 5: Basic OFDM System ===\n');
fprintf('FFT size: %d\n', N);
fprintf('CP length: %d\n', cp_length);
fprintf('Modulation: %d-QAM\n', M);
fprintf('Number of OFDM symbols: %d\n', num_ofdm_symbols);

%% Initialize BER storage
ber_results = zeros(size(snr_db_range));

%% Main Simulation Loop
for snr_idx = 1:length(snr_db_range)
    snr_db = snr_db_range(snr_idx);
    errors = 0;
    total_bits = 0;

    for trial = 1:num_trials
        %% Transmitter
        % Generate random bits
        bits_per_symbol = log2(M) * N;  % Bits per OFDM symbol
        tx_bits = generate_data(num_ofdm_symbols * bits_per_symbol);

        % QAM modulation
        tx_qam_symbols = qam_modulate(tx_bits, M);

        % Reshape into OFDM symbols (frequency domain)
        freq_symbols = reshape(tx_qam_symbols, N, num_ofdm_symbols);

        % OFDM modulation (IFFT + CP)
        tx_signal = ofdm_modulate(freq_symbols, cp_length);

        %% Channel
        % Add AWGN
        rx_signal = add_awgn(tx_signal, snr_db);

        %% Receiver
        % OFDM demodulation (remove CP + FFT)
        rx_freq_symbols = ofdm_demodulate(rx_signal, N, cp_length);

        % Reshape to vector
        rx_qam_symbols = rx_freq_symbols(:);

        % QAM demodulation
        rx_bits = qam_demodulate(rx_qam_symbols, M);

        %% Performance Analysis
        % Calculate errors
        min_length = min(length(tx_bits), length(rx_bits));
        errors = errors + sum(tx_bits(1:min_length) ~= rx_bits(1:min_length));
        total_bits = total_bits + min_length;
    end

    % Calculate BER
    ber_results(snr_idx) = errors / total_bits;
    fprintf('SNR = %d dB, BER = %.2e\n', snr_db, ber_results(snr_idx));
end

%% Theoretical BER for 16-QAM
snr_linear = 10.^(snr_db_range/10);
% Approximate theoretical BER for 16-QAM in AWGN
% qfunc(x) = 0.5*erfc(x/sqrt(2))
ber_16qam_theoretical = 1.5 * 0.5 * erfc(sqrt(0.4 * snr_linear) / sqrt(2));

%% Visualization
figure('Position', [100, 100, 1400, 600]);

% BER curve
subplot(1, 2, 1);
semilogy(snr_db_range, ber_results, 'o-', 'LineWidth', 2, 'MarkerSize', 8, ...
    'DisplayName', 'Simulated OFDM');
hold on;
semilogy(snr_db_range, ber_16qam_theoretical, 'r--', 'LineWidth', 2, ...
    'DisplayName', 'Theoretical 16-QAM');
grid on;
xlabel('SNR (dB)', 'FontSize', 12);
ylabel('Bit Error Rate (BER)', 'FontSize', 12);
title('OFDM BER Performance', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'southwest');
ylim([1e-5, 1]);

% Time domain OFDM signal (one symbol)
subplot(1, 2, 2);
% Generate one OFDM symbol for visualization
bits_one_symbol = generate_data(bits_per_symbol);
qam_one = qam_modulate(bits_one_symbol, M);
freq_one = reshape(qam_one, N, 1);
tx_one = ofdm_modulate(freq_one, cp_length);

plot(real(tx_one), 'LineWidth', 1.5);
hold on;
plot(imag(tx_one), 'LineWidth', 1.5);
grid on;
xlabel('Sample Index', 'FontSize', 12);
ylabel('Amplitude', 'FontSize', 12);
title('OFDM Symbol (Time Domain)', 'FontSize', 14, 'FontWeight', 'bold');
legend('Real', 'Imaginary', 'Location', 'northeast');

annotation('textbox', [0.4, 0.95, 0.2, 0.05], ...
           'String', 'Basic OFDM System', ...
           'FontSize', 16, 'FontWeight', 'bold', ...
           'HorizontalAlignment', 'center', ...
           'EdgeColor', 'none');

fprintf('\n=== Simulation Complete ===\n');
fprintf('Final BER at %d dB SNR: %.2e\n', snr_db_range(end), ber_results(end));

