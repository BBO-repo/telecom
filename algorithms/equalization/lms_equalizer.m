function [equalized, weights] = lms_equalizer(rx_signal, training_seq, step_size, num_taps, mode)
% LMS_EQUALIZER LMS (Least Mean Squares) adaptive equalizer
%
%   [EQUALIZED, WEIGHTS] = LMS_EQUALIZER(RX_SIGNAL, TRAINING_SEQ, STEP_SIZE, NUM_TAPS)
%   performs adaptive equalization using LMS algorithm.
%
%   [EQUALIZED, WEIGHTS] = LMS_EQUALIZER(..., MODE) specifies the mode:
%       'training' - Use training sequence only (default)
%       'decision' - Use decision-directed mode after training
%
%   Inputs:
%       rx_signal    - Received signal (column vector)
%       training_seq - Training sequence (known symbols for adaptation)
%       step_size    - LMS step size (mu) - controls convergence speed
%       num_taps     - Number of equalizer taps (integer)
%       mode         - Optional: 'training' or 'decision' (string,
%                      default: 'training')
%
%   Outputs:
%       equalized    - Equalized output signal (column vector)
%       weights      - Final equalizer weights (column vector)
%
%   LMS update equation: w(n+1) = w(n) + mu * e(n) * conj(x(n))
%   where e(n) = d(n) - y(n) is the error
%
%   Example:
%       tx = qpsk_modulate(randi([0,1], 1, 1000));
%       rx = multipath_channel(tx, [1, 0.5, 0.3]);
%       training = tx(1:100);
%       [eq_out, w] = lms_equalizer(rx, training, 0.01, 7);
%

    if nargin < 4
        error('lms_equalizer: Not enough input arguments');
    end
    
    if nargin < 5
        mode = 'training';
    end
    
    % Ensure column vectors
    rx_signal = rx_signal(:);
    training_seq = training_seq(:);
    
    % Initialize equalizer weights (complex)
    weights = zeros(num_taps, 1);
    
    % Length of training
    training_length = length(training_seq);
    
    % Initialize output
    equalized = zeros(length(rx_signal), 1);
    
    % Pad input signal with zeros for convolution
    padded_rx = [zeros(num_taps-1, 1); rx_signal];
    
    % Training phase
    for n = 1:min(training_length, length(rx_signal))
        % Input vector (sliding window)
        input_vec = padded_rx(n : n + num_taps - 1);
        
        % Equalizer output
        y = weights' * input_vec;
        equalized(n) = y;
        
        % Desired signal (from training sequence)
        d = training_seq(n);
        
        % Error
        e = d - y;
        
        % LMS weight update
        weights = weights + step_size * e * conj(input_vec);
    end
    
    % Decision-directed mode
    if strcmpi(mode, 'decision') && length(rx_signal) > training_length
        % Simple hard decision for continuation
        for n = training_length + 1 : length(rx_signal)
            % Input vector
            input_vec = padded_rx(n : n + num_taps - 1);
            
            % Equalizer output
            y = weights' * input_vec;
            equalized(n) = y;
            
            % Hard decision (QPSK for example - can be generalized)
            % Find closest QPSK point
            qpsk_points = [1+1j, -1+1j, 1-1j, -1-1j] / sqrt(2);
            distances = abs(y/sqrt(2) - qpsk_points);
            [~, min_idx] = min(distances);
            d_hat = qpsk_points(min_idx) * sqrt(2);
            
            % Error (decision-directed)
            e = d_hat - y;
            
            % LMS weight update
            weights = weights + step_size * e * conj(input_vec);
        end
    else
        % Just equalize remaining samples without adaptation
        for n = training_length + 1 : length(rx_signal)
            input_vec = padded_rx(n : n + num_taps - 1);
            equalized(n) = weights' * input_vec;
        end
    end
end

