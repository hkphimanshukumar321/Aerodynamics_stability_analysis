% EXAMPLE_USAGE - Examples of how to use aero_calculations.m
%
% This script demonstrates various ways to use the aerodynamic calculations
% function with default parameters and online data sources.

fprintf('=== AERODYNAMIC CALCULATIONS - USAGE EXAMPLES ===\n\n');

% Example 1: Use default parameters
fprintf('Example 1: Using default parameters\n');
fprintf('-----------------------------------\n');
aero_calculations();
fprintf('\n\n');

% Example 2: Use online data from a JSON URL
% Uncomment and modify the URL to use your own data source
% fprintf('Example 2: Fetching data from online JSON source\n');
% fprintf('-----------------------------------\n');
% json_url = 'https://example.com/aerodynamic_data.json';
% aero_calculations(json_url);
% fprintf('\n\n');

% Example 3: Use online data from a CSV URL
% Uncomment and modify the URL to use your own data source
% fprintf('Example 3: Fetching data from online CSV source\n');
% fprintf('-----------------------------------\n');
% csv_url = 'https://example.com/aerodynamic_data.csv';
% aero_calculations(csv_url);
% fprintf('\n\n');

fprintf('Note: To use online data, uncomment the examples above and\n');
fprintf('provide a valid URL pointing to your aerodynamic data file.\n');
fprintf('Supported formats: JSON, CSV, or text files with key-value pairs.\n');
