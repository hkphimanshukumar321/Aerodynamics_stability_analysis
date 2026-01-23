% STARTUP - Initializes the project environment
%
% This script should be run when starting work on the project.
% It adds the code folder to the path and validates the setup.
%
% Usage:
%   startup
%   Or call from command window after navigating to project root

function startup()
    % Get the code folder path
    this_file = mfilename('fullpath');
    code_folder = fileparts(this_file);
    
    % Add code folder to MATLAB path if not already there
    if ~contains(path, code_folder)
        addpath(code_folder);
        fprintf('Added %s to MATLAB path\n', code_folder);
    end
    
    % Display welcome message
    fprintf('\n');
    fprintf('========================================\n');
    fprintf('AIRCRAFT FLIGHT STABILITY PROJECT\n');
    fprintf('========================================\n\n');
    
    % Validate setup
    fprintf('Running setup validation...\n\n');
    [is_valid, issues] = validate_setup();
    
    if is_valid
        fprintf('\n✓ Project is ready to use!\n');
        fprintf('\nNext steps:\n');
        fprintf('  1. Run: run_full_analysis()\n');
        fprintf('  2. Or use individual functions:\n');
        fprintf('     - aero_calculations()\n');
        fprintf('     - stability_analysis()\n');
        fprintf('     - [data, files] = process_data_folder()\n');
    else
        fprintf('\n⚠ Setup validation found issues.\n');
        fprintf('Please review the issues above before proceeding.\n');
    end
    
    fprintf('\n');
end
