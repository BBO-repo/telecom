%% Demo 1: Basic Single-Carrier BPSK System
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
num_bits = 100000;              % Number of bits to transmit
ebno_db_range = -20:2:10;      % Eb/No range in dB for BER curve
num_trials = 100;              % Number of trials per Eb/No point

% Add paths to functions
addpath('./utils');
addpath('./algorithms/modulation');
addpath('./algorithms/demodulation');

%% Initialize BER storage
ber_results = zeros(size(ebno_db_range));

fprintf('=== Demo 1: Basic BPSK System ===\n');
fprintf('Simulating BER vs Eb/No...\n');

%% Main Simulation Loop
for ebno_idx = 1:length(ebno_db_range)
    ebno_db = ebno_db_range(ebno_idx);
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
        % Add AWGN with proper Eb/No calculation
        % For BPSK: Eb = Es (1 bit per symbol), so Eb/No = Es/No
        % Theoretical BER formula uses two-sided PSD: BER = 0.5*erfc(sqrt(Eb/No))
        % This assumes noise variance = No/2 per dimension
        % For baseband real signals, we need noise variance = No/2
        tx_symbols_real = real(tx_symbols);
        Es = mean(tx_symbols_real.^2);  % Symbol energy (should be 1 for default BPSK)
        ebno_linear = 10^(ebno_db/10);
        No = Es / ebno_linear;  % Noise PSD (two-sided)
        noise_variance = No / 2;  % Noise variance for baseband real signal
        noise = sqrt(noise_variance) * randn(size(tx_symbols_real));
        rx_symbols = tx_symbols_real + noise;

        %% Receiver
        % BPSK demodulation
        rx_bits = bpsk_demodulate(rx_symbols);

        %% Performance Analysis
        % Calculate errors
        errors = errors + sum(tx_bits ~= rx_bits);
        total_bits = total_bits + length(tx_bits);
    end

    % Calculate BER
    ber_results(ebno_idx) = errors / total_bits;

    fprintf('Eb/No = %d dB, BER = %.2e\n', ebno_db, ber_results(ebno_idx));
end

%% Theoretical BER for BPSK (for comparison)
ebno_linear = 10.^(ebno_db_range/10);
ber_theoretical = 0.5 * erfc(sqrt(ebno_linear));

%% Visualization
figure('Position', [100, 100, 1200, 500]);

% BER curve
subplot(1, 2, 1);
semilogy(ebno_db_range, ber_results, 'o-', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'Simulated');
hold on;
semilogy(ebno_db_range, ber_theoretical, 'r--', 'LineWidth', 2, 'DisplayName', 'Theoretical');
grid on;
xlabel('Eb/No (dB)', 'FontSize', 12);
ylabel('Bit Error Rate (BER)', 'FontSize', 12);
title('BPSK BER Performance', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'southwest');
ylim([1e-5, 1]);

% Constellation diagram (for one trial at 10 dB Eb/No)
subplot(1, 2, 2);
tx_bits = generate_data(1000);
tx_symbols = bpsk_modulate(tx_bits);
tx_symbols_real = real(tx_symbols);
Es = mean(tx_symbols_real.^2);
ebno_linear = 10^(10/10);
No = Es / ebno_linear;
noise_variance = No / 2;
noise = sqrt(noise_variance) * randn(size(tx_symbols_real));
rx_symbols = tx_symbols_real + noise;
scatter(real(rx_symbols), imag(rx_symbols), 20, 'filled', 'MarkerFaceAlpha', 0.6);
hold on;
scatter(real(tx_symbols), imag(tx_symbols), 100, 'rx', 'LineWidth', 2);
grid on;
xlabel('In-Phase (I)', 'FontSize', 12);
ylabel('Quadrature (Q)', 'FontSize', 12);
title('BPSK Constellation (Eb/No = 10 dB)', 'FontSize', 14, 'FontWeight', 'bold');
legend('Received', 'Transmitted', 'Location', 'northeast');
axis equal;
annotation('textbox', [0.4, 0.95, 0.2, 0.05], ...
           'String', 'Basic BPSK System', ...
           'FontSize', 16, 'FontWeight', 'bold', ...
           'HorizontalAlignment', 'center', ...
           'EdgeColor', 'none');

fprintf('\n=== Simulation Complete ===\n');
fprintf('Final BER at %d dB Eb/No: %.2e\n', ebno_db_range(end), ber_results(end));

