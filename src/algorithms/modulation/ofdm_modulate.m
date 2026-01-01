function tx_signal = ofdm_modulate(freq_symbols, cp_length)
% OFDM_MODULATE OFDM modulation (IFFT + Cyclic Prefix)
%
%   TX_SIGNAL = OFDM_MODULATE(FREQ_SYMBOLS) performs OFDM modulation.
%   FREQ_SYMBOLS should be a column vector or matrix where each column
%   is an OFDM symbol.
%
%   TX_SIGNAL = OFDM_MODULATE(FREQ_SYMBOLS, CP_LENGTH) specifies the
%   cyclic prefix length. Default is N/4 where N is FFT size.
%
%   Inputs:
%       freq_symbols - Frequency domain symbols (N x num_symbols matrix,
%                      where N is FFT size)
%       cp_length    - Optional: Cyclic prefix length in samples (integer,
%                      default: N/4)
%
%   Outputs:
%       tx_signal    - Time domain OFDM signal (column vector)
%
%   The function performs:
%       1. IFFT to convert frequency domain to time domain
%       2. Adds cyclic prefix to each OFDM symbol
%       3. Concatenates all symbols
%
%   Example:
%       N = 64;
%       symbols = qam_modulate(randi([0,1], 1, N*4), 16);  % 16-QAM
%       freq_sym = reshape(symbols, N, []);
%       tx = ofdm_modulate(freq_sym, 16);
%
%   Author: L1 Algorithm Developer
%   Date: 2024

    if nargin < 1
        error('ofdm_modulate: Not enough input arguments');
    end
    
    % Get dimensions
    [N, num_symbols] = size(freq_symbols);
    
    % Set default CP length
    if nargin < 2 || isempty(cp_length)
        cp_length = round(N / 4);
    end
    
    % Initialize output
    tx_signal = [];
    
    % Process each OFDM symbol
    for i = 1:num_symbols
        % Take IFFT (time domain symbol)
        time_symbol = ifft(freq_symbols(:, i), N);
        
        % Add cyclic prefix
        cp = time_symbol(end - cp_length + 1 : end);
        ofdm_symbol = [cp; time_symbol];
        
        % Concatenate
        tx_signal = [tx_signal; ofdm_symbol];
    end
end

