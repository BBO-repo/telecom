function bits = qpsk_demodulate(symbols, energy)
% QPSK_DEMODULATE Quadrature Phase Shift Keying demodulation
%
%   BITS = QPSK_DEMODULATE(SYMBOLS) demodulates QPSK symbols to binary data.
%   Uses minimum distance decision rule.
%
%   BITS = QPSK_DEMODULATE(SYMBOLS, ENERGY) specifies the symbol energy.
%   Default energy is 1.
%
%   Inputs:
%       symbols - Received QPSK symbols (complex vector)
%       energy  - Optional: Symbol energy (scalar, default: 1)
%
%   Outputs:
%       bits    - Demodulated binary data (row vector of 0s and 1s)
%
%   Decision rule: Minimum distance to QPSK constellation points.
%   Output bits are in pairs corresponding to each symbol.
%
%   Example:
%       bits = [0, 1, 1, 0];
%       symbols = qpsk_modulate(bits);
%       rx_bits = qpsk_demodulate(symbols);
%

    if nargin < 1
        error('qpsk_demodulate: Not enough input arguments');
    end
    
    if nargin < 2
        energy = 1;
    end
    
    % Ensure column vector
    symbols = symbols(:);
    
    % Normalize symbols (reverse the energy scaling)
    symbols_norm = symbols / sqrt(energy/2);
    
    % QPSK constellation points (Gray coded)
    const_points = [1+1j, -1+1j, 1-1j, -1-1j];
    const_bits = [0, 0; 0, 1; 1, 0; 1, 1];  % Corresponding bit pairs
    
    % For each symbol, find closest constellation point
    num_symbols = length(symbols_norm);
    bits = zeros(2*num_symbols, 1);
    
    for i = 1:num_symbols
        % Calculate distances to all constellation points
        distances = abs(symbols_norm(i) - const_points);
        
        % Find minimum distance
        [~, min_idx] = min(distances);
        
        % Get corresponding bit pair
        bits(2*i-1:2*i) = const_bits(min_idx, :)';
    end
    
    % Convert to row vector
    bits = bits(:)';
end

