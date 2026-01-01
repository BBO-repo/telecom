function evm_db = calculate_evm(received_symbols, ideal_symbols)
% CALCULATE_EVM Calculate Error Vector Magnitude
%
%   EVM_DB = CALCULATE_EVM(RECEIVED_SYMBOLS, IDEAL_SYMBOLS) calculates the
%   Error Vector Magnitude (EVM) in dB between received and ideal symbols.
%
%   Inputs:
%       received_symbols - Received constellation symbols (complex vector)
%       ideal_symbols    - Ideal/reference constellation symbols (complex vector)
%
%   Outputs:
%       evm_db           - EVM in dB (scalar)
%
%   EVM is calculated as:
%       EVM = sqrt(mean(|received - ideal|^2) / mean(|ideal|^2))
%       EVM_dB = 20*log10(EVM)
%
%   Example:
%       ideal = [1+1j, -1+1j, -1-1j, 1-1j];
%       received = ideal + 0.1*randn(size(ideal));
%       evm_db = calculate_evm(received, ideal);
%
%   Author: L1 Algorithm Developer
%   Date: 2024

    if nargin < 2
        error('calculate_evm: Not enough input arguments');
    end
    
    % Ensure column vectors
    received_symbols = received_symbols(:);
    ideal_symbols = ideal_symbols(:);
    
    if length(received_symbols) ~= length(ideal_symbols)
        error('calculate_evm: received_symbols and ideal_symbols must have same length');
    end
    
    % Calculate error vector
    error_vector = received_symbols - ideal_symbols;
    
    % Calculate mean squared error and reference power
    mse = mean(abs(error_vector).^2);
    ref_power = mean(abs(ideal_symbols).^2);
    
    if ref_power == 0
        warning('calculate_evm: ideal_symbols have zero power, EVM undefined');
        evm_db = inf;
        return;
    end
    
    % Calculate EVM (as a percentage ratio)
    evm = sqrt(mse / ref_power);
    
    % Convert to dB
    evm_db = 20 * log10(evm);
end

