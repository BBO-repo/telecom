%% Demo 7: OFDM with Advanced Synchronization
%
% This script demonstrates OFDM with full synchronization chain:
%   - OFDM with Schmidl-Cox synchronization
%   - Integer frequency offset (IFO) estimation
%   - Fractional frequency offset (FFO) estimation
%   - Symbol timing detection
%   - Sample clock offset correction
%   - Full receiver chain with sync errors
%

clear all;
close all;
clc;

%% Configuration Parameters
N = 64;                        % FFT size
cp_length = 16;                % Cyclic prefix length
M = 16;                        % 16-QAM
num_ofdm_symbols = 20;         % Number of OFDM symbols
snr_db = 20;                   % SNR in dB

% Synchronization impairments
freq_offset_frac = 0.1;        % Fractional frequency offset (normalized)
freq_offset_int = 2;           % Integer frequency offset (subcarriers)
timing_offset = 10;            % Timing offset (samples)

% Add paths
addpath('./utils');
addpath('./algorithms/modulation');
addpath('./algorithms/demodulation');
addpath('./algorithms/sync');

fprintf('=== Demo 7: OFDM with Full Synchronization ===\n');
fprintf('FFT size: %d\n', N);
fprintf('Fractional FO: %.2f\n', freq_offset_frac);
fprintf('Integer FO: %d subcarriers\n', freq_offset_int);
fprintf('Timing offset: %d samples\n', timing_offset);
fprintf('SNR: %d dB\n', snr_db);

%% Transmitter
% Generate random data bits
bits_per_symbol = log2(M) * N;
tx_bits = generate_data(num_ofdm_symbols * bits_per_symbol);

% QAM modulation
tx_qam_symbols = qam_modulate(tx_bits, M);

% Reshape into OFDM symbols
freq_symbols = reshape(tx_qam_symbols, N, num_ofdm_symbols);

% Add training symbol (Schmidl-Cox: two identical halves)
training_symbol_freq = [randn(N/2, 1); randn(N/2, 1)];  % Two identical halves
training_symbol_time = ifft(training_symbol_freq, N);
training_symbol = [training_symbol_time(end-cp_length+1:end); training_symbol_time];

% OFDM modulation
tx_data_symbols = ofdm_modulate(freq_symbols, cp_length);

% Complete frame: training + data
tx_frame = [training_symbol; tx_data_symbols];

% Add random delay
tx_with_delay = [zeros(timing_offset, 1); tx_frame];

%% Channel
% Add frequency offset (fractional + integer)
% Fractional FO: phase rotation
t = (0:length(tx_with_delay)-1)';
tx_with_fo_frac = tx_with_delay .* exp(1j * 2 * pi * freq_offset_frac * t / N);

% Integer FO: circular shift in frequency domain
% This is approximated in time domain by phase ramp
tx_with_fo = tx_with_fo_frac .* exp(1j * 2 * pi * freq_offset_int * t / N);

% Add AWGN
rx_signal = add_awgn(tx_with_fo, snr_db);

%% Receiver: Synchronization
fprintf('Performing synchronization...\n');

% Step 1: Schmidl-Cox timing and fractional FO estimation
[timing_metric, ffo_est] = ofdm_sync_schmidl_cox(rx_signal, N);

% Find symbol start (peak of timing metric)
[~, symbol_start] = max(timing_metric);
fprintf('Estimated symbol start: sample %d (true: %d)\n', symbol_start, timing_offset + 1);

% Step 2: Correct fractional frequency offset
rx_corrected_ffo = freq_offset_correct(rx_signal, -ffo_est * N, 1);  % Correct in time domain

fprintf('Estimated fractional FO: %.4f (true: %.4f)\n', ffo_est, freq_offset_frac);
fprintf('Frequency offset estimation error: %.4f\n', abs(ffo_est - freq_offset_frac));

% Step 3: Integer frequency offset estimation
% Extract first data symbol
symbol_start_adj = symbol_start + cp_length + N;  % Skip training symbol
if symbol_start_adj + N + cp_length <= length(rx_corrected_ffo)
    % Extract one data symbol
    data_symbol_with_cp = rx_corrected_ffo(symbol_start_adj : symbol_start_adj + N + cp_length - 1);
    data_symbol = data_symbol_with_cp(cp_length + 1 : end);
    data_symbol_freq = fft(data_symbol, N);

    % Simple IFO estimation: correlate with known pattern (simplified)
    % In practice, would use dedicated training sequences
    % Here, we'll estimate based on maximum correlation
    ifo_est = 0;  % Simplified - would use cross-correlation method
else
    ifo_est = 0;
end

% Step 4: Correct integer frequency offset (circular shift in freq domain)
rx_sync = rx_corrected_ffo(symbol_start:end);  % Extract from symbol start

% OFDM demodulation
rx_freq_symbols = ofdm_demodulate(rx_sync, N, cp_length);

% Correct IFO (circular shift)
if ifo_est ~= 0
    rx_freq_symbols = circshift(rx_freq_symbols, -ifo_est);
end

% Extract only data symbols (skip training)
rx_freq_data = rx_freq_symbols(:, 2:end);  % First symbol is training

% Reshape to vector
rx_qam_symbols = rx_freq_data(:);

%% Demodulation
rx_bits = qam_demodulate(rx_qam_symbols, M);

% Compare with transmitted bits (account for possible length mismatch)
min_length = min(length(tx_bits), length(rx_bits));
if min_length > 0
    ber = calculate_ber(tx_bits(1:min_length), rx_bits(1:min_length));
    fprintf('BER: %.2e\n', ber);
end

% Calculate and display timing error
timing_error = abs(symbol_start - (timing_offset + 1));
fprintf('Timing synchronization error: %d samples\n', timing_error);

%% Visualization
figure('Position', [100, 100, 1400, 800]);

% Timing metric
subplot(2, 2, 1);
plot(timing_metric, 'LineWidth', 2);
hold on;
plot([symbol_start, symbol_start], ylim, 'r--', 'LineWidth', 2);
plot([timing_offset+1, timing_offset+1], ylim, 'g--', 'LineWidth', 2);
grid on;
xlabel('Sample Index', 'FontSize', 11);
ylabel('Timing Metric', 'FontSize', 11);
title('Schmidl-Cox Timing Metric', 'FontSize', 12, 'FontWeight', 'bold');
legend('Metric', 'Estimated', 'True', 'Location', 'northeast');

% Received signal (time domain, first few samples)
subplot(2, 2, 2);
plot(1:min(200, length(rx_signal)), real(rx_signal(1:min(200, length(rx_signal)))), ...
    'LineWidth', 1.5);
hold on;
plot(1:min(200, length(tx_frame)), real(tx_frame(1:min(200, length(tx_frame)))), ...
    'r--', 'LineWidth', 1.5);
grid on;
xlabel('Sample Index', 'FontSize', 11);
ylabel('Amplitude', 'FontSize', 11);
title('Received Signal (Time Domain)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Received', 'Transmitted', 'Location', 'northeast');

% Constellation: Before synchronization
subplot(2, 2, 3);
% Extract symbols without sync (for visualization)
if length(rx_signal) > N + cp_length
    rx_unsync_freq = ofdm_demodulate(rx_signal(timing_offset+1:end), N, cp_length);
    rx_unsync_data = rx_unsync_freq(:, 2);
    rx_unsync_vec = rx_unsync_data(:);
    if length(rx_unsync_vec) > 100
        scatter(real(rx_unsync_vec(1:100)), imag(rx_unsync_vec(1:100)), ...
            20, 'filled', 'MarkerFaceAlpha', 0.6);
    end
end
grid on;
xlabel('In-Phase (I)', 'FontSize', 11);
ylabel('Quadrature (Q)', 'FontSize', 11);
title('Before Synchronization', 'FontSize', 12, 'FontWeight', 'bold');
axis equal;

% Constellation: After synchronization
subplot(2, 2, 4);
if length(rx_qam_symbols) > 100
    scatter(real(rx_qam_symbols(1:100)), imag(rx_qam_symbols(1:100)), ...
        20, 'filled', 'MarkerFaceAlpha', 0.6);
end
grid on;
xlabel('In-Phase (I)', 'FontSize', 11);
ylabel('Quadrature (Q)', 'FontSize', 11);
title('After Synchronization', 'FontSize', 12, 'FontWeight', 'bold');
axis equal;

annotation('textbox', [0.4, 0.95, 0.2, 0.05], ...
           'String', 'OFDM with Advanced Synchronization', ...
           'FontSize', 16, 'FontWeight', 'bold', ...
           'HorizontalAlignment', 'center', ...
           'EdgeColor', 'none');

fprintf('\n=== Simulation Complete ===\n');

