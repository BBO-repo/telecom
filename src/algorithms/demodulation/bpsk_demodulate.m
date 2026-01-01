function bits = bpsk_demodulate(symbols, energy)
% BPSK_DEMODULATE Binary Phase Shift Keying demodulation
%
%   BITS = BPSK_DEMODULATE(SYMBOLS) demodulates BPSK symbols to binary data.
%   Uses minimum distance decision rule.
%
%   BITS = BPSK_DEMODULATE(SYMBOLS, ENERGY) specifies the symbol energy.
%   Default energy is 1.
%
%   Inputs:
%       symbols - Received BPSK symbols (complex vector)
%       energy  - Optional: Symbol energy (scalar, default: 1)
%
%   Outputs:
%       bits    - Demodulated binary data (row vector of 0s and 1s)
%
%   Decision rule: Choose bit=0 if symbol closer to +sqrt(energy),
%                  Choose bit=1 if symbol closer to -sqrt(energy)
%
%   Example:
%       symbols = bpsk_modulate([0, 1, 0]);
%       bits = bpsk_demodulate(symbols);
%
%   Author: L1 Algorithm Developer
%   Date: 2024

    if nargin < 1
        error('bpsk_demodulate: Not enough input arguments');
    end
    
    if nargin < 2
        energy = 1;
    end
    
    % Ensure column vector
    symbols = symbols(:);
    
    % Reference symbols
    ref_0 = sqrt(energy);  % Bit 0
    ref_1 = -sqrt(energy); % Bit 1
    
    % Minimum distance decision
    % Use real part for BPSK (since it's real-valued)
    symbols_real = real(symbols);
    
    % Decision: 0 if closer to +sqrt(energy), 1 if closer to -sqrt(energy)
    bits = double(symbols_real < 0);  % 0 if positive, 1 if negative
    bits = bits(:)';  % Row vector
end

