% STABILITY_ANALYSIS - Performs stability analysis using aerodynamic data
%
% This script analyzes aircraft stability by comparing CG and AC positions
% Can work with data from .dat files or default parameters
%
% Usage:
%   stability_analysis()  % Use default parameters
%   stability_analysis(data_file)  % Load data from specific file
%   stability_analysis(all_data)  % Use processed data structure

function stability_analysis(data_source)
    if nargin < 1
        data_source = [];
    end
    
    % Default parameters
    cg_position = 0.5; % CG position (fraction of MAC)
    ac_position = 0.25; % Aerodynamic center position (fraction of MAC)
    
    % Try to extract data from source if provided
    if ~isempty(data_source)
        if ischar(data_source) || isstring(data_source)
            % Load from file
            if exist(data_source, 'file')
                data = read_aero_data(data_source);
                if isfield(data, 'alpha') && ~isempty(data.alpha)
                    % Use coefficient data if available
                    fprintf('Loaded coefficient data from %s\n', data_source);
                end
            end
        elseif isstruct(data_source) && isfield(data_source, 'alpha')
            % Use provided data structure
            data = data_source;
        elseif iscell(data_source)
            % Process first coefficient data found
            for i = 1:length(data_source)
                if isfield(data_source{i}, 'type') && ...
                   strcmp(data_source{i}.type, 'coefficients')
                    data = data_source{i};
                    break;
                end
            end
        end
    end
    
    % Example coefficients (for demonstration if no data loaded)
    if ~exist('data', 'var') || ~isfield(data, 'alpha') || isempty(data.alpha)
        angles_of_attack = [1.00, 0.95, 0.90, 0.80, 0.70, 0.60, 0.50, 0.40];
        coefficients = [0.0016, 0.0124, 0.0229, 0.0428, 0.061, 0.0771, 0.0905, 0.1002];
    else
        angles_of_attack = data.alpha;
        coefficients = data.cl;
    end
    
    % Calculate static margin
    static_margin = ac_position - cg_position;
    
    % Display analysis
    fprintf('\n=== STABILITY ANALYSIS ===\n');
    fprintf('CG Position: %.2f (fraction of MAC)\n', cg_position);
    fprintf('AC Position: %.2f (fraction of MAC)\n', ac_position);
    fprintf('Static Margin: %.4f\n', static_margin);
    fprintf('\n');
    
    % Stability determination
    if static_margin > 0
        fprintf('✓ STABLE CONFIGURATION\n');
        fprintf('  The CG is ahead of the AC, providing positive static stability.\n');
        fprintf('  The aircraft will tend to return to equilibrium after disturbances.\n');
    elseif static_margin < 0
        fprintf('✗ UNSTABLE CONFIGURATION\n');
        fprintf('  The CG is behind the AC, resulting in negative static stability.\n');
        fprintf('  The aircraft will diverge from equilibrium after disturbances.\n');
        fprintf('  Recommendation: Move CG forward to achieve stability.\n');
    else
        fprintf('⚠ NEUTRAL STABILITY\n');
        fprintf('  The CG coincides with the AC.\n');
        fprintf('  The aircraft has neutral stability.\n');
    end
    
    fprintf('\n');
end
