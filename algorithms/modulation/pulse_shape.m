function h = pulse_shape(samples_per_symbol, rolloff, filter_span, filter_type)
% PULSE_SHAPE Generate raised cosine or root-raised cosine pulse shaping filter
%
%   H = PULSE_SHAPE(SAMPLES_PER_SYMBOL, ROLLOFF) generates a raised cosine
%   filter with specified samples per symbol and roll-off factor.
%
%   H = PULSE_SHAPE(SAMPLES_PER_SYMBOL, ROLLOFF, FILTER_SPAN) specifies the
%   filter span in symbol periods. Default is 6.
%
%   H = PULSE_SHAPE(SAMPLES_PER_SYMBOL, ROLLOFF, FILTER_SPAN, FILTER_TYPE)
%   specifies the filter type: 'rc' for raised cosine or 'rrc' for
%   root-raised cosine. Default is 'rc'.
%
%   Inputs:
%       samples_per_symbol - Number of samples per symbol (integer)
%       rolloff            - Roll-off factor (0 to 1, typically 0.2-0.5)
%       filter_span        - Optional: Filter span in symbol periods (default: 6)
%       filter_type        - Optional: 'rc' or 'rrc' (default: 'rc')
%
%   Outputs:
%       h                  - Filter coefficients (column vector)
%
%   The raised cosine filter has zero ISI at the symbol sampling instants
%   and provides spectral efficiency. The root-raised cosine is used for
%   split filtering (half in transmitter, half in receiver).
%
%   Example:
%       h = pulse_shape(8, 0.3, 6, 'rc');  % Raised cosine, 8 samples/symbol
%

    if nargin < 2
        error('pulse_shape: Not enough input arguments');
    end
    
    % Set defaults
    if nargin < 3 || isempty(filter_span)
        filter_span = 6;
    end
    
    if nargin < 4 || isempty(filter_type)
        filter_type = 'rc';
    end
    
    % Validate inputs
    if rolloff < 0 || rolloff > 1
        error('pulse_shape: Roll-off factor must be between 0 and 1');
    end
    
    if samples_per_symbol < 1 || mod(samples_per_symbol, 1) ~= 0
        error('pulse_shape: Samples per symbol must be a positive integer');
    end
    
    % Calculate filter length
    filter_length = 2 * filter_span * samples_per_symbol + 1;
    
    % Time vector (centered at zero)
    t = (-filter_span * samples_per_symbol : filter_span * samples_per_symbol) / samples_per_symbol;
    
    % Avoid division by zero at t = 0
    t(abs(t) < eps) = 0;
    
    % Generate raised cosine filter
    if strcmpi(filter_type, 'rc')
        % Raised cosine formula: h(t) = sinc(t) * cos(παt) / (1 - (2αt)^2)
        h = zeros(size(t));
        
        % For t = 0
        idx_zero = (abs(t) < eps);
        h(idx_zero) = 1;
        
        % For |t| = 1/(2*rolloff) - special case using L'Hôpital's rule
        if rolloff > 0
            idx_special = (abs(abs(t) - 1/(2*rolloff)) < 1e-10);
            h(idx_special) = (rolloff/2) * sin(pi/(2*rolloff));
        else
            idx_special = false(size(t));
        end
        
        % For other values
        idx_other = ~(idx_zero | idx_special);
        if rolloff > 0
            % Standard raised cosine formula
            numerator = sin(pi * t(idx_other)) .* cos(pi * rolloff * t(idx_other));
            denominator = pi * t(idx_other) .* (1 - (2 * rolloff * t(idx_other)).^2);
            h(idx_other) = numerator ./ denominator;
        else
            % For rolloff = 0, it's a sinc function
            h(idx_other) = sinc(t(idx_other));
        end
        
    elseif strcmpi(filter_type, 'rrc')
        % Root-raised cosine formula
        h = zeros(size(t));
        
        % For t = 0
        idx_zero = (abs(t) < eps);
        h(idx_zero) = 1 - rolloff + (4*rolloff/pi);
        
        % For |t| = 1/(4*rolloff) - special case
        if rolloff > 0
            idx_special1 = (abs(abs(t) - 1/(4*rolloff)) < 1e-10);
            h(idx_special1) = (rolloff/sqrt(2)) * ((1 + 2/pi) * sin(pi/(4*rolloff)) + ...
                                                   (1 - 2/pi) * cos(pi/(4*rolloff)));
        else
            idx_special1 = false(size(t));
        end
        
        % For other values
        idx_other = ~(idx_zero | idx_special1);
        if rolloff > 0
            numerator = sin(pi * t(idx_other) * (1 - rolloff)) + ...
                       4 * rolloff * t(idx_other) .* cos(pi * t(idx_other) * (1 + rolloff));
            denominator = pi * t(idx_other) .* (1 - (4 * rolloff * t(idx_other)).^2);
            h(idx_other) = numerator ./ denominator;
        else
            % For rolloff = 0, it's a sinc function
            h(idx_other) = sinc(t(idx_other));
        end
        
    else
        error('pulse_shape: Filter type must be ''rc'' or ''rrc''');
    end
    
    % Normalize filter to have unit energy
    h = h / sqrt(sum(abs(h).^2));
    
    % Ensure column vector
    h = h(:);
end

