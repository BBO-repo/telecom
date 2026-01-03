function decoded = conv_decode(encoded, generators, constraint_length, is_soft)
% CONV_DECODE Convolutional code decoding using Viterbi algorithm
%
%   DECODED = CONV_DECODE(ENCODED) decodes convolutionally encoded data using
%   Viterbi algorithm. Assumes hard decisions (binary input).
%
%   DECODED = CONV_DECODE(ENCODED, GENERATORS) specifies generator polynomials
%   as a vector of octal numbers (e.g., [7, 5] for rate 1/2).
%
%   DECODED = CONV_DECODE(ENCODED, GENERATORS, CONSTRAINT_LENGTH) specifies
%   the constraint length.
%
%   DECODED = CONV_DECODE(ENCODED, GENERATORS, CONSTRAINT_LENGTH, IS_SOFT)
%   specifies whether input is soft decisions (LLRs). If IS_SOFT is true,
%   ENCODED should contain log-likelihood ratios (LLRs) instead of hard bits.
%
%   Inputs:
%       encoded          - Encoded bits or LLRs (vector)
%                         For rate 1/2: [out0(1), out1(1), out0(2), out1(2), ...]
%       generators       - Optional: Generator polynomials in octal (vector)
%                         Default: [7, 5] for rate 1/2
%       constraint_length - Optional: Constraint length (scalar, default: 3)
%       is_soft          - Optional: True if input is soft decisions/LLRs
%                         (logical, default: false)
%
%   Outputs:
%       decoded          - Decoded binary data (row vector)
%
%   This implements the Viterbi algorithm for decoding convolutional codes.
%   For soft-decision decoding, input should be LLRs (log-likelihood ratios)
%   where LLR = log(P(bit=0)/P(bit=1)).
%
%   Example:
%       data = randi([0,1], 1, 100);
%       encoded = conv_encode(data);
%       decoded = conv_decode(encoded);  % Hard decision
%       llrs = 2*encoded - 1;  % Convert bits to simple LLRs
%       decoded = conv_decode(llrs, [], [], true);  % Soft decision
%

    if nargin < 1
        error('conv_decode: Not enough input arguments');
    end
    
    % Ensure row vector
    encoded = encoded(:)';
    
    % Default parameters
    if nargin < 2 || isempty(generators)
        generators = [7, 5];  % Octal
    end
    
    if nargin < 3 || isempty(constraint_length)
        constraint_length = 3;
    end
    
    if nargin < 4 || isempty(is_soft)
        is_soft = false;
    end
    
    % Convert octal generators to binary polynomials (same as encoder)
    num_outputs = length(generators);
    gen_binary = zeros(num_outputs, constraint_length);
    
    for i = 1:num_outputs
        gen_octal = generators(i);
        gen_bin_str = dec2bin(gen_octal);
        gen_bin = str2num(gen_bin_str')';
        
        if length(gen_bin) < constraint_length
            gen_bin = [zeros(1, constraint_length - length(gen_bin)), gen_bin];
        elseif length(gen_bin) > constraint_length
            gen_bin = gen_bin(end-constraint_length+1:end);
        end
        
        gen_binary(i, :) = gen_bin;
    end
    
    % Number of states = 2^(constraint_length-1)
    num_states = 2^(constraint_length - 1);
    
    % Determine input length (account for tail bits)
    % For rate 1/2, encoded length = num_outputs * (num_bits + tail_bits)
    % We need to figure out original data length
    % Simplified: assume tail bits are present
    total_encoded_bits = length(encoded);
    num_encoded_symbols = floor(total_encoded_bits / num_outputs);
    
    % Remove tail bits (last constraint_length-1 symbols)
    num_data_symbols = num_encoded_symbols - (constraint_length - 1);
    
    % Initialize path metrics (log probabilities)
    % path_metric(state) = log probability of most likely path ending at state
    path_metric = -inf * ones(1, num_states);
    path_metric(1) = 0;  % Start from state 0 (all zeros)
    
    % Initialize trellis (for traceback)
    % trellis(state, time) = previous state on best path
    % surv_path(state) = most recent input bit on best path to state
    surv_path = zeros(1, num_states);
    
    % Build trellis structure: state transitions
    % For each state, find next states for input 0 and input 1
    next_state_0 = zeros(1, num_states);
    next_state_1 = zeros(1, num_states);
    output_0 = zeros(num_states, num_outputs);
    output_1 = zeros(num_states, num_outputs);
    
    for state = 0:num_states-1
        % Current state (binary representation, MSB first)
        state_bits = zeros(1, constraint_length-1);
        temp_state = state;
        for bit_idx = 1:constraint_length-1
            state_bits(bit_idx) = mod(floor(temp_state / 2^(constraint_length-1-bit_idx)), 2);
        end
        
        % Input = 0
        input_bit_0 = 0;
        out_0 = zeros(1, num_outputs);
        for out_idx = 1:num_outputs
            % Generator: gen_binary(out_idx, 1) is coefficient for input bit
            %            gen_binary(out_idx, 2:end) are coefficients for shift register
            out_0(out_idx) = mod(sum(state_bits .* gen_binary(out_idx, 2:end)), 2);
            if gen_binary(out_idx, 1) == 1
                out_0(out_idx) = mod(out_0(out_idx) + input_bit_0, 2);
            end
        end
        % Next state: shift left and insert 0
        next_state_bits_0 = [state_bits(2:end), 0];
        next_state_0(state+1) = 0;
        for bit_idx = 1:length(next_state_bits_0)
            next_state_0(state+1) = next_state_0(state+1) + next_state_bits_0(bit_idx) * 2^(length(next_state_bits_0)-bit_idx);
        end
        output_0(state+1, :) = out_0;
        
        % Input = 1
        input_bit_1 = 1;
        out_1 = zeros(1, num_outputs);
        for out_idx = 1:num_outputs
            % Generator: gen_binary(out_idx, 1) is coefficient for input bit
            %            gen_binary(out_idx, 2:end) are coefficients for shift register
            out_1(out_idx) = mod(sum(state_bits .* gen_binary(out_idx, 2:end)), 2);
            if gen_binary(out_idx, 1) == 1
                out_1(out_idx) = mod(out_1(out_idx) + input_bit_1, 2);
            end
        end
        % Next state: shift left and insert 1
        next_state_bits_1 = [state_bits(2:end), 1];
        next_state_1(state+1) = 0;
        for bit_idx = 1:length(next_state_bits_1)
            next_state_1(state+1) = next_state_1(state+1) + next_state_bits_1(bit_idx) * 2^(length(next_state_bits_1)-bit_idx);
        end
        output_1(state+1, :) = out_1;
    end
    
    % Viterbi algorithm
    % Store survivor paths: prev_state(time, state) = previous state
    % Store input bits: input_bit(time, state) = input bit that led to state
    prev_state = zeros(num_data_symbols, num_states);
    input_bit = zeros(num_data_symbols, num_states);
    
    for t = 1:num_data_symbols
        % Get received symbols for this time step
        idx_start = (t-1)*num_outputs + 1;
        idx_end = t*num_outputs;
        received = encoded(idx_start:idx_end);
        
        % Convert to soft values if needed
        if ~is_soft
            % Convert hard bits to simple LLRs: bit=0 -> LLR=+1, bit=1 -> LLR=-1
            llrs = 1 - 2*received;  % 0->+1, 1->-1
        else
            llrs = received;  % Already LLRs
        end
        
        % Temporary path metrics for next iteration
        new_path_metric = -inf * ones(1, num_states);
        
        % For each current state, evaluate transitions
        for state = 0:num_states-1
            if path_metric(state+1) == -inf
                continue;  % State not reachable
            end
            
            % Transition with input 0
            next_s0 = next_state_0(state+1) + 1;  % 1-indexed
            expected_out_0 = output_0(state+1, :);
            % Compute branch metric (correlation metric)
            % For soft decision: branch_metric = sum(expected * llr)
            branch_metric_0 = 0;
            for out_idx = 1:num_outputs
                expected_bit = expected_out_0(out_idx);
                % Convert expected bit to +1/-1
                expected_llr = 1 - 2*expected_bit;  % 0->+1, 1->-1
                % Branch metric: higher when expected matches received
                branch_metric_0 = branch_metric_0 + expected_llr * llrs(out_idx);
            end
            
            new_metric_0 = path_metric(state+1) + branch_metric_0;
            if new_metric_0 > new_path_metric(next_s0)
                new_path_metric(next_s0) = new_metric_0;
                prev_state(t, next_s0) = state;
                input_bit(t, next_s0) = 0;
            end
            
            % Transition with input 1
            next_s1 = next_state_1(state+1) + 1;  % 1-indexed
            expected_out_1 = output_1(state+1, :);
            branch_metric_1 = 0;
            for out_idx = 1:num_outputs
                expected_bit = expected_out_1(out_idx);
                expected_llr = 1 - 2*expected_bit;
                branch_metric_1 = branch_metric_1 + expected_llr * llrs(out_idx);
            end
            
            new_metric_1 = path_metric(state+1) + branch_metric_1;
            if new_metric_1 > new_path_metric(next_s1)
                new_path_metric(next_s1) = new_metric_1;
                prev_state(t, next_s1) = state;
                input_bit(t, next_s1) = 1;
            end
        end
        
        % Update path metrics
        path_metric = new_path_metric;
    end
    
    % Traceback: find best path
    % Start from state 0 (most likely ending state after tail bits)
    [~, final_state_idx] = max(path_metric);
    
    decoded = zeros(1, num_data_symbols);
    current_state = final_state_idx;
    
    % Trace back through the trellis
    for t = num_data_symbols:-1:1
        decoded(t) = input_bit(t, current_state);
        current_state = prev_state(t, current_state) + 1;  % +1 for 1-indexing
    end
    
end

