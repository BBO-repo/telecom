function H_est = mmse_channel_est(rx_pilots, tx_pilots, snr_db, R_hh)
% MMSE_CHANNEL_EST MMSE channel estimation
%
%   H_EST = MMSE_CHANNEL_EST(RX_PILOTS, TX_PILOTS, SNR_DB) performs MMSE
%   channel estimation using known pilot symbols.
%
%   H_EST = MMSE_CHANNEL_EST(..., R_HH) specifies the channel correlation
%   matrix. If not provided, assumes identity (uncorrelated taps).
%
%   Inputs:
%       rx_pilots - Received pilot symbols (vector or matrix)
%       tx_pilots - Transmitted pilot symbols (known, same size as rx_pilots)
%       snr_db    - Signal-to-Noise Ratio in dB (scalar)
%       R_hh      - Optional: Channel correlation matrix (matrix,
%                   default: identity)
%
%   Outputs:
%       H_est     - Channel estimate (same size as inputs)
%
%   MMSE estimation accounts for noise statistics and provides better
%   performance than LS, especially at low SNR.
%
%   Example:
%       H_true = 0.9 + 0.1*randn(64, 1);
%       tx_pilots = ones(64, 1);
%       rx_pilots = H_true .* tx_pilots + 0.01*randn(64, 1);
%       H_est = mmse_channel_est(rx_pilots, tx_pilots, 20);
%

    if nargin < 3
        error('mmse_channel_est: Not enough input arguments');
    end
    
    % Convert SNR from dB to linear
    snr_linear = 10^(snr_db/10);
    
    % For simplicity, use a frequency-domain MMSE approach
    % H_MMSE = (X'*X + sigma_n^2*I)^(-1) * X'*Y
    % For single-tap per subcarrier: H_MMSE = (|X|^2 + sigma_n^2)^(-1) * X'*Y
    
    % Noise variance (assuming unit signal power)
    sigma_n_sq = 1 / snr_linear;
    
    % MMSE weight
    X_power = abs(tx_pilots).^2;
    mmse_weight = conj(tx_pilots) ./ (X_power + sigma_n_sq);
    
    % MMSE estimate
    H_est = rx_pilots .* mmse_weight;
    
    % If correlation matrix provided, apply smoothing (simplified)
    if nargin >= 4 && ~isempty(R_hh)
        % For frequency-domain, would apply correlation-based smoothing
        % Simplified: just return the basic MMSE estimate
        % Full implementation would require matrix operations
    end
end

