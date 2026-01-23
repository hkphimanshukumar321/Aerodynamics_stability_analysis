function [all_data, file_list] = process_data_folder(data_folder)
    % PROCESS_DATA_FOLDER - Processes all .dat files in a folder
    %
    % Input:
    %   data_folder: (optional) Path to folder containing .dat files
    %                If not provided, uses project data folder
    %
    % Output:
    %   all_data: Cell array of data structures
    %   file_list: Cell array of filenames
    
    % Use automatic path detection if no folder specified
    if nargin < 1 || isempty(data_folder)
        [~, ~, data_folder, ~] = get_project_paths();
    else
        % If relative path provided, resolve it
        if ~contains(data_folder, filesep) || ~exist(data_folder, 'dir')
            [~, ~, default_data_folder, ~] = get_project_paths();
            % Check if it's a subfolder name
            test_path = fullfile(default_data_folder, data_folder);
            if exist(test_path, 'dir')
                data_folder = test_path;
            else
                % Try as absolute or relative to current directory
                if ~exist(data_folder, 'dir')
                    error('Data folder not found: %s', data_folder);
                end
            end
        end
    end
    
    % Verify folder exists
    if ~exist(data_folder, 'dir')
        error('Data folder not found: %s\nUse validate_setup() to check project structure.', data_folder);
    end
    
    % Find all .dat files
    dat_files = dir(fullfile(data_folder, '*.dat'));
    num_files = length(dat_files);
    
    fprintf('Found %d .dat files in %s\n', num_files, data_folder);
    fprintf('Processing files...\n');
    
    all_data = cell(num_files, 1);
    file_list = cell(num_files, 1);
    
    for i = 1:num_files
        filename = fullfile(data_folder, dat_files(i).name);
        file_list{i} = dat_files(i).name;
        
        if mod(i, 100) == 0
            fprintf('  Processed %d/%d files...\n', i, num_files);
        end
        
        try
            all_data{i} = read_aero_data(filename);
            all_data{i}.filename = dat_files(i).name;
        catch ME
            warning('Error processing %s: %s', dat_files(i).name, ME.message);
            all_data{i} = struct('filename', dat_files(i).name, 'error', ME.message);
        end
    end
    
    fprintf('Processing complete.\n');
end
