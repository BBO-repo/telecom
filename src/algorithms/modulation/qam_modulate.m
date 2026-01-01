function symbols = qam_modulate(bits, M, energy)
% QAM_MODULATE Quadrature Amplitude Modulation
%
%   SYMBOLS = QAM_MODULATE(BITS, M) modulates binary data using M-QAM.
%   M must be a power of 2 (4, 16, 64, 256, etc.).
%
%   SYMBOLS = QAM_MODULATE(BITS, M, ENERGY) specifies the symbol energy.
%   Default energy is 1.
%
%   Inputs:
%       bits   - Binary data (vector of 0s and 1s)
%       M      - Modulation order (must be power of 2, e.g., 4, 16, 64)
%       energy - Optional: Symbol energy (scalar, default: 1)
%
%   Outputs:
%       symbols - Complex QAM symbols (column vector)
%
%   The function groups bits into symbols (log2(M) bits per symbol) and
%   maps them to a rectangular M-QAM constellation with Gray coding.
%   Symbols are normalized to have average energy 'energy'.
%
%   Example:
%       bits = randi([0, 1], 1, 32);
%       symbols = qam_modulate(bits, 16);  % 16-QAM
%
%   Author: L1 Algorithm Developer
%   Date: 2024

    if nargin < 2
        error('qam_modulate: Not enough input arguments');
    end
    
    if nargin < 3
        energy = 1;
    end
    
    % Check that M is a power of 2
    if mod(log2(M), 1) ~= 0
        error('qam_modulate: M must be a power of 2');
    end
    
    bits_per_symbol = log2(M);
    sqrt_M = sqrt(M);
    
    % Ensure bits are in row vector format
    bits = bits(:)';
    
    % Check that number of bits is a multiple of bits_per_symbol
    num_symbols = floor(length(bits) / bits_per_symbol);
    if num_symbols == 0
        error('qam_modulate: Not enough bits for at least one symbol');
    end
    
    % Take only the bits we can use
    bits = bits(1:num_symbols * bits_per_symbol);
    
    % Reshape bits into groups of bits_per_symbol
    bit_groups = reshape(bits, bits_per_symbol, [])';
    
    % Generate constellation (rectangular M-QAM)
    % Create I and Q levels: -sqrt(M)+1, -sqrt(M)+3, ..., sqrt(M)-1
    levels = -sqrt_M + 1 : 2 : sqrt_M - 1;
    
    % Convert bit groups to decimal indices
    % MSB first convention
    decimal_values = zeros(num_symbols, 1);
    for i = 1:num_symbols
        for j = 1:bits_per_symbol
            decimal_values(i) = decimal_values(i) + bit_groups(i, j) * 2^(bits_per_symbol - j);
        end
    end
    
    % Map to I and Q coordinates (Gray code mapping)
    % Split into I (MSBs) and Q (LSBs)
    bits_I = floor(decimal_values / sqrt_M);
    bits_Q = mod(decimal_values, sqrt_M);
    
    % Convert to I and Q coordinates
    I = levels(bits_I + 1);  % +1 for 1-indexing
    Q = levels(bits_Q + 1);
    
    % Create complex symbols
    symbols = (I + 1j*Q).';
    
    % Normalize to desired average energy
    % Average power of unnormalized M-QAM is 2*(M-1)/3
    current_energy = 2*(M-1)/3;
    symbols = symbols * sqrt(energy / current_energy);
    
    % Column vector
    symbols = symbols(:);
end

