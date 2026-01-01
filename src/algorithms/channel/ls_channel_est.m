function H_est = ls_channel_est(rx_pilots, tx_pilots)
% LS_CHANNEL_EST Least Squares channel estimation
%
%   H_EST = LS_CHANNEL_EST(RX_PILOTS, TX_PILOTS) performs least squares
%   channel estimation using known pilot symbols.
%
%   Inputs:
%       rx_pilots - Received pilot symbols (vector or matrix)
%                   For OFDM: frequency domain pilots (N x num_symbols or vector)
%       tx_pilots - Transmitted pilot symbols (known, same size as rx_pilots)
%
%   Outputs:
%       H_est     - Channel estimate (same size as inputs)
%
%   LS estimation: H = Y / X, where Y is received and X is transmitted.
%   This is the simplest channel estimation method.
%
%   Example:
%       H_true = 0.9 + 0.1*randn(64, 1);
%       tx_pilots = ones(64, 1);
%       rx_pilots = H_true .* tx_pilots + 0.01*randn(64, 1);
%       H_est = ls_channel_est(rx_pilots, tx_pilots);
%
%   Author: L1 Algorithm Developer
%   Date: 2024

    if nargin < 2
        error('ls_channel_est: Not enough input arguments');
    end
    
    % Avoid division by zero
    epsilon = 1e-10;
    
    % Least squares: H = Y / X
    H_est = rx_pilots ./ (tx_pilots + epsilon);
end

