function y = add_awgn(x, snr_db, signal_power)
% ADD_AWGN Add Additive White Gaussian Noise to signal
%
%   Y = ADD_AWGN(X, SNR_DB) adds AWGN to signal X with specified SNR in dB.
%   The signal power is automatically calculated from X.
%
%   Y = ADD_AWGN(X, SNR_DB, SIGNAL_POWER) uses the specified signal power
%   instead of calculating it from X.
%
%   Inputs:
%       x            - Input signal (complex or real)
%       snr_db       - Signal-to-Noise Ratio in dB (scalar)
%       signal_power - Optional: Signal power (scalar, default: calculated from x)
%
%   Outputs:
%       y            - Noisy signal (same size as x)
%
%   The noise power is calculated as:
%       noise_power = signal_power / (10^(snr_db/10))
%       noise = sqrt(noise_power/2) * (randn + 1j*randn) for complex signals
%
%   Example:
%       x = randn(1000, 1);
%       y = add_awgn(x, 10);  % Add noise at 10 dB SNR
%

    if nargin < 2
        error('add_awgn: Not enough input arguments');
    end
    
    % Calculate signal power if not provided
    if nargin < 3 || isempty(signal_power)
        signal_power = mean(abs(x(:)).^2);
    end
    
    % Convert SNR from dB to linear scale
    snr_linear = 10^(snr_db/10);
    
    % Calculate noise power
    noise_power = signal_power / snr_linear;
    
    % Generate noise (handle complex and real signals)
    if isreal(x)
        % Real signal: use real noise only
        noise = sqrt(noise_power) * randn(size(x));
    else
        % Complex signal: use complex noise (divide by 2 since power splits between I and Q)
        noise = sqrt(noise_power/2) * (randn(size(x)) + 1j*randn(size(x)));
    end
    
    % Add noise to signal
    y = x + noise;
end

