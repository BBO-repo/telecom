function H_full = pilot_interpolation(H_pilots, pilot_indices, total_subcarriers, method)
% PILOT_INTERPOLATION Interpolate channel estimates from pilots
%
%   H_FULL = PILOT_INTERPOLATION(H_PILOTS, PILOT_INDICES, TOTAL_SUBCARRIERS)
%   interpolates channel estimates from pilot subcarriers to all subcarriers.
%
%   H_FULL = PILOT_INTERPOLATION(..., METHOD) specifies interpolation method:
%       'linear' - Linear interpolation (default)
%       'spline' - Cubic spline interpolation
%
%   Inputs:
%       H_pilots         - Channel estimates at pilot positions (vector)
%       pilot_indices    - Indices of pilot subcarriers (integer vector, 1-indexed)
%       total_subcarriers - Total number of subcarriers (integer)
%       method           - Optional: Interpolation method (string,
%                          default: 'linear')
%
%   Outputs:
%       H_full           - Channel estimates for all subcarriers (column vector)
%
%   This function is used in OFDM systems to interpolate channel estimates
%   from pilot subcarriers to all data subcarriers.
%
%   Example:
%       pilot_idx = [1, 5, 9, 13];  % Every 4th subcarrier
%       H_pilots = [1+0.1j, 0.9+0.05j, 1.1-0.05j, 0.95+0.1j];
%       H_full = pilot_interpolation(H_pilots, pilot_idx, 16, 'linear');
%

    if nargin < 3
        error('pilot_interpolation: Not enough input arguments');
    end
    
    if nargin < 4
        method = 'linear';
    end
    
    % Ensure column vectors
    H_pilots = H_pilots(:);
    pilot_indices = pilot_indices(:);
    
    % All subcarrier indices
    all_indices = (1:total_subcarriers)';
    
    % Separate real and imaginary parts for interpolation
    H_pilots_real = real(H_pilots);
    H_pilots_imag = imag(H_pilots);
    
    % Interpolate
    if strcmpi(method, 'spline')
        H_full_real = interp1(pilot_indices, H_pilots_real, all_indices, 'spline', 'extrap');
        H_full_imag = interp1(pilot_indices, H_pilots_imag, all_indices, 'spline', 'extrap');
    else  % linear (default)
        H_full_real = interp1(pilot_indices, H_pilots_real, all_indices, 'linear', 'extrap');
        H_full_imag = interp1(pilot_indices, H_pilots_imag, all_indices, 'linear', 'extrap');
    end
    
    % Combine real and imaginary parts
    H_full = H_full_real + 1j * H_full_imag;
    H_full = H_full(:);
end

