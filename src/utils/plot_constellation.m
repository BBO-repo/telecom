function plot_constellation(symbols, title_str, figure_handle)
% PLOT_CONSTELLATION Plot constellation diagram
%
%   PLOT_CONSTELLATION(SYMBOLS) plots a constellation diagram of the given symbols.
%
%   PLOT_CONSTELLATION(SYMBOLS, TITLE_STR) uses TITLE_STR as the plot title.
%
%   PLOT_CONSTELLATION(SYMBOLS, TITLE_STR, FIGURE_HANDLE) plots in the
%   specified figure handle.
%
%   Inputs:
%       symbols     - Complex constellation symbols (vector)
%       title_str   - Optional: Plot title (string, default: 'Constellation Diagram')
%       figure_handle - Optional: Figure handle to plot in
%
%   Outputs:
%       None (creates a plot)
%
%   Example:
%       symbols = qpsk_modulate([0, 1, 1, 0]);
%       plot_constellation(symbols, 'QPSK Constellation');
%

    if nargin < 1
        error('plot_constellation: Not enough input arguments');
    end
    
    if nargin < 2 || isempty(title_str)
        title_str = 'Constellation Diagram';
    end
    
    % Extract real and imaginary parts
    real_part = real(symbols);
    imag_part = imag(symbols);
    
    % Create or use existing figure
    if nargin >= 3 && ishandle(figure_handle)
        figure(figure_handle);
    else
        figure;
    end
    
    % Plot constellation
    scatter(real_part, imag_part, 'filled', 'MarkerFaceAlpha', 0.6);
    grid on;
    xlabel('In-Phase (I)');
    ylabel('Quadrature (Q)');
    title(title_str);
    axis equal;
    
    % Add axis lines
    hold on;
    plot(xlim, [0 0], 'k--', 'LineWidth', 0.5);
    plot([0 0], ylim, 'k--', 'LineWidth', 0.5);
    hold off;
end

