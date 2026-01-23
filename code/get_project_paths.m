function [project_root, code_folder, data_folder, output_folder] = get_project_paths()
    % GET_PROJECT_PATHS - Automatically detects project paths regardless of location
    %
    % This function finds the project root by looking for the 'code' folder
    % and 'data' folder, making the code portable to any location.
    %
    % Output:
    %   project_root: Absolute path to project root directory
    %   code_folder: Absolute path to code directory
    %   data_folder: Absolute path to data directory
    %   output_folder: Absolute path to output directory (created if needed)
    %
    % This function ensures the code works when:
    %   - Cloned from GitHub to any location
    %   - Run from different working directories
    %   - Used on different operating systems
    
    % Get the folder where this function is located (should be in 'code' folder)
    this_file = mfilename('fullpath');
    code_folder = fileparts(this_file);
    
    % Project root is parent of code folder
    project_root = fileparts(code_folder);
    
    % Verify project structure
    if ~exist(project_root, 'dir')
        error('Project root not found. Expected structure: project_root/code/');
    end
    
    % Define expected folders
    data_folder = fullfile(project_root, 'data');
    output_folder = fullfile(project_root, 'output');
    
    % Verify data folder exists
    if ~exist(data_folder, 'dir')
        error('Data folder not found at: %s\nPlease ensure the data folder exists in the project root.', data_folder);
    end
    
    % Create output folder if it doesn't exist
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    
    % Return absolute paths
    project_root = get_absolute_path(project_root);
    code_folder = get_absolute_path(code_folder);
    data_folder = get_absolute_path(data_folder);
    output_folder = get_absolute_path(output_folder);
end

function abs_path = get_absolute_path(path)
    % GET_ABSOLUTE_PATH - Converts relative path to absolute path
    % Handles both Windows and Unix-style paths
    
    if isempty(path)
        abs_path = pwd;
        return;
    end
    
    % If already absolute (starts with / or drive letter), return as is
    if ispc
        % Windows: check for drive letter (C:, D:, etc.)
        if length(path) >= 2 && path(2) == ':'
            abs_path = path;
            return;
        end
        % Also check for UNC path (\\server\share)
        if length(path) >= 2 && path(1) == '\' && path(2) == '\'
            abs_path = path;
            return;
        end
    else
        % Unix/Mac: check if starts with /
        if ~isempty(path) && path(1) == filesep
            abs_path = path;
            return;
        end
    end
    
    % For relative paths, use fullfile with current directory
    % This handles most cases correctly
    current_dir = pwd;
    abs_path = fullfile(current_dir, path);
    
    % Use canonical form if available (MATLAB R2014b+)
    try
        if exist('canonicalizePath', 'builtin') || exist('canonicalizePath', 'file')
            % Not available in MATLAB, so we'll use a simpler approach
        end
    catch
        % Ignore if not available
    end
end
