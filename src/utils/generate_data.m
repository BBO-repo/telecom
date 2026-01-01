function data = generate_data(num_bits)
% GENERATE_DATA Generate random binary data
%
%   DATA = GENERATE_DATA(NUM_BITS) generates a vector of random binary
%   data (0s and 1s) of length NUM_BITS.
%
%   Inputs:
%       num_bits - Number of bits to generate (integer)
%
%   Outputs:
%       data     - Binary data vector (row vector of 0s and 1s)
%
%   Example:
%       data = generate_data(1000);  % Generate 1000 random bits
%
%   Author: L1 Algorithm Developer
%   Date: 2024

    if nargin < 1
        error('generate_data: Not enough input arguments');
    end
    
    if ~isscalar(num_bits) || num_bits <= 0 || mod(num_bits, 1) ~= 0
        error('generate_data: num_bits must be a positive integer');
    end
    
    % Generate random binary data
    data = randi([0, 1], 1, num_bits);
end

