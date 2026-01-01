function y = freq_offset_correct(x, freq_offset, fs)
% FREQ_OFFSET_CORRECT Correct frequency offset in signal
%
%   Y = FREQ_OFFSET_CORRECT(X, FREQ_OFFSET) corrects the frequency offset
%   in signal X by multiplying with exp(-j*2*pi*freq_offset*t).
%
%   Y = FREQ_OFFSET_CORRECT(X, FREQ_OFFSET, FS) specifies the sampling
%   frequency. Default is 1 (normalized frequency).
%
%   Inputs:
%       x            - Input signal with frequency offset (column vector)
%       freq_offset  - Frequency offset to correct in Hz (scalar)
%       fs           - Optional: Sampling frequency (scalar, default: 1)
%
%   Outputs:
%       y            - Corrected signal (column vector)
%
%   Frequency correction: y[n] = x[n] * exp(-j*2*pi*freq_offset*n/fs)
%
%   Example:
%       t = (0:999)' / 1e6;
%       x = exp(1j*2*pi*1000*t);  % Signal with 1 kHz offset
%       y = freq_offset_correct(x, 1000, 1e6);
%
%   Author: L1 Algorithm Developer
%   Date: 2024

    if nargin < 2
        error('freq_offset_correct: Not enough input arguments');
    end
    
    if nargin < 3
        fs = 1;
    end
    
    % Ensure column vector
    x = x(:);
    
    % Time indices
    n = (0 : length(x) - 1)';
    
    % Correction term
    correction = exp(-1j * 2 * pi * freq_offset * n / fs);
    
    % Apply correction
    y = x .* correction;
end

