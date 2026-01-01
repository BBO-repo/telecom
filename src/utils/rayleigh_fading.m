function h = rayleigh_fading(num_samples, num_taps)
% RAYLEIGH_FADING Generate Rayleigh fading channel coefficients
%
%   H = RAYLEIGH_FADING(NUM_SAMPLES) generates a complex channel vector
%   with Rayleigh fading coefficients for NUM_SAMPLES samples.
%
%   H = RAYLEIGH_FADING(NUM_SAMPLES, NUM_TAPS) generates a multi-tap
%   Rayleigh fading channel with NUM_TAPS taps.
%
%   Inputs:
%       num_samples - Number of samples in the channel (integer)
%       num_taps    - Number of channel taps (integer, default: 1)
%
%   Outputs:
%       h           - Channel coefficients (num_samples x num_taps for multi-tap,
%                     or num_samples x 1 for single-tap)
%
%   Rayleigh fading is modeled as a complex Gaussian process where both
%   in-phase and quadrature components are zero-mean Gaussian with variance 0.5.
%
%   Example:
%       h = rayleigh_fading(1000);           % Single-tap fading
%       h = rayleigh_fading(1000, 4);        % 4-tap fading channel
%

    if nargin < 1
        error('rayleigh_fading: Not enough input arguments');
    end
    
    if nargin < 2
        num_taps = 1;
    end
    
    % Generate complex Gaussian (real and imaginary parts independent)
    % Each component has variance 0.5, so total power = 1
    h = sqrt(0.5) * (randn(num_samples, num_taps) + 1j*randn(num_samples, num_taps));
end

