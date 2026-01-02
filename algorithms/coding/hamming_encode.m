function encoded = hamming_encode(data)
% HAMMING_ENCODE (7,4) Hamming code encoding
%
%   ENCODED = HAMMING_ENCODE(DATA) encodes data using (7,4) Hamming code.
%
%   Inputs:
%       data    - Input binary data (vector of 0s and 1s)
%                 Length should be a multiple of 4 for optimal efficiency.
%                 If not, data will be padded with zeros.
%
%   Outputs:
%       encoded - Encoded bits (7 bits per 4 input bits)
%                 Code rate: 4/7
%
%   The (7,4) Hamming code can detect 2 errors and correct 1 error per
%   7-bit block. It encodes 4 data bits into 7 bits by adding 3 parity bits.
%
%   Example:
%       data = [1, 0, 1, 1, 0, 1, 0, 0];
%       encoded = hamming_encode(data);  % Returns 14 bits
%
%   Note: Uses standard (7,4) Hamming code generator matrix.

    if nargin < 1
        error('hamming_encode: Not enough input arguments');
    end
    
    % Ensure row vector
    data = data(:)';
    
    % Pad data to multiple of 4
    num_bits = length(data);
    num_blocks = ceil(num_bits / 4);
    padded_length = num_blocks * 4;
    
    if num_bits < padded_length
        data = [data, zeros(1, padded_length - num_bits)];
    end
    
    % Standard (7,4) Hamming code generator matrix
    % G = [I4 | P] where I4 is 4x4 identity and P is parity matrix
    G = [1 0 0 0 1 1 0;
         0 1 0 0 1 0 1;
         0 0 1 0 0 1 1;
         0 0 0 1 1 1 1];
    
    % Encode each block of 4 bits
    encoded = zeros(1, num_blocks * 7);
    
    for i = 1:num_blocks
        block_start = (i - 1) * 4 + 1;
        block_end = i * 4;
        data_block = data(block_start:block_end);
        
        % Encode: c = d * G (mod 2)
        encoded_block = mod(data_block * G, 2);
        
        % Store encoded block
        encoded_start = (i - 1) * 7 + 1;
        encoded_end = i * 7;
        encoded(encoded_start:encoded_end) = encoded_block;
    end
end

