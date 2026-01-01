function ber = calculate_ber(tx_bits, rx_bits)
% CALCULATE_BER Calculate Bit Error Rate
%
%   BER = CALCULATE_BER(TX_BITS, RX_BITS) calculates the Bit Error Rate
%   by comparing transmitted bits TX_BITS with received bits RX_BITS.
%
%   Inputs:
%       tx_bits - Transmitted binary data (vector of 0s and 1s)
%       rx_bits - Received binary data (vector of 0s and 1s, same length as tx_bits)
%
%   Outputs:
%       ber     - Bit Error Rate (scalar between 0 and 1)
%
%   BER is calculated as: BER = (number of bit errors) / (total number of bits)
%
%   Example:
%       tx_bits = [1, 0, 1, 1, 0];
%       rx_bits = [1, 1, 1, 1, 0];
%       ber = calculate_ber(tx_bits, rx_bits);  % Returns 0.2 (1 error out of 5)
%

    if nargin < 2
        error('calculate_ber: Not enough input arguments');
    end
    
    % Ensure both are row vectors for comparison
    tx_bits = tx_bits(:)';
    rx_bits = rx_bits(:)';
    
    if length(tx_bits) ~= length(rx_bits)
        error('calculate_ber: tx_bits and rx_bits must have the same length');
    end
    
    % Calculate number of bit errors
    num_errors = sum(tx_bits ~= rx_bits);
    
    % Calculate BER
    ber = num_errors / length(tx_bits);
end

