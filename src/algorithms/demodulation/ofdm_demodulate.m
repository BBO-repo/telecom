function freq_symbols = ofdm_demodulate(rx_signal, N, cp_length)
% OFDM_DEMODULATE OFDM demodulation (Remove CP + FFT)
%
%   FREQ_SYMBOLS = OFDM_DEMODULATE(RX_SIGNAL, N) performs OFDM demodulation.
%   N is the FFT size.
%
%   FREQ_SYMBOLS = OFDM_DEMODULATE(RX_SIGNAL, N, CP_LENGTH) specifies the
%   cyclic prefix length. Default is N/4.
%
%   Inputs:
%       rx_signal  - Received time domain signal (column vector)
%       N          - FFT size (integer)
%       cp_length  - Optional: Cyclic prefix length in samples (integer,
%                    default: N/4)
%
%   Outputs:
%       freq_symbols - Frequency domain symbols (N x num_symbols matrix)
%
%   The function performs:
%       1. Removes cyclic prefix from each OFDM symbol
%       2. FFT to convert time domain to frequency domain
%
%   Example:
%       N = 64;
%       symbols = qam_modulate(randi([0,1], 1, N*4), 16);
%       freq_sym = reshape(symbols, N, []);
%       tx = ofdm_modulate(freq_sym, 16);
%       rx_freq = ofdm_demodulate(tx, N, 16);
%
%   Author: L1 Algorithm Developer
%   Date: 2024

    if nargin < 2
        error('ofdm_demodulate: Not enough input arguments');
    end
    
    % Set default CP length
    if nargin < 3 || isempty(cp_length)
        cp_length = round(N / 4);
    end
    
    % Ensure column vector
    rx_signal = rx_signal(:);
    
    % Symbol length (with CP)
    symbol_length = N + cp_length;
    
    % Calculate number of symbols
    num_symbols = floor(length(rx_signal) / symbol_length);
    
    if num_symbols == 0
        error('ofdm_demodulate: Signal too short for at least one OFDM symbol');
    end
    
    % Truncate to complete symbols only
    rx_signal = rx_signal(1 : num_symbols * symbol_length);
    
    % Initialize output
    freq_symbols = zeros(N, num_symbols);
    
    % Process each OFDM symbol
    for i = 1:num_symbols
        % Extract symbol (with CP)
        symbol_start = (i-1) * symbol_length + 1;
        symbol_end = symbol_start + symbol_length - 1;
        symbol_with_cp = rx_signal(symbol_start : symbol_end);
        
        % Remove cyclic prefix
        symbol_no_cp = symbol_with_cp(cp_length + 1 : end);
        
        % Take FFT (frequency domain symbol)
        freq_symbols(:, i) = fft(symbol_no_cp, N);
    end
end

