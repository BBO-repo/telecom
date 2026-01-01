function [timing_metric, freq_offset_frac] = ofdm_sync_schmidl_cox(rx_signal, N)
% OFDM_SYNC_SCHMIDL_COX Schmidl-Cox OFDM synchronization
%
%   [TIMING_METRIC, FREQ_OFFSET_FRAC] = OFDM_SYNC_SCHMIDL_COX(RX_SIGNAL, N)
%   performs Schmidl-Cox synchronization for OFDM signals.
%
%   Inputs:
%       rx_signal - Received OFDM signal (column vector)
%       N         - FFT size (integer)
%
%   Outputs:
%       timing_metric    - Timing metric (used to find symbol start)
%       freq_offset_frac - Fractional frequency offset estimate
%
%   The Schmidl-Cox algorithm uses a training symbol with two identical
%   halves to estimate timing and fractional frequency offset.
%
%   Example:
%       N = 64;
%       training = [randn(N/2,1); randn(N/2,1)];  % Two identical halves
%       rx = [zeros(100,1); training];
%       [metric, foff] = ofdm_sync_schmidl_cox(rx, N);
%
%   Reference: Schmidl & Cox, "Robust Frequency and Timing Synchronization
%              for OFDM", IEEE Trans. Comm., 1997
%

    if nargin < 2
        error('ofdm_sync_schmidl_cox: Not enough input arguments');
    end
    
    % Ensure column vector
    rx_signal = rx_signal(:);
    
    % Length for correlation (half of training symbol length)
    L = N / 2;
    
    % Need at least 2*L samples
    if length(rx_signal) < 2*L
        error('ofdm_sync_schmidl_cox: Signal too short');
    end
    
    % Initialize timing metric
    num_windows = length(rx_signal) - 2*L + 1;
    timing_metric = zeros(num_windows, 1);
    
    % Compute correlation P(d) and energy R(d)
    for d = 1:num_windows
        % Correlation: P(d) = sum(r*[d+k] * conj(r[d+k+L]))
        P = 0;
        for k = 0:L-1
            P = P + rx_signal(d + k) * conj(rx_signal(d + k + L));
        end
        
        % Energy: R(d) = sum(|r[d+k+L]|^2)
        R = sum(abs(rx_signal(d + L : d + 2*L - 1)).^2);
        
        % Timing metric: M(d) = |P(d)|^2 / R(d)^2
        timing_metric(d) = abs(P)^2 / (R^2 + eps);
    end
    
    % Find peak (symbol timing)
    [~, timing_idx] = max(timing_metric);
    
    % Estimate fractional frequency offset from peak position
    % f_frac = angle(P(d)) / (2*pi*L)
    P_peak = 0;
    for k = 0:L-1
        P_peak = P_peak + rx_signal(timing_idx + k) * conj(rx_signal(timing_idx + k + L));
    end
    freq_offset_frac = -angle(P_peak) / (2 * pi * L);
end

