function [is_valid, issues] = validate_setup()
    % VALIDATE_SETUP - Validates project setup and file integrity
    %
    % This function checks:
    %   - Project structure (folders exist)
    %   - Required files are present
    %   - Functions can be found and called
    %   - Data files are accessible
    %
    % Output:
    %   is_valid: true if setup is valid, false otherwise
    %   issues: Cell array of issue descriptions
    
    issues = {};
    is_valid = true;
    
    fprintf('========================================\n');
    fprintf('PROJECT SETUP VALIDATION\n');
    fprintf('========================================\n\n');
    
    % 1. Check project structure
    fprintf('1. Checking project structure...\n');
    try
        [project_root, code_folder, data_folder, output_folder] = get_project_paths();
        fprintf('   ✓ Project root: %s\n', project_root);
        fprintf('   ✓ Code folder: %s\n', code_folder);
        fprintf('   ✓ Data folder: %s\n', data_folder);
        fprintf('   ✓ Output folder: %s\n', output_folder);
    catch ME
        is_valid = false;
        issues{end+1} = sprintf('Project structure error: %s', ME.message);
        fprintf('   ✗ Error: %s\n', ME.message);
        return;
    end
    
    % 2. Check required functions exist
    fprintf('\n2. Checking required functions...\n');
    required_functions = {
        'read_aero_data.m'
        'process_data_folder.m'
        'aero_calculations.m'
        'stability_analysis.m'
        'create_visualizations.m'
        'run_full_analysis.m'
        'get_project_paths.m'
    };
    
    for i = 1:length(required_functions)
        func_name = required_functions{i};
        func_path = fullfile(code_folder, func_name);
        if exist(func_path, 'file')
            fprintf('   ✓ %s\n', func_name);
        else
            is_valid = false;
            issues{end+1} = sprintf('Missing function: %s', func_name);
            fprintf('   ✗ Missing: %s\n', func_name);
        end
    end
    
    % 3. Check data folder has .dat files
    fprintf('\n3. Checking data files...\n');
    dat_files = dir(fullfile(data_folder, '*.dat'));
    num_files = length(dat_files);
    if num_files > 0
        fprintf('   ✓ Found %d .dat files\n', num_files);
    else
        is_valid = false;
        issues{end+1} = 'No .dat files found in data folder';
        fprintf('   ✗ No .dat files found\n');
    end
    
    % 4. Test function calls (without full execution)
    fprintf('\n4. Testing function availability...\n');
    try
        % Test get_project_paths
        [~, ~, ~, ~] = get_project_paths();
        fprintf('   ✓ get_project_paths() works\n');
    catch ME
        is_valid = false;
        issues{end+1} = sprintf('get_project_paths() error: %s', ME.message);
        fprintf('   ✗ get_project_paths() failed: %s\n', ME.message);
    end
    
    try
        % Test read_aero_data with a sample file
        if num_files > 0
            sample_file = fullfile(data_folder, dat_files(1).name);
            data = read_aero_data(sample_file);
            if isstruct(data)
                fprintf('   ✓ read_aero_data() works\n');
            else
                is_valid = false;
                issues{end+1} = 'read_aero_data() returned invalid structure';
                fprintf('   ✗ read_aero_data() returned invalid structure\n');
            end
        end
    catch ME
        is_valid = false;
        issues{end+1} = sprintf('read_aero_data() error: %s', ME.message);
        fprintf('   ✗ read_aero_data() failed: %s\n', ME.message);
    end
    
    % 5. Check MATLAB version compatibility
    fprintf('\n5. Checking MATLAB compatibility...\n');
    matlab_version = version('-release');
    fprintf('   MATLAB version: %s\n', matlab_version);
    
    % Check for required functions
    required_funcs = {'fullfile', 'fileparts', 'mfilename', 'dir', 'fopen'};
    for i = 1:length(required_funcs)
        if exist(required_funcs{i}, 'builtin') || exist(required_funcs{i}, 'file')
            fprintf('   ✓ %s available\n', required_funcs{i});
        else
            is_valid = false;
            issues{end+1} = sprintf('Required MATLAB function missing: %s', required_funcs{i});
            fprintf('   ✗ Missing: %s\n', required_funcs{i});
        end
    end
    
    % 6. Check file permissions
    fprintf('\n6. Checking file permissions...\n');
    test_file = fullfile(output_folder, 'test_write.txt');
    try
        fid = fopen(test_file, 'w');
        if fid ~= -1
            fprintf(fid, 'test');
            fclose(fid);
            delete(test_file);
            fprintf('   ✓ Output folder is writable\n');
        else
            is_valid = false;
            issues{end+1} = 'Output folder is not writable';
            fprintf('   ✗ Output folder is not writable\n');
        end
    catch ME
        is_valid = false;
        issues{end+1} = sprintf('File permission error: %s', ME.message);
        fprintf('   ✗ File permission error: %s\n', ME.message);
    end
    
    % Summary
    fprintf('\n========================================\n');
    if is_valid
        fprintf('✓ VALIDATION PASSED\n');
        fprintf('Project is ready to use!\n');
    else
        fprintf('✗ VALIDATION FAILED\n');
        fprintf('Issues found:\n');
        for i = 1:length(issues)
            fprintf('  - %s\n', issues{i});
        end
    end
    fprintf('========================================\n\n');
end
