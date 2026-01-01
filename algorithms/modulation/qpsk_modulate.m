function symbols = qpsk_modulate(bits, energy)
% QPSK_MODULATE Quadrature Phase Shift Keying modulation
%
%   SYMBOLS = QPSK_MODULATE(BITS) modulates binary data using QPSK.
%   Groups bits into pairs and maps to complex symbols.
%
%   SYMBOLS = QPSK_MODULATE(BITS, ENERGY) specifies the symbol energy.
%   Default energy is 1.
%
%   Inputs:
%       bits   - Binary data (vector of 0s and 1s, length must be even)
%       energy - Optional: Symbol energy (scalar, default: 1)
%
%   Outputs:
%       symbols - Complex QPSK symbols (column vector)
%
%   QPSK mapping (Gray coded):
%       00 -> +1+1j  (π/4)
%       01 -> -1+1j  (3π/4)
%       10 -> +1-1j  (-π/4)
%       11 -> -1-1j  (-3π/4)
%   Symbols are normalized to have energy 'energy'.
%
%   Example:
%       bits = [0, 1, 1, 0, 1, 1];
%       symbols = qpsk_modulate(bits);
%

    if nargin < 1
        error('qpsk_modulate: Not enough input arguments');
    end
    
    if nargin < 2
        energy = 1;
    end
    
    % Ensure bits are in row vector format
    bits = bits(:)';
    
    % Check that number of bits is even
    if mod(length(bits), 2) ~= 0
        error('qpsk_modulate: Number of bits must be even');
    end
    
    % Reshape bits into pairs
    bit_pairs = reshape(bits, 2, [])';
    
    % QPSK mapping (Gray code)
    % Each pair [b0, b1] maps to I+jQ where:
    % I = 1 - 2*b0, Q = 1 - 2*b1
    I = 1 - 2*bit_pairs(:, 1);
    Q = 1 - 2*bit_pairs(:, 2);
    
    % Create complex symbols
    symbols = (I + 1j*Q);
    
    % Normalize to desired energy (average power should be 'energy')
    % For QPSK with ±1±j, average power is 2, so scale by sqrt(energy/2)
    symbols = symbols * sqrt(energy/2);
    
    % Column vector
    symbols = symbols(:);
end

