function equalized = mmse_equalizer(rx_symbols, channel_est, snr_db)
% MMSE_EQUALIZER Minimum Mean Square Error equalizer
%
%   EQUALIZED = MMSE_EQUALIZER(RX_SYMBOLS, CHANNEL_EST, SNR_DB) performs
%   MMSE equalization in frequency domain (for OFDM).
%
%   Inputs:
%       rx_symbols   - Received symbols (vector or matrix)
%                      For OFDM: frequency domain symbols (N x num_symbols)
%       channel_est  - Channel estimate (vector or matrix, same size as rx_symbols)
%       snr_db       - Signal-to-Noise Ratio in dB (scalar)
%
%   Outputs:
%       equalized    - Equalized symbols (same size as rx_symbols)
%
%   MMSE equalization: Y_eq = Y * (H* / (|H|^2 + 1/SNR))
%   where H* is conjugate of channel estimate.
%
%   Example:
%       H_est = ones(64, 1) + 0.1*randn(64, 1);
%       rx_freq = ofdm_demodulate(rx_signal, 64);
%       eq_freq = mmse_equalizer(rx_freq, H_est, 20);
%

    if nargin < 3
        error('mmse_equalizer: Not enough input arguments');
    end
    
    % Convert SNR from dB to linear
    snr_linear = 10^(snr_db/10);
    
    % MMSE weight: H* / (|H|^2 + 1/SNR)
    H_conj = conj(channel_est);
    H_power = abs(channel_est).^2;
    mmse_weight = H_conj ./ (H_power + 1/snr_linear);
    
    % Apply MMSE equalization
    equalized = rx_symbols .* mmse_weight;
end

