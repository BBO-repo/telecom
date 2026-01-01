function symbols = bpsk_modulate(bits, energy)
% BPSK_MODULATE Binary Phase Shift Keying modulation
%
%   SYMBOLS = BPSK_MODULATE(BITS) modulates binary data using BPSK.
%   Maps: 0 -> +sqrt(energy), 1 -> -sqrt(energy)
%
%   SYMBOLS = BPSK_MODULATE(BITS, ENERGY) specifies the symbol energy.
%   Default energy is 1.
%
%   Inputs:
%       bits   - Binary data (vector of 0s and 1s)
%       energy - Optional: Symbol energy (scalar, default: 1)
%
%   Outputs:
%       symbols - Complex BPSK symbols (column vector)
%
%   BPSK mapping: bit=0 -> +sqrt(energy), bit=1 -> -sqrt(energy)
%   Note: BPSK is real-valued, but output is complex for compatibility.
%
%   Example:
%       bits = [0, 1, 0, 1, 1];
%       symbols = bpsk_modulate(bits);
%

    if nargin < 1
        error('bpsk_modulate: Not enough input arguments');
    end
    
    if nargin < 2
        energy = 1;
    end
    
    % Ensure bits are in row vector format
    bits = bits(:)';
    
    % BPSK mapping: 0 -> +sqrt(energy), 1 -> -sqrt(energy)
    % Convert to column vector of complex symbols
    symbols = sqrt(energy) * (1 - 2*double(bits));
    symbols = symbols(:);  % Column vector
end

