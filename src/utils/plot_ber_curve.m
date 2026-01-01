function plot_ber_curve(snr_db, ber_values, legend_str, figure_handle)
% PLOT_BER_CURVE Plot Bit Error Rate curve
%
%   PLOT_BER_CURVE(SNR_DB, BER_VALUES) plots BER vs SNR curve on semilogy scale.
%
%   PLOT_BER_CURVE(SNR_DB, BER_VALUES, LEGEND_STR) adds legend string.
%
%   PLOT_BER_CURVE(SNR_DB, BER_VALUES, LEGEND_STR, FIGURE_HANDLE) plots in
%   specified figure handle.
%
%   Inputs:
%       snr_db       - SNR values in dB (vector)
%       ber_values   - BER values (vector or matrix, same length as snr_db)
%       legend_str   - Optional: Legend label(s) (string or cell array)
%       figure_handle - Optional: Figure handle to plot in
%
%   Outputs:
%       None (creates a plot)
%
%   Example:
%       snr = 0:2:20;
%       ber = 0.5 * erfc(sqrt(10.^(snr/10)));
%       plot_ber_curve(snr, ber, 'Theoretical BPSK');
%
%   Author: L1 Algorithm Developer
%   Date: 2024

    if nargin < 2
        error('plot_ber_curve: Not enough input arguments');
    end
    
    % Create or use existing figure
    if nargin >= 4 && ishandle(figure_handle)
        figure(figure_handle);
    else
        figure;
    end
    
    % Plot BER curve(s) on semilogy scale
    semilogy(snr_db, ber_values, 'o-', 'LineWidth', 1.5, 'MarkerSize', 6);
    grid on;
    xlabel('SNR (dB)');
    ylabel('Bit Error Rate (BER)');
    title('BER Performance');
    
    % Add legend if provided
    if nargin >= 3 && ~isempty(legend_str)
        legend(legend_str, 'Location', 'best');
    end
    
    % Set reasonable y-axis limits
    ylim([1e-5, 1]);
end

