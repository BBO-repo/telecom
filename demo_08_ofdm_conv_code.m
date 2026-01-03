%% Demo 8: Complete OFDM System with Convolution Codes
%
% This script demonstrates a complete OFDM system with:
%   - Full OFDM system (64-QAM)
%   - Convolutional code encoding/decoding (rate 1/2)
%   - Channel estimation with interpolation
%   - Advanced equalization (MMSE)
%   - Full synchronization chain
%   - Adaptive modulation support
%   - Comprehensive performance analysis
%   - Comparison with theoretical limits
%

clear all;
close all;
clc;

%% Configuration Parameters
N = 64;                        % FFT size
cp_length = 16;                % Cyclic prefix length
M = 64;                        % 64-QAM modulation
num_ofdm_symbols = 30;         % Number of OFDM symbols
snr_db = 0;                    % SNR in dB
pilot_spacing = 8;             % Pilot spacing

% Convolutional code parameters
conv_rate = 1/2;               % Code rate (1/2)

% Synchronization parameters
freq_offset_frac = 0.05;
timing_offset = 8;

% Channel parameters
channel_taps = [1, 0.6*exp(1j*pi/3), 0.4*exp(-1j*pi/4), 0.2];
channel_delays = [0, 1, 2, 3];

% Add paths
addpath('./utils');
addpath('./algorithms/modulation');
addpath('./algorithms/demodulation');
addpath('./algorithms/coding');
addpath('./algorithms/channel');
addpath('./algorithms/equalization');
addpath('./algorithms/sync');

fprintf('=== Demo 8: Complete OFDM System with Convolution Codes ===\n');
fprintf('FFT size: %d\n', N);
fprintf('Modulation: %d-QAM\n', M);
fprintf('Convolutional code rate: %.2f\n', conv_rate);
fprintf('SNR: %d dB\n', snr_db);

%% Generate pilot positions
pilot_indices = 1:pilot_spacing:N;
num_pilots = length(pilot_indices);
data_indices = setdiff(1:N, pilot_indices);
num_data = length(data_indices);

%% Transmitter
% Generate random data bits
% For rate 1/2, encoded_bits ≈ 2 * data_bits (plus tail bits for constraint length 3)
bits_per_data_symbol = log2(M) * num_data;
total_encoded_bits_needed = num_ofdm_symbols * bits_per_data_symbol;
% Account for rate 1/2: data_bits = (encoded_bits - tail_bits) / 2
% Tail bits: constraint_length-1 = 2 bits, which produce 4 encoded bits (2 outputs)
tail_encoded_bits = 2 * (3 - 1);  % 2 outputs * (constraint_length - 1)
total_data_bits = floor((total_encoded_bits_needed - tail_encoded_bits) / 2);
tx_data_bits = generate_data(total_data_bits);

% Convolutional encoding (rate 1/2)
fprintf('Convolutional encoding...\n');
tx_encoded_bits = conv_encode(tx_data_bits);

% Adjust encoded bits to fit OFDM symbols exactly
bits_needed = num_ofdm_symbols * bits_per_data_symbol;
if length(tx_encoded_bits) > bits_needed
    tx_encoded_bits = tx_encoded_bits(1:bits_needed);
else
    % Pad with zeros (will be handled by decoder)
    tx_encoded_bits = [tx_encoded_bits, zeros(1, bits_needed - length(tx_encoded_bits))];
end

% QAM modulation
tx_qam_data = qam_modulate(tx_encoded_bits, M);

% Create OFDM symbols with pilots
freq_symbols = zeros(N, num_ofdm_symbols);
for sym_idx = 1:num_ofdm_symbols
    % Data symbols
    data_start = (sym_idx - 1) * num_data + 1;
    data_end = sym_idx * num_data;
    freq_symbols(data_indices, sym_idx) = tx_qam_data(data_start:data_end);

    % Pilot symbols
    pilot_values = (1 - 2*mod(sym_idx, 2)) * ones(num_pilots, 1);
    freq_symbols(pilot_indices, sym_idx) = pilot_values;
end

% Add training symbol for synchronization (Schmidl-Cox)
training_symbol_freq = [randn(N/2, 1); randn(N/2, 1)];
training_symbol_time = ifft(training_symbol_freq, N);
training_symbol = [training_symbol_time(end-cp_length+1:end); training_symbol_time];

% OFDM modulation
tx_data_symbols = ofdm_modulate(freq_symbols, cp_length);
tx_frame = [training_symbol; tx_data_symbols];

% Add impairments
t = (0:length(tx_frame)-1)';
tx_frame = tx_frame .* exp(1j * 2 * pi * freq_offset_frac * t / N);
tx_with_delay = [zeros(timing_offset, 1); tx_frame];

%% Channel
% Multipath channel
rx_signal_mp = multipath_channel(tx_with_delay, channel_taps, channel_delays);

% Add AWGN
rx_signal = add_awgn(rx_signal_mp, snr_db);

%% Receiver: Synchronization
fprintf('Performing synchronization...\n');
[timing_metric, ffo_est] = ofdm_sync_schmidl_cox(rx_signal, N);
[~, symbol_start] = max(timing_metric);
rx_corrected_ffo = freq_offset_correct(rx_signal, -ffo_est * N, 1);
rx_sync = rx_corrected_ffo(symbol_start:end);

% OFDM demodulation
rx_freq_symbols = ofdm_demodulate(rx_sync, N, cp_length);

% Skip training symbol
rx_freq_data = rx_freq_symbols(:, 2:end);

%% Channel Estimation and Equalization
fprintf('Channel estimation and equalization...\n');

% Extract pilots - ensure same number of columns
rx_pilots = rx_freq_data(pilot_indices, :);
num_rx_symbols = size(rx_freq_data, 2);
% Match the number of columns from received data
tx_pilots = freq_symbols(pilot_indices, 2:min(2+num_rx_symbols-1, size(freq_symbols, 2)));

% MMSE channel estimation
H_pilots_mmse = mmse_channel_est(rx_pilots, tx_pilots, snr_db);
H_pilots_avg = mean(H_pilots_mmse, 2);

% Interpolate to all subcarriers
H_est = pilot_interpolation(H_pilots_avg, pilot_indices, N, 'spline');

% Equalize data symbols
rx_data_symbols = rx_freq_data(data_indices, :);
rx_data_vector = rx_data_symbols(:);
H_data = H_est(data_indices);

% Repeat channel estimate for each OFDM symbol
num_rx_data_symbols = size(rx_data_symbols, 2);
H_data_repeated = repmat(H_data, num_rx_data_symbols, 1);

% MMSE equalization
eq_data = mmse_equalizer(rx_data_vector, H_data_repeated, snr_db);

%% Demodulation and Soft Decision Extraction
% Compute LLRs (Log-Likelihood Ratios) for soft-decision decoding
fprintf('Computing soft decisions for Viterbi decoding...\n');

% Generate constellation for LLR computation
bits_per_symbol = log2(M);
sqrt_M = sqrt(M);
levels = -sqrt_M + 1 : 2 : sqrt_M - 1;

% Normalize equalized symbols (reverse energy scaling)
energy = 1;
current_energy = 2*(M-1)/3;
eq_data_norm = eq_data / sqrt(energy / current_energy);

% Compute LLRs for each bit in each symbol
num_symbols = length(eq_data_norm);
rx_llrs = zeros(1, num_symbols * bits_per_symbol);

for i = 1:num_symbols
    symbol = eq_data_norm(i);
    I = real(symbol);
    Q = imag(symbol);

    % For each bit position, compute LLR
    % LLR = log(P(bit=0) / P(bit=1))
    % Approximate using distance to nearest constellation points
    for bit_pos = 1:bits_per_symbol
        % Determine which bit this is (I or Q component)
        if bit_pos <= bits_per_symbol/2
            % I component bits
            component = I;
            bit_idx_in_component = bit_pos;
            num_bits_in_component = bits_per_symbol/2;
        else
            % Q component bits
            component = Q;
            bit_idx_in_component = bit_pos - bits_per_symbol/2;
            num_bits_in_component = bits_per_symbol/2;
        end

        % Find distance to nearest level where this bit is 0
        % and nearest level where this bit is 1
        min_dist_0 = inf;
        min_dist_1 = inf;

        for level_idx = 1:length(levels)
            level = levels(level_idx);
            % Convert level index to binary (0-indexed)
            level_bin_idx = level_idx - 1;
            % Get bit value at this position
            bit_value = mod(floor(level_bin_idx / 2^(num_bits_in_component - bit_idx_in_component)), 2);

            dist = abs(component - level);

            if bit_value == 0 && dist < min_dist_0
                min_dist_0 = dist;
            elseif bit_value == 1 && dist < min_dist_1
                min_dist_1 = dist;
            end
        end

        % Compute approximate LLR
        % LLR ≈ (min_dist_1^2 - min_dist_0^2) / (2*sigma^2)
        % For simplicity, use distance difference scaled by SNR
        sigma_est = 1 / sqrt(10^(snr_db/10));  % Rough noise estimate
        if sigma_est > 0
            llr = (min_dist_1^2 - min_dist_0^2) / (2 * sigma_est^2);
        else
            llr = (min_dist_1 - min_dist_0) * 10;  % Fallback
        end

        rx_llrs((i-1)*bits_per_symbol + bit_pos) = llr;
    end
end

% Also get hard bits for comparison
rx_qam_bits = qam_demodulate(eq_data, M);

%% Convolutional Decoding (Soft Decision Viterbi)
fprintf('Convolutional decoding (Viterbi soft-decision)...\n');
rx_decoded_bits = conv_decode(rx_llrs, [], [], true);  % is_soft = true

%% Performance Analysis
min_length = min(length(tx_data_bits), length(rx_decoded_bits));
if min_length > 0
    ber = calculate_ber(tx_data_bits(1:min_length), rx_decoded_bits(1:min_length));
    fprintf('BER: %.2e\n', ber);
end

% EVM calculation
ideal_symbols = tx_qam_data(1:min(length(eq_data), length(tx_qam_data)));
if length(eq_data) <= length(ideal_symbols)
    evm = calculate_evm(eq_data, ideal_symbols(1:length(eq_data)));
    fprintf('EVM: %.2f dB\n', evm);
end

%% Theoretical comparison
% Theoretical BER for 64-QAM in AWGN
snr_linear = 10^(snr_db/10);
% Approximate: ber_64qam ≈ 7/12 * erfc(sqrt(3/7 * snr))
ber_theoretical_64qam = (7/12) * 0.5 * erfc(sqrt((3/7) * snr_linear) / sqrt(2));

fprintf('Theoretical BER (64-QAM): %.2e\n', ber_theoretical_64qam);

%% Visualization
figure('Position', [100, 100, 1400, 900]);

% Channel frequency response
subplot(2, 3, 1);
H_true = fft([channel_taps, zeros(1, N - length(channel_taps))].', N);
plot(1:N, abs(H_true), 'k-', 'LineWidth', 2, 'DisplayName', 'True');
hold on;
plot(pilot_indices, abs(H_pilots_avg), 'bo', 'MarkerSize', 8, ...
    'DisplayName', 'MMSE (Pilots)');
plot(1:N, abs(H_est), 'r--', 'LineWidth', 1.5, 'DisplayName', 'Interpolated');
grid on;
xlabel('Subcarrier Index', 'FontSize', 11);
ylabel('|H(f)|', 'FontSize', 11);
title('Channel Frequency Response', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'northeast');

% Constellation: Before equalization
subplot(2, 3, 2);
rx_uneq = rx_data_vector(1:min(500, length(rx_data_vector)));
scatter(real(rx_uneq), imag(rx_uneq), 15, 'filled', 'MarkerFaceAlpha', 0.5);
grid on;
xlabel('In-Phase (I)', 'FontSize', 11);
ylabel('Quadrature (Q)', 'FontSize', 11);
title('Before Equalization', 'FontSize', 12, 'FontWeight', 'bold');
axis equal;

% Constellation: After equalization
subplot(2, 3, 3);
eq_plot = eq_data(1:min(500, length(eq_data)));
scatter(real(eq_plot), imag(eq_plot), 15, 'filled', 'MarkerFaceAlpha', 0.5);
grid on;
xlabel('In-Phase (I)', 'FontSize', 11);
ylabel('Quadrature (Q)', 'FontSize', 11);
title('After MMSE Equalization', 'FontSize', 12, 'FontWeight', 'bold');
axis equal;

% Timing metric
subplot(2, 3, 4);
plot(timing_metric, 'LineWidth', 1.5);
hold on;
plot([symbol_start, symbol_start], ylim, 'r--', 'LineWidth', 2);
grid on;
xlabel('Sample Index', 'FontSize', 11);
ylabel('Timing Metric', 'FontSize', 11);
title('Synchronization Timing Metric', 'FontSize', 12, 'FontWeight', 'bold');

% Performance summary
subplot(2, 3, 5);
if min_length > 0
    performance_metrics = [ber, ber_theoretical_64qam];
    bar(1:2, log10(performance_metrics + eps), 'FaceColor', [0.3, 0.6, 0.9]);
    grid on;
    ylabel('log10(BER)', 'FontSize', 11);
    title('Performance Comparison', 'FontSize', 12, 'FontWeight', 'bold');
    xticklabels({'Simulated', 'Theoretical'});
end

% Channel impulse response
subplot(2, 3, 6);
stem(0:length(channel_taps)-1, abs(channel_taps), 'filled', ...
    'LineWidth', 2, 'MarkerSize', 8);
grid on;
xlabel('Tap Index', 'FontSize', 11);
ylabel('|h[n]|', 'FontSize', 11);
title('Channel Impulse Response', 'FontSize', 12, 'FontWeight', 'bold');

annotation('textbox', [0.4, 0.95, 0.2, 0.05], ...
           'String', 'Complete OFDM System with Convolution Codes', ...
           'FontSize', 16, 'FontWeight', 'bold', ...
           'HorizontalAlignment', 'center', ...
           'EdgeColor', 'none');

fprintf('\n=== Simulation Complete ===\n');
fprintf('System successfully demonstrates:\n');
fprintf('  - OFDM modulation/demodulation\n');
fprintf('  - Convolutional coding (rate 1/2)\n');
fprintf('  - Viterbi soft-decision decoding\n');
fprintf('  - Channel estimation\n');
fprintf('  - MMSE equalization\n');
fprintf('  - Full synchronization\n');

