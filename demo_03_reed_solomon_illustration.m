%% Demo: Reed-Solomon Coding Illustration
%
% This script demonstrates Reed-Solomon (RS) error-correcting codes:
%   - Step-by-step encoding process
%   - Introduction of errors (symbol errors)
%   - Decoding and error correction
%   - Comparison of different code parameters (n, k)
%   - Visualization of encoding/decoding process
%
% Reed-Solomon codes are block-based error correction codes that work
% on symbols rather than individual bits. An (n, k) RS code can correct
% up to t = floor((n-k)/2) symbol errors per codeword.
%

clear all;
close all;
clc;

%% Setup Paths
addpath('./utils');
addpath('./algorithms/coding');

fprintf('=== Reed-Solomon Coding Illustration ===\n\n');

%% Part 1: Basic Encoding and Decoding
fprintf('--- Part 1: Basic RS Encoding/Decoding ---\n');

% Code parameters
n = 7;          % Codeword length (total symbols)
k = 4;          % Message length (data symbols)
t = floor((n - k) / 2);  % Error correction capability

fprintf('Using RS(%d, %d) code:\n', n, k);
fprintf('  - Codeword length: %d symbols\n', n);
fprintf('  - Message length: %d symbols\n', k);
fprintf('  - Parity symbols: %d\n', n - k);
fprintf('  - Can correct up to %d symbol errors per codeword\n\n', t);

% Generate some message symbols (GF(8): values 0-7)
message_symbols = [1, 2, 3, 4];
fprintf('Original message symbols: ');
fprintf('%d ', message_symbols);
fprintf('\n');

% Encode
encoded_symbols = rs_encode(message_symbols, n, k);
fprintf('Encoded codeword (%d symbols): ', length(encoded_symbols));
fprintf('%d ', encoded_symbols);
fprintf('\n');
fprintf('  Message symbols (first %d): ', k);
fprintf('%d ', encoded_symbols(1:k));
fprintf('\n');
fprintf('  Parity symbols (last %d): ', n-k);
fprintf('%d ', encoded_symbols(k+1:end));
fprintf('\n\n');

% Decode (no errors)
decoded_symbols = rs_decode(encoded_symbols, n, k);
fprintf('Decoded message symbols: ');
fprintf('%d ', decoded_symbols);
fprintf('\n');
fprintf('Decoding successful: %s\n\n', ...
    mat2str(isequal(message_symbols, decoded_symbols(1:length(message_symbols)))));

%% Part 2: Error Introduction and Correction
fprintf('--- Part 2: Error Correction Demonstration ---\n');

% Test different numbers of errors
num_error_tests = min(t, 3);  % Test up to t errors

for num_errors = 0:num_error_tests
    fprintf('\nTest %d: Introducing %d symbol error(s)\n', num_errors+1, num_errors);
    
    % Create a copy of encoded symbols
    corrupted_symbols = encoded_symbols;
    
    % Introduce errors at random positions
    error_positions = randperm(n, num_errors);
    for pos = error_positions
        % Change symbol to a different random value
        new_value = mod(encoded_symbols(pos) + randi([1, 7]), 8);
        corrupted_symbols(pos) = new_value;
    end
    
    fprintf('  Corrupted codeword: ');
    fprintf('%d ', corrupted_symbols);
    if num_errors > 0
        fprintf('  [errors at positions: ');
        fprintf('%d ', error_positions);
        fprintf(']');
    end
    fprintf('\n');
    
    % Decode
    decoded_corrupted = rs_decode(corrupted_symbols, n, k);
    fprintf('  Decoded message: ');
    fprintf('%d ', decoded_corrupted);
    
    % Check if decoding was successful
    is_correct = isequal(message_symbols, decoded_corrupted(1:length(message_symbols)));
    if is_correct
        fprintf('  [SUCCESS - errors corrected!]');
    else
        fprintf('  [FAILED - too many errors]');
    end
    fprintf('\n');
end

%% Part 3: Comparison of Different Code Parameters
fprintf('\n--- Part 3: Different Code Parameters ---\n');

code_configs = [
    7, 4;   % RS(7,4) - can correct 1 error
    7, 3;   % RS(7,3) - can correct 2 errors
    15, 11; % RS(15,11) - can correct 2 errors
];

test_message = [0, 1, 2, 3];

fprintf('Comparing different RS code configurations:\n\n');

for i = 1:size(code_configs, 1)
    n_test = code_configs(i, 1);
    k_test = code_configs(i, 2);
    t_test = floor((n_test - k_test) / 2);
    code_rate = k_test / n_test;
    
    % Use appropriate message length
    msg_test = test_message(1:min(k_test, length(test_message)));
    if length(msg_test) < k_test
        msg_test = [msg_test, zeros(1, k_test - length(msg_test))];
    end
    
    fprintf('RS(%d, %d):\n', n_test, k_test);
    fprintf('  Code rate: %.2f\n', code_rate);
    fprintf('  Error correction: up to %d symbol errors\n', t_test);
    fprintf('  Message: ');
    fprintf('%d ', msg_test(1:min(k_test, 4)));
    fprintf('\n');
    
    encoded_test = rs_encode(msg_test, n_test, k_test);
    fprintf('  Encoded length: %d symbols (overhead: %.1f%%)\n', ...
        n_test, 100 * (n_test - k_test) / n_test);
    
    % Test with errors
    corrupted_test = encoded_test;
    if t_test > 0
        corrupted_test(1) = mod(encoded_test(1) + 1, 8);  % Introduce 1 error
    end
    decoded_test = rs_decode(corrupted_test, n_test, k_test);
    
    is_correct = isequal(msg_test(1:min(k_test, length(decoded_test))), ...
        decoded_test(1:min(k_test, length(decoded_test))));
    fprintf('  With 1 error: %s\n', mat2str(is_correct));
    fprintf('\n');
end

%% Part 4: Visualization
fprintf('--- Part 4: Visualization ---\n');

figure('Position', [100, 100, 1400, 800]);

% Subplot 1: Encoding process
subplot(2, 3, 1);
message_vis = [1, 2, 3, 4];
encoded_vis = rs_encode(message_vis, 7, 4);

bar([1:4, 5:7], [message_vis, encoded_vis(5:7)], 'grouped');
hold on;
bar(1:4, message_vis, 'FaceColor', [0.2, 0.6, 0.8]);
bar(5:7, encoded_vis(5:7), 'FaceColor', [0.8, 0.3, 0.3]);
xlabel('Symbol Position', 'FontSize', 11);
ylabel('Symbol Value', 'FontSize', 11);
title('RS(7,4) Encoding Process', 'FontSize', 12, 'FontWeight', 'bold');
legend('Message Symbols', 'Parity Symbols', 'Location', 'northwest');
grid on;
xticks(1:7);
xticklabels({'1', '2', '3', '4', 'P1', 'P2', 'P3'});

% Subplot 2: Error correction example
subplot(2, 3, 2);
corrupted_vis = encoded_vis;
corrupted_vis(2) = mod(encoded_vis(2) + 3, 8);  % Introduce error
decoded_vis = rs_decode(corrupted_vis, 7, 4);

x_pos = [1, 2, 3, 4];
bar_data = [message_vis; decoded_vis(1:4); corrupted_vis(1:4)];
b = bar(x_pos, bar_data', 'grouped');
% Set colors using set() for Octave compatibility
set(b(1), 'FaceColor', [0.2, 0.8, 0.2]);  % Original (green)
set(b(2), 'FaceColor', [0.2, 0.6, 0.8]);  % Decoded (blue)
set(b(3), 'FaceColor', [0.8, 0.3, 0.3]);  % Corrupted (red)
xlabel('Symbol Position', 'FontSize', 11);
ylabel('Symbol Value', 'FontSize', 11);
title('Error Correction (1 error introduced)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Original', 'Decoded', 'Corrupted', 'Location', 'northwest');
grid on;

% Subplot 3: Code rate comparison
subplot(2, 3, 3);
n_vals = [7, 7, 15];
k_vals = [4, 3, 11];
code_rates = k_vals ./ n_vals;
overhead = 1 - code_rates;

x_labels = cell(size(n_vals));
for i = 1:length(n_vals)
    x_labels{i} = sprintf('RS(%d,%d)', n_vals(i), k_vals(i));
end

b = bar([code_rates; overhead]', 'stacked');
% Set colors using set() for Octave compatibility
set(b(1), 'FaceColor', [0.2, 0.6, 0.8]);
set(b(2), 'FaceColor', [0.8, 0.5, 0.2]);
ylabel('Fraction', 'FontSize', 11);
title('Code Rate vs Overhead', 'FontSize', 12, 'FontWeight', 'bold');
legend('Code Rate', 'Overhead (parity)', 'Location', 'best');
grid on;
set(gca, 'XTickLabel', x_labels);

% Subplot 4: Error correction capability
subplot(2, 3, 4);
t_vals = floor((n_vals - k_vals) / 2);
bar(t_vals, 'FaceColor', [0.6, 0.2, 0.6]);
ylabel('Correctable Errors (t)', 'FontSize', 11);
title('Error Correction Capability', 'FontSize', 12, 'FontWeight', 'bold');
set(gca, 'XTickLabel', x_labels);
grid on;

% Subplot 5: Codeword structure
subplot(2, 3, 5);
codeword_example = encoded_vis;
codeword_labels = {'M1', 'M2', 'M3', 'M4', 'P1', 'P2', 'P3'};
% Create bars with different colors for message and parity
hold on;
bar(1:4, codeword_example(1:4), 'FaceColor', [0.2, 0.6, 0.8]);
bar(5:7, codeword_example(5:7), 'FaceColor', [0.8, 0.3, 0.3]);
hold off;
xlabel('Symbol Position', 'FontSize', 11);
ylabel('Symbol Value', 'FontSize', 11);
title('RS(7,4) Codeword Structure', 'FontSize', 12, 'FontWeight', 'bold');
set(gca, 'XTickLabel', codeword_labels);
grid on;
legend('Message', 'Parity', 'Location', 'northwest');

% Subplot 6: Encoding/Decoding flow
subplot(2, 3, 6);
axis off;
text(0.5, 0.9, 'Reed-Solomon Coding Flow', 'HorizontalAlignment', 'center', ...
    'FontSize', 14, 'FontWeight', 'bold');

y_positions = [0.75, 0.55, 0.35, 0.15];
text(0.1, y_positions(1), 'Message (k symbols)', 'FontSize', 11);
text(0.1, y_positions(2), 'RS Encoder', 'FontSize', 11, 'FontWeight', 'bold', ...
    'Color', [0.2, 0.6, 0.8]);
text(0.1, y_positions(3), 'Codeword (n symbols)', 'FontSize', 11);
text(0.1, y_positions(4), 'RS Decoder', 'FontSize', 11, 'FontWeight', 'bold', ...
    'Color', [0.8, 0.3, 0.3]);

% Add arrows
annotation('arrow', [0.3, 0.3], [0.7, 0.6], 'LineWidth', 2);
annotation('arrow', [0.3, 0.3], [0.5, 0.4], 'LineWidth', 2);

% Add example values
text(0.6, y_positions(1), sprintf('[%d %d %d %d]', message_vis), ...
    'FontSize', 10, 'FontFamily', 'monospace');
text(0.6, y_positions(3), sprintf('[%d %d %d %d %d %d %d]', encoded_vis), ...
    'FontSize', 10, 'FontFamily', 'monospace');

sgtitle('Reed-Solomon Coding Illustration', 'FontSize', 16, 'FontWeight', 'bold');

fprintf('Visualization complete. Check the figure window.\n\n');

%% Part 5: Performance with Multiple Codewords
fprintf('--- Part 5: Performance with Multiple Codewords ---\n');

num_codewords = 10;
bits_per_symbol = 3;  % For GF(8)
symbols_per_codeword = k;
total_symbols = num_codewords * symbols_per_codeword;

% Generate random message symbols
random_message = randi([0, 7], 1, total_symbols);
fprintf('Encoding %d message symbols (%d codewords of %d symbols each)...\n', ...
    total_symbols, num_codewords, symbols_per_codeword);

% Encode
encoded_multi = rs_encode(random_message, n, k);
fprintf('Encoded to %d codeword symbols\n', length(encoded_multi));

% Introduce errors (randomly across codewords)
error_rate = 0.1;  % 10% symbol error rate
num_errors_total = round(error_rate * length(encoded_multi));
error_positions = randperm(length(encoded_multi), num_errors_total);

corrupted_multi = encoded_multi;
for pos = error_positions
    corrupted_multi(pos) = mod(encoded_multi(pos) + randi([1, 7]), 8);
end

fprintf('Introduced %d symbol errors (%.1f%% error rate)\n', ...
    num_errors_total, 100 * error_rate);

% Decode
decoded_multi = rs_decode(corrupted_multi, n, k);
decoded_multi = decoded_multi(1:min(length(decoded_multi), length(random_message)));

% Count errors per codeword
errors_per_codeword = zeros(1, num_codewords);
for i = 1:num_codewords
    msg_start = (i-1) * symbols_per_codeword + 1;
    msg_end = min(i * symbols_per_codeword, length(random_message));
    dec_start = (i-1) * symbols_per_codeword + 1;
    dec_end = min(i * symbols_per_codeword, length(decoded_multi));
    
    if msg_end >= msg_start && dec_end >= dec_start
        original_block = random_message(msg_start:msg_end);
        decoded_block = decoded_multi(dec_start:dec_end);
        min_len = min(length(original_block), length(decoded_block));
        errors_per_codeword(i) = sum(original_block(1:min_len) ~= decoded_block(1:min_len));
    end
end

fprintf('Errors per codeword: ');
fprintf('%d ', errors_per_codeword);
fprintf('\n');
fprintf('Total message symbols with errors: %d / %d\n', ...
    sum(errors_per_codeword), length(random_message));
fprintf('Overall symbol error rate: %.2f%%\n\n', ...
    100 * sum(errors_per_codeword) / length(random_message));

%% Summary
fprintf('=== Summary ===\n');
fprintf('Reed-Solomon codes add redundancy (parity symbols) to enable error correction.\n');
fprintf('An RS(n, k) code:\n');
fprintf('  - Takes k message symbols and produces n codeword symbols\n');
fprintf('  - Adds n-k parity symbols for error correction\n');
fprintf('  - Can correct up to floor((n-k)/2) symbol errors per codeword\n');
fprintf('  - Trade-off: Lower code rate (k/n) provides more error correction\n');
fprintf('\n=== Demonstration Complete ===\n');

