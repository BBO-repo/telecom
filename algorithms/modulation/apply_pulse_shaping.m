function waveform = apply_pulse_shaping(symbols, samples_per_symbol, rolloff, filter_span, filter_type)
% APPLY_PULSE_SHAPING Apply pulse shaping filter to symbols
%
%   WAVEFORM = APPLY_PULSE_SHAPING(SYMBOLS, SAMPLES_PER_SYMBOL, ROLLOFF)
%   upsamples symbols and applies a raised cosine pulse shaping filter.
%
%   WAVEFORM = APPLY_PULSE_SHAPING(SYMBOLS, SAMPLES_PER_SYMBOL, ROLLOFF, FILTER_SPAN)
%   specifies the filter span in symbol periods. Default is 6.
%
%   WAVEFORM = APPLY_PULSE_SHAPING(SYMBOLS, SAMPLES_PER_SYMBOL, ROLLOFF, FILTER_SPAN, FILTER_TYPE)
%   specifies 'rc' for raised cosine or 'rrc' for root-raised cosine.
%   Default is 'rc'.
%
%   Inputs:
%       symbols           - Complex symbols (column vector)
%       samples_per_symbol - Number of samples per symbol (integer)
%       rolloff            - Roll-off factor (0 to 1)
%       filter_span        - Optional: Filter span in symbol periods (default: 6)
%       filter_type        - Optional: 'rc' or 'rrc' (default: 'rc')
%
%   Outputs:
%       waveform          - Pulse-shaped waveform (column vector)
%
%   The function upsamples the symbols by inserting zeros, then convolves
%   with the pulse shaping filter. The output has samples_per_symbol samples
%   per input symbol.
%
%   Example:
%       symbols = qpsk_modulate([0, 1, 1, 0, 1, 1]);
%       waveform = apply_pulse_shaping(symbols, 8, 0.3);
%

    if nargin < 3
        error('apply_pulse_shaping: Not enough input arguments');
    end
    
    % Set defaults
    if nargin < 4 || isempty(filter_span)
        filter_span = 6;
    end
    
    if nargin < 5 || isempty(filter_type)
        filter_type = 'rc';
    end
    
    % Ensure symbols is a column vector
    symbols = symbols(:);
    num_symbols = length(symbols);
    
    % Upsample: insert zeros between symbols
    upsampled = zeros(num_symbols * samples_per_symbol, 1);
    upsampled(1:samples_per_symbol:end) = symbols;
    
    % Generate pulse shaping filter
    h = pulse_shape(samples_per_symbol, rolloff, filter_span, filter_type);
    
    % Apply filter via convolution
    waveform = conv(upsampled, h, 'same');
    
    % Ensure column vector
    waveform = waveform(:);
end

