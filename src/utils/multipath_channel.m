function y = multipath_channel(x, channel_taps, channel_delays)
% MULTIPATH_CHANNEL Apply multipath channel to signal
%
%   Y = MULTIPATH_CHANNEL(X, CHANNEL_TAPS) applies a multipath channel
%   to signal X. CHANNEL_TAPS is a vector of complex channel coefficients.
%
%   Y = MULTIPATH_CHANNEL(X, CHANNEL_TAPS, CHANNEL_DELAYS) specifies the
%   delay for each tap. If not provided, delays are assumed to be [0, 1, 2, ...].
%
%   Inputs:
%       x             - Input signal (column vector)
%       channel_taps  - Channel tap coefficients (complex vector)
%       channel_delays - Optional: Delay for each tap in samples (integer vector)
%
%   Outputs:
%       y             - Output signal after multipath channel (column vector)
%
%   The multipath channel is modeled as:
%       y[n] = sum(h[k] * x[n - d[k]])
%   where h[k] are the channel taps and d[k] are the delays.
%
%   Example:
%       x = randn(1000, 1);
%       taps = [1, 0.5*exp(1j*pi/4), 0.3];
%       y = multipath_channel(x, taps);
%

    if nargin < 2
        error('multipath_channel: Not enough input arguments');
    end
    
    % Convert to column vector if needed
    x = x(:);
    channel_taps = channel_taps(:);
    
    % Set default delays if not provided
    if nargin < 3 || isempty(channel_delays)
        channel_delays = (0:length(channel_taps)-1)';
    end
    
    channel_delays = channel_delays(:);
    
    if length(channel_taps) ~= length(channel_delays)
        error('multipath_channel: channel_taps and channel_delays must have same length');
    end
    
    % Maximum delay
    max_delay = max(channel_delays);
    
    % Initialize output
    y = zeros(length(x) + max_delay, 1);
    
    % Apply each tap
    for i = 1:length(channel_taps)
        delay = channel_delays(i);
        tap_coeff = channel_taps(i);
        
        % Pad input with zeros for delay
        x_delayed = [zeros(delay, 1); x; zeros(max_delay - delay, 1)];
        
        % Accumulate contribution from this tap
        y = y + tap_coeff * x_delayed(1:length(y));
    end
    
    % Trim to original length (or keep longer if desired)
    y = y(1:length(x));
end

