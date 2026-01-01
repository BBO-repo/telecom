function bits = qam_demodulate(symbols, M, energy)
% QAM_DEMODULATE Quadrature Amplitude Modulation demodulation
%
%   BITS = QAM_DEMODULATE(SYMBOLS, M) demodulates M-QAM symbols to binary data.
%   Uses minimum distance decision rule.
%
%   BITS = QAM_DEMODULATE(SYMBOLS, M, ENERGY) specifies the symbol energy.
%   Default energy is 1.
%
%   Inputs:
%       symbols - Received QAM symbols (complex vector)
%       M       - Modulation order (must be power of 2, e.g., 4, 16, 64)
%       energy  - Optional: Symbol energy (scalar, default: 1)
%
%   Outputs:
%       bits    - Demodulated binary data (row vector of 0s and 1s)
%
%   Decision rule: Minimum distance to M-QAM constellation points.
%
%   Example:
%       bits = randi([0, 1], 1, 32);
%       symbols = qam_modulate(bits, 16);
%       rx_bits = qam_demodulate(symbols, 16);
%
%   Author: L1 Algorithm Developer
%   Date: 2024

    if nargin < 2
        error('qam_demodulate: Not enough input arguments');
    end
    
    if nargin < 3
        energy = 1;
    end
    
    % Check that M is a power of 2
    if mod(log2(M), 1) ~= 0
        error('qam_demodulate: M must be a power of 2');
    end
    
    bits_per_symbol = log2(M);
    sqrt_M = sqrt(M);
    
    % Ensure column vector
    symbols = symbols(:);
    
    % Normalize symbols (reverse the energy scaling)
    % Average power of unnormalized M-QAM is 2*(M-1)/3
    current_energy = 2*(M-1)/3;
    symbols_norm = symbols / sqrt(energy / current_energy);
    
    % Generate constellation levels
    levels = -sqrt_M + 1 : 2 : sqrt_M - 1;
    
    % Quantize I and Q to nearest levels
    I_quantized = zeros(length(symbols), 1);
    Q_quantized = zeros(length(symbols), 1);
    
    for i = 1:length(symbols)
        [~, I_idx] = min(abs(real(symbols_norm(i)) - levels));
        [~, Q_idx] = min(abs(imag(symbols_norm(i)) - levels));
        I_quantized(i) = levels(I_idx);
        Q_quantized(i) = levels(Q_idx);
    end
    
    % Convert I and Q indices back to bit groups
    bits = zeros(length(symbols) * bits_per_symbol, 1);
    
    for i = 1:length(symbols)
        % Find indices in constellation
        I_idx = find(levels == I_quantized(i)) - 1;  % 0-indexed
        Q_idx = find(levels == Q_quantized(i)) - 1;  % 0-indexed
        
        % Combine to get decimal value
        decimal_value = I_idx * sqrt_M + Q_idx;
        
        % Convert to binary (MSB first)
        bit_start = (i-1)*bits_per_symbol + 1;
        for j = 1:bits_per_symbol
            bits(bit_start + j - 1) = mod(floor(decimal_value / 2^(bits_per_symbol - j)), 2);
        end
    end
    
    % Convert to row vector
    bits = bits(:)';
end

