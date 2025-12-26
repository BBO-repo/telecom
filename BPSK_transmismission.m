clc; clear; close all;

%% ---------------- PARAMETERS ---------------- %%
Fs     = 10000;       % Sampling frequency (Hz)
Fc     = 1000;        % Carrier frequency (Hz)
Tb     = 0.01;        % Bit duration (seconds)
Nb     = 20;          % Number of bits to transmit
SNR_dB = -10;         % Channel SNR in dB

t = 0:1/Fs:Tb-1/Fs;   % Time vector for one bit
Ns = length(t);       % Samples per bit

%% ---------------- TRANSMITTER ---------------- %%
% Random bits
rng(123);                       % force seed for reproductability
bits_tx = randi([0 1], 1, Nb);  % transmitted bits

% BPSK mapping: 0 -> -1, 1 -> +1
symbols = 2*bits_tx - 1;        % 1 x Nb

% Carrier
carrier = cos(2*pi*Fc*t);        % 1 x Ns

% Modulated signal on carrier
tx_signal = carrier.' * symbols; % Ns x Nb

%% ---------------- CHANNEL ---------------- %%
rx_signal = awgn(tx_signal, SNR_dB, 'measured');

%% ---------------- RECEIVER ---------------- %%
% Coherent demodulation
demod  = rx_signal .* carrier';

% Integrate (matched filter)
decision = sum(demod,1);

% Decode
bits_rx = 1*(decision > 0)

%% ---------------- PERFORMANCE ---------------- %%
bit_errors = sum(bits_tx ~= bits_rx);
BER        = bit_errors / Nb;

fprintf('Transmitted bits: '); disp(bits_tx);
fprintf('Received bits:    '); disp(bits_rx);
fprintf('Bit errors: %d out of %d\n', bit_errors, Nb);
fprintf('BER: %f\n', BER);

%% ---------------- PLOTS ---------------- %%
figure;

subplot(3,1,1)
plot(t, tx_signal)
title('Transmitted BPSK Signal'); xlabel('Time [s]'); ylabel('Amplitude');

subplot(3,1,2)
plot(t, rx_signal)
title('Received Signal (AWGN)')
ylabel('Amplitude')

subplot(3,1,3)
hold('on');
stem(1:Nb, bits_tx);
stem(1:Nb, bits_rx, 'rx');
title('Transmitted vs Received Bits')
legend('Tx Bits','Rx Bits'); xlabel('Bit Index'); ylabel('Bit Value')


