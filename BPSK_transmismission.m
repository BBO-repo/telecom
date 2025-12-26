clc; clear; close all;

%% ---------------- PARAMETERS ---------------- %%
Fs     = 10000;       % Sampling frequency (Hz)
Fc     = 1000;        % Carrier frequency (Hz)
Tb     = 0.01;        % Bit duration (seconds)
Nb     = 20;          % Number of bits to transmit
SNR_dB = -20;         % Channel SNR in dB

t = 0:1/Fs:Tb-1/Fs;   % Time vector for one bit
Ns = length(t);       % Samples per bit
fading = 'rayleigh';  % Fading 'none','rayleigh','rician','nakagami','log-normal','weibull'
%% ---------------- TRANSMITTER ---------------- %%
% Random bits
rng(123);                       % force seed for reproducibility
bits_tx = randi([0 1], Nb, 1);  % transmitted bits

% Complex BPSK mapping: 0 -> -1, 1 -> +1 in real part, imaginary part is 0
symbols = (2*bits_tx - 1) + 1i*zeros(Nb, 1);  % Complex symbols (1 x Nb)

% Carrier
carrier = exp(1i*2*pi*Fc*t);  % Complex carrier (cos + i*sin)

% Modulated signal on carrier (complex modulation)
tx_signal = (symbols .* carrier);  % Complex modulated signal (Ns x Nb)

%% ---------------- CHANNEL ---------------- %%
rx_signal = awgn(tx_signal, SNR_dB, 'measured');  % Add noise to signal

%% ---------------- RECEIVER ---------------- %%
% Add Rayleigh fading - used for environments without a clear line-of-sight (e.g., urban, dense areas).

switch fading

  case 'none'
    h = ones(Nb, 1);

  case 'rayleigh'
    % Generate random fading coefficients (Rayleigh distributed)
    h = (randn(Nb, 1) + 1i*randn(Nb, 1)) / sqrt(2);  % Rayleigh fading (complex Gaussian)

  case 'rician'
    % Parameters for Rician fading
    K = 5;  % Rician factor (ratio of line-of-sight power to scattered power)
    h = sqrt(K / (K + 1)) + (randn(Nb, 1) + 1i*randn(Nb, 1)) / sqrt(2); % Rician fading

  case 'nakagami'
    % Parameters for Nakagami fading
    m = 1.5;  % Nakagami fading parameter (1 for Rayleigh, >1 for stronger channels)
    h = sqrt(m) * (randn(Nb, 1) + 1i*randn(Nb, 1)) / sqrt(2);  % Nakagami fading

  case 'log-normal'
    % Parameters for Log-Normal Shadowing
    mu    = 0;      % Mean shadowing effect (in dB)
    sigma = 3;      % Standard deviation (in dB)
    h     = 10^(randn(Nb, 1) * sigma / 10);  % Log-normal fading factor

  case 'weibull'
    % Parameters for Weibull fading
    k = 1.5;  % Shape parameter
    lambda = 1; % Scale parameter

    % Generate Weibull fading coefficients
    h = (randn(Nb, 1) * lambda) .^ (1 / k);

  otherwise
    h = ones(Nb, 1);

endswitch

faded_signal = tx_signal .* h; % Apply fading to each symbol

% Coherent demodulation (multiply by the complex conjugate of the carrier)
demod = rx_signal .* conj(carrier);

% Integrate (matched filter)
decision = sum(demod, 2);  % Match filter output

% Decode based on decision (threshold)
bits_rx = real(decision) > 0;  % Make decision based on real part

%% ---------------- PERFORMANCE ---------------- %%
bit_errors = sum(bits_tx ~= bits_rx);  % Count bit errors
BER        = bit_errors / Nb;          % Bit Error Rate

% Output results
fprintf('Transmitted bits: '); disp(bits_tx.');
fprintf('Received bits:    '); disp(bits_rx.');
fprintf('Bit errors: %d out of %d\n', bit_errors, Nb);
fprintf('BER: %f\n', BER);

%% ---------------- PLOTS ---------------- %%
figure;

subplot(3,1,1)
plot(t, real(tx_signal))
title('Transmitted Complex BPSK Signal (Real Part)'); xlabel('Time [s]'); ylabel('Amplitude');

subplot(3,1,2)
plot(t, real(rx_signal))
title('Received Signal (AWGN) - Real Part')
ylabel('Amplitude')

subplot(3,1,3)
hold on;
stem(1:Nb, bits_tx, 'bo--');
stem(1:Nb, bits_rx, 'rx');
title('Transmitted vs Received Bits')
legend('Tx Bits','Rx Bits'); xlabel('Bit Index'); ylabel('Bit Value');

