function freq_offset = freq_offset_estimate(rx_signal, preamble_length, fs)
% FREQ_OFFSET_ESTIMATE Estimate frequency offset using FFT
%
%   FREQ_OFFSET = FREQ_OFFSET_ESTIMATE(RX_SIGNAL, PREAMBLE_LENGTH) estimates
%   the carrier frequency offset from a received signal containing a
%   repetitive preamble.
%
%   FREQ_OFFSET = FREQ_OFFSET_ESTIMATE(RX_SIGNAL, PREAMBLE_LENGTH, FS)
%   specifies the sampling frequency. Default is 1 (normalized frequency).
%
%   Inputs:
%       rx_signal     - Received signal (column vector)
%       preamble_length - Length of one preamble period (integer)
%       fs            - Optional: Sampling frequency (scalar, default: 1)
%
%   Outputs:
%       freq_offset   - Estimated frequency offset in Hz (scalar)
%
%   The method uses the phase difference between two identical preamble
%   periods to estimate frequency offset.
%
%   Example:
%       preamble = repmat([1; -1], 32, 1);
%       tx = [preamble; preamble; data];
%       rx = tx .* exp(1j*2*pi*0.01*(0:length(tx)-1)');  % Add freq offset
%       offset = freq_offset_estimate(rx, length(preamble));
%
%   Author: L1 Algorithm Developer
%   Date: 2024

    if nargin < 2
        error('freq_offset_estimate: Not enough input arguments');
    end
    
    if nargin < 3
        fs = 1;
    end
    
    % Ensure column vector
    rx_signal = rx_signal(:);
    
    % Need at least two periods
    if length(rx_signal) < 2 * preamble_length
        error('freq_offset_estimate: Signal too short for estimation');
    end
    
    % Extract two consecutive preamble periods
    preamble1 = rx_signal(1 : preamble_length);
    preamble2 = rx_signal(preamble_length + 1 : 2 * preamble_length);
    
    % Compute phase difference using correlation
    % Phase difference = angle(sum(conj(preamble1) .* preamble2))
    correlation = sum(conj(preamble1) .* preamble2);
    phase_diff = angle(correlation);
    
    % Frequency offset: delta_f = phase_diff / (2*pi*T)
    % where T = preamble_length / fs
    T = preamble_length / fs;
    freq_offset = phase_diff / (2 * pi * T);
end

