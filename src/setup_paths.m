% SETUP_PATHS Add all necessary paths for running demonstration scripts
%
%   Run this script from the examples directory to add all required paths
%   to your Octave path.
%
%   Usage: run setup_paths.m or addpath('setup_paths.m'); setup_paths

% Get the directory where this script is located
script_dir = fileparts(mfilename('fullpath'));

% Add utility functions
addpath(fullfile(script_dir, 'utils'));

% Add algorithm modules
addpath(fullfile(script_dir, 'algorithms', 'modulation'));
addpath(fullfile(script_dir, 'algorithms', 'demodulation'));
addpath(fullfile(script_dir, 'algorithms', 'coding'));
addpath(fullfile(script_dir, 'algorithms', 'equalization'));
addpath(fullfile(script_dir, 'algorithms', 'sync'));
addpath(fullfile(script_dir, 'algorithms', 'channel'));

fprintf('Paths added successfully!\n');
fprintf('Base directory: %s\n', script_dir);

