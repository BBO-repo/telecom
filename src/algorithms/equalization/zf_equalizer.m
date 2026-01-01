function equalized = zf_equalizer(rx_symbols, channel_est)
% ZF_EQUALIZER Zero-Forcing equalizer
%
%   EQUALIZED = ZF_EQUALIZER(RX_SYMBOLS, CHANNEL_EST) performs zero-forcing
%   equalization in frequency domain (for OFDM) or time domain.
%
%   Inputs:
%       rx_symbols   - Received symbols (vector or matrix)
%                      For OFDM: frequency domain symbols (N x num_symbols)
%                      For SC: time domain symbols (vector)
%       channel_est  - Channel estimate (vector or matrix, same size as rx_symbols)
%
%   Outputs:
%       equalized    - Equalized symbols (same size as rx_symbols)
%
%   ZF equalization: Y_eq = Y / H = Y * (1/H)
%   where Y is received signal and H is channel frequency response.
%
%   Example:
%       % OFDM case
%       H_est = ones(64, 1) + 0.1*randn(64, 1);
%       rx_freq = ofdm_demodulate(rx_signal, 64);
%       eq_freq = zf_equalizer(rx_freq, H_est);
%

    if nargin < 2
        error('zf_equalizer: Not enough input arguments');
    end
    
    % Avoid division by zero (regularized ZF)
    epsilon = 1e-10;
    
    % Zero-forcing: divide by channel estimate
    % Add small regularization to avoid division by near-zero values
    equalized = rx_symbols ./ (channel_est + epsilon);
end

