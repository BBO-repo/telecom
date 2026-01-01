function [frame_start, correlation] = timing_sync(rx_signal, preamble, threshold)
% TIMING_SYNC Timing synchronization using correlation
%
%   [FRAME_START, CORRELATION] = TIMING_SYNC(RX_SIGNAL, PREAMBLE) finds
%   the frame start position by correlating the received signal with a
%   known preamble.
%
%   [FRAME_START, CORRELATION] = TIMING_SYNC(RX_SIGNAL, PREAMBLE, THRESHOLD)
%   uses a threshold to detect the preamble. If not provided, uses maximum
%   correlation position.
%
%   Inputs:
%       rx_signal  - Received signal (column vector)
%       preamble   - Known preamble sequence (column vector)
%       threshold  - Optional: Correlation threshold (scalar, default: use maximum)
%
%   Outputs:
%       frame_start - Estimated frame start position (integer, 1-indexed)
%       correlation - Correlation values (column vector)
%
%   The function computes cross-correlation between received signal and
%   preamble to find the frame start position.
%
%   Example:
%       preamble = qpsk_modulate([1, 0, 1, 0, 1, 0, 1, 0]);
%       rx = [zeros(100,1); preamble; data];
%       [start, corr] = timing_sync(rx, preamble);
%

    if nargin < 2
        error('timing_sync: Not enough input arguments');
    end
    
    % Ensure column vectors
    rx_signal = rx_signal(:);
    preamble = preamble(:);
    
    % Compute cross-correlation
    correlation = zeros(length(rx_signal) - length(preamble) + 1, 1);
    
    for i = 1:length(correlation)
        % Extract window
        window = rx_signal(i : i + length(preamble) - 1);
        
        % Compute correlation (normalized)
        correlation(i) = abs(sum(conj(window) .* preamble)) / (norm(window) * norm(preamble) + eps);
    end
    
    % Find frame start
    if nargin >= 3 && ~isempty(threshold)
        % Use threshold
        candidates = find(correlation >= threshold);
        if ~isempty(candidates)
            frame_start = candidates(1);
        else
            [~, frame_start] = max(correlation);
        end
    else
        % Use maximum correlation
        [~, frame_start] = max(correlation);
    end
end

