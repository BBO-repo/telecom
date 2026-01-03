function encoded = conv_encode(data, generators, constraint_length)
% CONV_ENCODE Convolutional code encoding
%
%   ENCODED = CONV_ENCODE(DATA) encodes data using a rate 1/2 convolutional
%   code with constraint length 3 and generator polynomials [7, 5] in octal.
%
%   ENCODED = CONV_ENCODE(DATA, GENERATORS) specifies generator polynomials
%   as a vector of octal numbers (e.g., [7, 5] for rate 1/2).
%
%   ENCODED = CONV_ENCODE(DATA, GENERATORS, CONSTRAINT_LENGTH) specifies
%   the constraint length.
%
%   Inputs:
%       data              - Input binary data (vector of 0s and 1s)
%       generators        - Optional: Generator polynomials in octal (vector)
%                          Default: [7, 5] for rate 1/2
%       constraint_length - Optional: Constraint length (scalar, default: 3)
%
%   Outputs:
%       encoded           - Encoded bits (2x input length for rate 1/2)
%                          Output format: [out0(1), out1(1), out0(2), out1(2), ...]
%
%   This implements a non-systematic convolutional encoder. For rate 1/2,
%   each input bit produces 2 output bits.
%
%   Example:
%       data = randi([0,1], 1, 100);
%       encoded = conv_encode(data);  % Rate 1/2, [7,5]
%

    if nargin < 1
        error('conv_encode: Not enough input arguments');
    end
    
    % Ensure row vector
    data = data(:)';
    
    % Default parameters: rate 1/2, constraint length 3, generators [7, 5]
    if nargin < 2 || isempty(generators)
        generators = [7, 5];  % Octal
    end
    
    if nargin < 3 || isempty(constraint_length)
        constraint_length = 3;
    end
    
    % Convert octal generators to binary polynomials
    num_outputs = length(generators);
    gen_binary = zeros(num_outputs, constraint_length);
    
    for i = 1:num_outputs
        gen_octal = generators(i);
        % Convert octal to binary representation
        gen_bin_str = dec2bin(gen_octal);
        gen_bin = str2num(gen_bin_str')';  % Convert to array
        
        % Pad or truncate to constraint_length (MSB first)
        if length(gen_bin) < constraint_length
            gen_bin = [zeros(1, constraint_length - length(gen_bin)), gen_bin];
        elseif length(gen_bin) > constraint_length
            gen_bin = gen_bin(end-constraint_length+1:end);
        end
        
        gen_binary(i, :) = gen_bin;
    end
    
    % Initialize shift register (encoder state)
    shift_reg = zeros(1, constraint_length - 1);
    
    % Length of input data
    num_bits = length(data);
    
    % Number of tail bits needed to flush encoder
    num_tail_bits = constraint_length - 1;
    
    % Initialize output (rate 1/2 means 2 output bits per input bit, plus tail bits)
    total_encoded_bits = num_outputs * (num_bits + num_tail_bits);
    encoded = zeros(1, total_encoded_bits);
    
    % Encode each input bit
    for n = 1:num_bits
        input_bit = data(n);
        
        % Calculate outputs for each generator
        % Note: We compute output BEFORE shifting in the input
        for out_idx = 1:num_outputs
            % Generator: gen_binary(out_idx, 1) is coefficient for input bit
            %            gen_binary(out_idx, 2:end) are coefficients for shift register
            output_bit = mod(sum(shift_reg .* gen_binary(out_idx, 2:end)), 2);
            
            % Also include current input bit if generator[0] is 1
            if gen_binary(out_idx, 1) == 1
                output_bit = mod(output_bit + input_bit, 2);
            end
            
            % Store output: interleave outputs [out0(1), out1(1), out0(2), out1(2), ...]
            encoded((n-1)*num_outputs + out_idx) = output_bit;
        end
        
        % Shift in new bit AFTER computing outputs (move register contents right, new bit at left)
        shift_reg = [input_bit, shift_reg(1:end-1)];
    end
    
    % Add tail bits (flush encoder state to zero)
    for n = 1:num_tail_bits
        input_bit = 0;
        
        % Calculate outputs BEFORE shifting
        for out_idx = 1:num_outputs
            % Generator: gen_binary(out_idx, 1) is coefficient for input bit
            %            gen_binary(out_idx, 2:end) are coefficients for shift register
            output_bit = mod(sum(shift_reg .* gen_binary(out_idx, 2:end)), 2);
            
            if gen_binary(out_idx, 1) == 1
                output_bit = mod(output_bit + input_bit, 2);
            end
            
            % Tail bits start after data bits
            encoded(num_outputs * num_bits + (n-1)*num_outputs + out_idx) = output_bit;
        end
        
        % Shift in zero AFTER computing outputs
        shift_reg = [input_bit, shift_reg(1:end-1)];
    end
end

