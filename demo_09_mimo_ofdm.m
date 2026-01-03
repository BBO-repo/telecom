%% Demo 9: MIMO-OFDM System
%
% This script demonstrates a MIMO-OFDM system with spatial multiplexing:
%   - Multiple transmit and receive antennas (MIMO)
%   - OFDM modulation per antenna
%   - MIMO channel matrix (Rayleigh fading)
%   - Channel estimation using pilot symbols
%   - MIMO detection (Zero-Forcing and MMSE)
%   - Spatial multiplexing gain
%   - BER comparison at fixed SNR (SISO vs MIMO)
%
% MIMO Configuration:
%   - Nt transmit antennas
%   - Nr receive antennas
%   - Spatial multiplexing: Nt independent data streams
%   - Channel: H (Nr x Nt) matrix per subcarrier
%

clear all;
clc;

%% Configuration Parameters
N = 64;                        % FFT size (number of subcarriers)
cp_length = 16;                % Cyclic prefix length
M = 16;                        % 16-QAM modulation
num_ofdm_symbols = 50;         % Number of OFDM symbols
pilot_spacing = 4;             % Pilot spacing (every Nth subcarrier)

% MIMO Configuration
Nt = 4;                        % Number of transmit antennas
Nr = 4;                        % Number of receive antennas

% Simulation parameters
snr_db = -10;                  % SNR in dB
num_trials = 5;                % Trials for averaging over channel realizations

% Add paths
addpath('./utils');
addpath('./algorithms/modulation');
addpath('./algorithms/demodulation');
addpath('./algorithms/channel');
addpath('./algorithms/equalization');

fprintf('=== Demo 9: MIMO-OFDM System ===\n');
fprintf('FFT size: %d (number of subcarriers)\n', N);
fprintf('CP length: %d\n', cp_length);
fprintf('Modulation: %d-QAM\n', M);
fprintf('MIMO: %dx%d (Tx x Rx)\n', Nt, Nr);
fprintf('Number of OFDM symbols: %d\n', num_ofdm_symbols);
fprintf('Pilot spacing: %d\n', pilot_spacing);
fprintf('SNR: %d dB\n', snr_db);

%% Generate pilot positions
pilot_indices = 1:pilot_spacing:N;  % Equally spaced pilots
num_pilots = length(pilot_indices);
data_indices = setdiff(1:N, pilot_indices);
num_data = length(data_indices);

fprintf('\nRunning simulation...\n');

%% Main Simulation Loop
errors_mimo_zf = 0;
errors_mimo_mmse = 0;
errors_siso = 0;
total_bits_mimo = 0;
total_bits_siso = 0;

for trial = 1:num_trials
        %% Transmitter - MIMO
        % Generate random data bits for each transmit antenna
        bits_per_data_symbol = log2(M) * num_data;
        tx_bits_mimo = cell(Nt, 1);
        for tx_ant = 1:Nt
            tx_bits_mimo{tx_ant} = generate_data(num_ofdm_symbols * bits_per_data_symbol);
        end

        % QAM modulation for each antenna
        tx_qam_data_mimo = cell(Nt, 1);
        for tx_ant = 1:Nt
            tx_qam_data_mimo{tx_ant} = qam_modulate(tx_bits_mimo{tx_ant}, M);
        end

        % Create OFDM symbols with pilots for each antenna
        freq_symbols_mimo = zeros(N, num_ofdm_symbols, Nt);
        for tx_ant = 1:Nt
            for sym_idx = 1:num_ofdm_symbols
                % Data symbols
                data_start = (sym_idx - 1) * num_data + 1;
                data_end = sym_idx * num_data;
                freq_symbols_mimo(data_indices, sym_idx, tx_ant) = ...
                    tx_qam_data_mimo{tx_ant}(data_start:data_end);

                % Pilot symbols (known: BPSK, alternating)
                pilot_values = (1 - 2*mod(sym_idx, 2)) * ones(num_pilots, 1);
                freq_symbols_mimo(pilot_indices, sym_idx, tx_ant) = pilot_values;
            end
        end

        % OFDM modulation for each transmit antenna
        tx_signal_mimo = zeros(length(ofdm_modulate(freq_symbols_mimo(:, 1, 1), cp_length)) * num_ofdm_symbols, Nt);
        for tx_ant = 1:Nt
            tx_signal_mimo(:, tx_ant) = ofdm_modulate(freq_symbols_mimo(:, :, tx_ant), cp_length);
        end

        %% Channel - MIMO
        % Generate MIMO channel matrix for each subcarrier
        % H[k] is Nr x Nt matrix for subcarrier k
        % Each element is independent Rayleigh fading
        H_freq = zeros(Nr, Nt, N);
        for k = 1:N
            % Rayleigh fading: complex Gaussian with variance 0.5 per dimension
            H_freq(:, :, k) = sqrt(0.5) * (randn(Nr, Nt) + 1j*randn(Nr, Nt));
        end

        % Apply MIMO channel in frequency domain (per subcarrier)
        % For each OFDM symbol and subcarrier: y = H*x + n
        rx_freq_symbols_mimo = zeros(Nr, N, num_ofdm_symbols);
        for sym_idx = 1:num_ofdm_symbols
            for k = 1:N
                % Transmit vector (Nt x 1)
                x_k = squeeze(freq_symbols_mimo(k, sym_idx, :));

                % MIMO channel: y = H*x
                y_k = H_freq(:, :, k) * x_k;

                % Add AWGN (per receive antenna)
                noise_power = 10^(-snr_db/10);
                noise = sqrt(noise_power/2) * (randn(Nr, 1) + 1j*randn(Nr, 1));
                y_k = y_k + noise;

                rx_freq_symbols_mimo(:, k, sym_idx) = y_k;
            end
        end

        %% Receiver - MIMO Detection
        % Channel estimation using pilots
        H_est = zeros(Nr, Nt, N);
        for k = 1:N
            if ismember(k, pilot_indices)
                % Extract pilots at this subcarrier
                rx_pilots_k = squeeze(rx_freq_symbols_mimo(:, k, :));  % Nr x num_symbols
                tx_pilots_k = squeeze(freq_symbols_mimo(k, :, :)).';    % Nt x num_symbols

                % LS channel estimation: H = Y * X^H * (X * X^H)^(-1)
                % For each receive antenna
                H_pilot_k = zeros(Nr, Nt);
                for rx_ant = 1:Nr
                    % Y is 1 x num_symbols, X is Nt x num_symbols
                    Y = rx_pilots_k(rx_ant, :);
                    X = tx_pilots_k;

                    % H = Y * X^H * (X * X^H)^(-1)
                    XXH = X * X';
                    if cond(XXH) < 1e10  % Check condition number
                        H_pilot_k(rx_ant, :) = (Y * X') / (XXH + 1e-10*eye(Nt));
                    else
                        % Fallback to simple division if ill-conditioned
                        H_pilot_k(rx_ant, :) = (Y * X') / (trace(XXH) + 1e-10);
                    end
                end
                H_est(:, :, k) = H_pilot_k;
            else
                % Interpolate from nearest pilots
                [~, nearest_pilot_idx] = min(abs(pilot_indices - k));
                nearest_pilot = pilot_indices(nearest_pilot_idx);
                H_est(:, :, k) = H_est(:, :, nearest_pilot);
            end
        end

        % MIMO Detection (per subcarrier, per symbol)
        % Extract data symbols
        rx_data_mimo_zf = zeros(Nt, num_data, num_ofdm_symbols);
        rx_data_mimo_mmse = zeros(Nt, num_data, num_ofdm_symbols);

        for sym_idx = 1:num_ofdm_symbols
            for data_idx = 1:num_data
                k = data_indices(data_idx);

                % Received signal at this subcarrier
                y_k = squeeze(rx_freq_symbols_mimo(:, k, sym_idx));

                % Channel matrix at this subcarrier
                H_k = H_est(:, :, k);

                % Zero-Forcing detection: x_hat = (H^H * H)^(-1) * H^H * y
                HHH = H_k' * H_k;
                if cond(HHH) < 1e10
                    W_zf = (HHH + 1e-10*eye(Nt)) \ H_k';
                    x_hat_zf = W_zf * y_k;
                else
                    % Fallback
                    x_hat_zf = pinv(H_k) * y_k;
                end
                rx_data_mimo_zf(:, data_idx, sym_idx) = x_hat_zf;

                % MMSE detection: x_hat = (H^H * H + (1/SNR)*I)^(-1) * H^H * y
                snr_linear = 10^(snr_db/10);
                HHH_mmse = H_k' * H_k + (1/snr_linear) * eye(Nt);
                if cond(HHH_mmse) < 1e10
                    W_mmse = (HHH_mmse + 1e-10*eye(Nt)) \ H_k';
                    x_hat_mmse = W_mmse * y_k;
                else
                    % Fallback
                    x_hat_mmse = pinv(H_k) * y_k;
                end
                rx_data_mimo_mmse(:, data_idx, sym_idx) = x_hat_mmse;
            end
        end

        % Demodulation for each antenna
        rx_bits_mimo_zf = cell(Nt, 1);
        rx_bits_mimo_mmse = cell(Nt, 1);
        for tx_ant = 1:Nt
            rx_data_vec_zf = squeeze(rx_data_mimo_zf(tx_ant, :, :));
            rx_data_vec_zf = rx_data_vec_zf(:);
            rx_bits_mimo_zf{tx_ant} = qam_demodulate(rx_data_vec_zf, M);

            rx_data_vec_mmse = squeeze(rx_data_mimo_mmse(tx_ant, :, :));
            rx_data_vec_mmse = rx_data_vec_mmse(:);
            rx_bits_mimo_mmse{tx_ant} = qam_demodulate(rx_data_vec_mmse, M);
        end

        % Calculate errors for MIMO
        for tx_ant = 1:Nt
            min_len = min(length(tx_bits_mimo{tx_ant}), length(rx_bits_mimo_zf{tx_ant}));
            errors_mimo_zf = errors_mimo_zf + sum(tx_bits_mimo{tx_ant}(1:min_len) ~= ...
                rx_bits_mimo_zf{tx_ant}(1:min_len));

            min_len = min(length(tx_bits_mimo{tx_ant}), length(rx_bits_mimo_mmse{tx_ant}));
            errors_mimo_mmse = errors_mimo_mmse + sum(tx_bits_mimo{tx_ant}(1:min_len) ~= ...
                rx_bits_mimo_mmse{tx_ant}(1:min_len));

            total_bits_mimo = total_bits_mimo + min_len;
        end

        %% SISO comparison (single antenna)
        tx_bits_siso = generate_data(num_ofdm_symbols * bits_per_data_symbol);
        tx_qam_data_siso = qam_modulate(tx_bits_siso, M);

        freq_symbols_siso = zeros(N, num_ofdm_symbols);
        for sym_idx = 1:num_ofdm_symbols
            data_start = (sym_idx - 1) * num_data + 1;
            data_end = sym_idx * num_data;
            freq_symbols_siso(data_indices, sym_idx) = tx_qam_data_siso(data_start:data_end);

            pilot_values = (1 - 2*mod(sym_idx, 2)) * ones(num_pilots, 1);
            freq_symbols_siso(pilot_indices, sym_idx) = pilot_values;
        end

        tx_signal_siso = ofdm_modulate(freq_symbols_siso, cp_length);

        % SISO channel (single tap from first transmit to first receive)
        H_siso_freq = H_freq(1, 1, :);
        rx_freq_symbols_siso = zeros(N, num_ofdm_symbols);
        for sym_idx = 1:num_ofdm_symbols
            for k = 1:N
                x_k = freq_symbols_siso(k, sym_idx);
                y_k = H_siso_freq(k) * x_k;
                noise_power = 10^(-snr_db/10);
                noise = sqrt(noise_power/2) * (randn + 1j*randn);
                rx_freq_symbols_siso(k, sym_idx) = y_k + noise;
            end
        end

        % Channel estimation and equalization for SISO
        H_est_siso = zeros(N, 1);
        for k = 1:N
            if ismember(k, pilot_indices)
                rx_pilots_k = rx_freq_symbols_siso(k, :);
                tx_pilots_k = freq_symbols_siso(k, :);
                H_est_siso(k) = mean(rx_pilots_k ./ tx_pilots_k);
            else
                [~, nearest_pilot_idx] = min(abs(pilot_indices - k));
                nearest_pilot = pilot_indices(nearest_pilot_idx);
                H_est_siso(k) = H_est_siso(nearest_pilot);
            end
        end

        % Equalize SISO
        rx_data_siso = zeros(num_data, num_ofdm_symbols);
        for sym_idx = 1:num_ofdm_symbols
            for data_idx = 1:num_data
                k = data_indices(data_idx);
                y_k = rx_freq_symbols_siso(k, sym_idx);
                H_k = H_est_siso(k);
                rx_data_siso(data_idx, sym_idx) = y_k / (H_k + 1e-10);
            end
        end

        rx_bits_siso = qam_demodulate(rx_data_siso(:), M);
        min_len = min(length(tx_bits_siso), length(rx_bits_siso));
        errors_siso = errors_siso + sum(tx_bits_siso(1:min_len) ~= rx_bits_siso(1:min_len));
        total_bits_siso = total_bits_siso + min_len;
    end

% Calculate BER
ber_mimo_zf = errors_mimo_zf / total_bits_mimo;
ber_mimo_mmse = errors_mimo_mmse / total_bits_mimo;
ber_siso = errors_siso / total_bits_siso;

fprintf('\nSNR = %d dB: MIMO-ZF BER = %.2e, MIMO-MMSE BER = %.2e, SISO BER = %.2e\n', ...
        snr_db, ber_mimo_zf, ber_mimo_mmse, ber_siso);

fprintf('\n=== Simulation Complete ===\n');
fprintf('BER at %d dB SNR:\n', snr_db);
fprintf('  MIMO-ZF:   %.2e\n', ber_mimo_zf);
fprintf('  MIMO-MMSE: %.2e\n', ber_mimo_mmse);
fprintf('  SISO:      %.2e\n', ber_siso);

