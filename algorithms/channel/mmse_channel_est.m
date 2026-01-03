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
    
    % If correlation matrix provided, apply correlation-based MMSE smoothing
    if nargin >= 4 && ~isempty(R_hh)
        % Get dimensions
        [N_pilots, N_symbols] = size(rx_pilots);
        
        % Ensure R_hh is the correct size
        if size(R_hh, 1) ~= N_pilots || size(R_hh, 2) ~= N_pilots
            error('mmse_channel_est: R_hh must be N_pilots x N_pilots matrix');
        end
        
        % Compute LS estimate first: H_LS = Y / X
        epsilon = 1e-10;
        H_ls = rx_pilots ./ (tx_pilots + epsilon);
        
        % Process each symbol (column) separately
        H_est = zeros(size(H_ls));
        for sym_idx = 1:N_symbols
            % Extract LS estimate for this symbol
            H_ls_sym = H_ls(:, sym_idx);
            tx_pilots_sym = tx_pilots(:, sym_idx);
            
            % Compute diagonal matrix: diag(1/|X|^2)
            X_power_inv = 1 ./ (abs(tx_pilots_sym).^2 + epsilon);
            D_inv = diag(X_power_inv);
            
            % MMSE with correlation: H_MMSE = R_hh * (R_hh + sigma_n^2 * D_inv)^(-1) * H_LS
            % This accounts for both noise and channel correlation
            R_mmse = R_hh + sigma_n_sq * D_inv;
            H_est(:, sym_idx) = R_hh * (R_mmse \ H_ls_sym);
        end
    end
end

