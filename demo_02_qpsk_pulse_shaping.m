%% Demo 2: QPSK Pulse Shaping Visualization
%
% This script demonstrates QPSK modulation with and without pulse shaping:
%   - QPSK symbol generation
%   - Rectangular pulse shaping (no filtering)
%   - Raised cosine pulse shaping
%   - Time domain waveform comparison
%   - Frequency domain spectral comparison
%   - Eye diagram visualization
%
% This reproduces the visualizations from:
% https://dsp.stackexchange.com/a/70414

clear all;
close all;
clc;

%% Configuration Parameters
num_bits = 200;              % Number of bits to transmit
samples_per_symbol = 16;     % Samples per symbol for smooth visualization
rolloff = 0.3;               % Roll-off factor (alpha) for raised cosine
filter_span = 6;              % Filter span in symbol periods

% Add paths
addpath('./utils');
addpath('./algorithms/modulation');
addpath('./algorithms/demodulation');

fprintf('=== Demo 2: QPSK Pulse Shaping Visualization ===\n');
fprintf('Generating QPSK symbols and applying pulse shaping...\n');

%% Generate QPSK Symbols
tx_bits = generate_data(num_bits);
tx_symbols = qpsk_modulate(tx_bits);
num_symbols = length(tx_symbols);

fprintf('Generated %d QPSK symbols from %d bits\n', num_symbols, num_bits);

%% Create Waveforms

% 1. Without pulse shaping: Rectangular pulses (hold value for each symbol period)
rectangular_waveform = zeros(num_symbols * samples_per_symbol, 1);
for i = 1:num_symbols
    idx_start = (i-1) * samples_per_symbol + 1;
    idx_end = i * samples_per_symbol;
    rectangular_waveform(idx_start:idx_end) = tx_symbols(i);
end

% 2. With pulse shaping: Root raised cosine filtered
pulse_shaped_waveform = apply_pulse_shaping(tx_symbols, samples_per_symbol, ...
                                            rolloff, filter_span, 'rrc');

% Time vector for plotting
time_rect = (0:length(rectangular_waveform)-1) / samples_per_symbol;
time_pulse = (0:length(pulse_shaped_waveform)-1) / samples_per_symbol;

fprintf('Created rectangular and pulse-shaped waveforms\n');
fprintf('Roll-off factor: %.2f\n', rolloff);

%% Visualization

% Create figure with multiple subplots
figure('Position', [100, 100, 1400, 900]);

%% 1. Time Domain Comparison - I and Q Components
subplot(3, 2, 1);
plot(time_rect, real(rectangular_waveform), 'b-', 'LineWidth', 1.5, ...
     'DisplayName', 'I (Rectangular)');
hold on;
plot(time_rect, imag(rectangular_waveform), 'r-', 'LineWidth', 1.5, ...
     'DisplayName', 'Q (Rectangular)');
grid on;
xlabel('Time (Symbol Periods)', 'FontSize', 11);
ylabel('Amplitude', 'FontSize', 11);
title('QPSK Without Pulse Shaping (Rectangular Pulses)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'northeast');
xlim([0, min(20, max(time_rect))]);  % Show first 20 symbols

subplot(3, 2, 2);
plot(time_pulse, real(pulse_shaped_waveform), 'b-', 'LineWidth', 1.5, ...
     'DisplayName', 'I (Pulse Shaped)');
hold on;
plot(time_pulse, imag(pulse_shaped_waveform), 'r-', 'LineWidth', 1.5, ...
     'DisplayName', 'Q (Pulse Shaped)');
% Mark symbol sampling points
symbol_times = (0:num_symbols-1);
symbol_samples = tx_symbols;
hold on;
plot(symbol_times, real(symbol_samples), 'bo', 'MarkerSize', 8, ...
     'MarkerFaceColor', 'b', 'DisplayName', 'Symbol Samples (I)');
plot(symbol_times, imag(symbol_samples), 'ro', 'MarkerSize', 8, ...
     'MarkerFaceColor', 'r', 'DisplayName', 'Symbol Samples (Q)');
grid on;
xlabel('Time (Symbol Periods)', 'FontSize', 11);
ylabel('Amplitude', 'FontSize', 11);
title(sprintf('QPSK With Pulse Shaping (Raised Cosine, α=%.2f)', rolloff), ...
      'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'northeast');
xlim([0, min(20, max(time_pulse))]);  % Show first 20 symbols

%% 2. Frequency Domain Comparison
subplot(3, 2, 3);

% Compute power spectral density using FFT
N_fft = 2^nextpow2(max(length(rectangular_waveform), length(pulse_shaped_waveform)));
freq_rect = fft(rectangular_waveform, N_fft);
freq_pulse = fft(pulse_shaped_waveform, N_fft);

% Normalized frequency axis (normalized to symbol rate)
freq_axis = (-N_fft/2:N_fft/2-1) / N_fft * samples_per_symbol;

% Power spectral density (dB)
psd_rect = 20*log10(abs(fftshift(freq_rect)) + eps);
psd_pulse = 20*log10(abs(fftshift(freq_pulse)) + eps);

% Normalize to peak
psd_rect = psd_rect - max(psd_rect);
psd_pulse = psd_pulse - max(psd_pulse);

plot(freq_axis, psd_rect, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Rectangular');
hold on;
plot(freq_axis, psd_pulse, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Pulse Shaped');
grid on;
xlabel('Normalized Frequency (× Symbol Rate)', 'FontSize', 11);
ylabel('Power Spectral Density (dB)', 'FontSize', 11);
title('Frequency Domain Comparison', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'northeast');
xlim([-2, 2]);
ylim([-60, 5]);

%% 3. Eye Diagram - Real Component (I)
subplot(3, 2, 4);

% Extract segments for eye diagram (2 symbol periods each)
eye_period = 2 * samples_per_symbol;
num_eye_periods = floor(length(pulse_shaped_waveform) / eye_period);

% Real component eye diagram
for i = 1:num_eye_periods
    idx_start = (i-1) * eye_period + 1;
    idx_end = i * eye_period;
    if idx_end <= length(pulse_shaped_waveform)
        segment = real(pulse_shaped_waveform(idx_start:idx_end));
        time_eye = (0:length(segment)-1) / samples_per_symbol;
        plot(time_eye, segment, 'b-', 'LineWidth', 0.5);
        hold on;
    end
end

% Mark symbol decision points
symbol_decision_times = [0, 1, 2];
plot(symbol_decision_times, [0, 0, 0], 'ko', 'MarkerSize', 8, ...
     'MarkerFaceColor', 'k', 'DisplayName', 'Symbol Decision Points');
grid on;
xlabel('Time (Symbol Periods)', 'FontSize', 11);
ylabel('Amplitude', 'FontSize', 11);
title('Eye Diagram - In-Phase (I) Component', 'FontSize', 12, 'FontWeight', 'bold');
xlim([0, 2]);

%% 4. Eye Diagram - Imaginary Component (Q)
subplot(3, 2, 5);

% Imaginary component eye diagram
for i = 1:num_eye_periods
    idx_start = (i-1) * eye_period + 1;
    idx_end = i * eye_period;
    if idx_end <= length(pulse_shaped_waveform)
        segment = imag(pulse_shaped_waveform(idx_start:idx_end));
        time_eye = (0:length(segment)-1) / samples_per_symbol;
        plot(time_eye, segment, 'r-', 'LineWidth', 0.5);
        hold on;
    end
end

% Mark symbol decision points
plot(symbol_decision_times, [0, 0, 0], 'ko', 'MarkerSize', 8, ...
     'MarkerFaceColor', 'k', 'DisplayName', 'Symbol Decision Points');
grid on;
xlabel('Time (Symbol Periods)', 'FontSize', 11);
ylabel('Amplitude', 'FontSize', 11);
title('Eye Diagram - Quadrature (Q) Component', 'FontSize', 12, 'FontWeight', 'bold');
xlim([0, 2]);

%% 5. Constellation Diagram
subplot(3, 2, 6);
% Show original constellation points
scatter(real(tx_symbols), imag(tx_symbols), 100, 'rx', 'LineWidth', 2, ...
        'DisplayName', 'Transmitted Symbols');
hold on;
% Show pulse-shaped waveform samples at symbol instants
symbol_indices = 1:samples_per_symbol:length(pulse_shaped_waveform);
symbol_indices = symbol_indices(1:min(length(symbol_indices), num_symbols));
scatter(real(pulse_shaped_waveform(symbol_indices)), ...
        imag(pulse_shaped_waveform(symbol_indices)), 50, 'bo', ...
        'MarkerFaceColor', 'b', 'MarkerFaceAlpha', 0.6, ...
        'DisplayName', 'Pulse Shaped (at symbol instants)');
grid on;
xlabel('In-Phase (I)', 'FontSize', 11);
ylabel('Quadrature (Q)', 'FontSize', 11);
title('QPSK Constellation', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'northeast');
axis equal;

% Add overall title
annotation('textbox', [0.4, 0.97, 0.2, 0.03], ...
           'String', 'QPSK Pulse Shaping Demonstration', ...
           'FontSize', 16, 'FontWeight', 'bold', ...
           'HorizontalAlignment', 'center', ...
           'EdgeColor', 'none');

fprintf('\n=== Visualization Complete ===\n');
fprintf('Key observations:\n');
fprintf('  - Pulse shaping reduces spectral occupancy\n');
fprintf('  - Smooth transitions between symbols\n');
fprintf('  - Zero ISI at symbol sampling instants\n');
fprintf('  - Eye diagram shows clear decision regions\n');


