function decoded = hamming_decode(encoded)
% HAMMING_DECODE (7,4) Hamming code decoding with error correction
%
%   DECODED = HAMMING_DECODE(ENCODED) decodes and corrects errors using
%   (7,4) Hamming code.
%
%   Inputs:
%       encoded - Encoded bits (vector of 0s and 1s)
%                 Length should be a multiple of 7.
%                 If not, will truncate to nearest multiple of 7.
%
%   Outputs:
%       decoded - Decoded data bits (4 bits per 7 input bits)
%                 Code rate: 4/7
%
%   The (7,4) Hamming code can detect 2 errors and correct 1 error per
%   7-bit block. This decoder uses syndrome-based error correction.
%
%   Example:
%       encoded = [1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 1];
%       decoded = hamming_decode(encoded);  % Returns 8 bits
%
%   Note: Uses standard (7,4) Hamming code parity check matrix.

    if nargin < 1
        error('hamming_decode: Not enough input arguments');
    end
    
    % Ensure row vector
    encoded = encoded(:)';
    
    % Truncate to multiple of 7
    num_bits = length(encoded);
    num_blocks = floor(num_bits / 7);
    
    if num_blocks == 0
        error('hamming_decode: Encoded data must contain at least 7 bits');
    end
    
    if num_bits < num_blocks * 7
        warning('hamming_decode: Encoded length not multiple of 7, truncating');
        encoded = encoded(1:num_blocks * 7);
    end
    
    % Standard (7,4) Hamming code parity check matrix
    % H = [P^T | I3] where P is parity matrix and I3 is 3x3 identity
    H = [1 1 0 1 1 0 0;
         1 0 1 1 0 1 0;
         0 1 1 1 0 0 1];
    
    % Decode each block of 7 bits
    decoded = zeros(1, num_blocks * 4);
    
    for i = 1:num_blocks
        block_start = (i - 1) * 7 + 1;
        block_end = i * 7;
        received_block = encoded(block_start:block_end);
        
        % Calculate syndrome: s = r * H^T (mod 2)
        syndrome = mod(received_block * H', 2);
        
        % Convert syndrome to error position (0-indexed)
        % Syndrome is a 3-bit binary number indicating error position
        error_pos = syndrome(1) + syndrome(2)*2 + syndrome(3)*4;
        
        % Correct error if syndrome is non-zero (error_pos > 0)
        if error_pos > 0 && error_pos <= 7
            % Flip the bit at error position (1-indexed)
            received_block(error_pos) = mod(received_block(error_pos) + 1, 2);
        end
        
        % Extract data bits (first 4 bits of corrected codeword)
        decoded_start = (i - 1) * 4 + 1;
        decoded_end = i * 4;
        decoded(decoded_start:decoded_end) = received_block(1:4);
    end
end

