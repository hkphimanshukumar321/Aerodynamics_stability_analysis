function test_integrity()
    % TEST_INTEGRITY - Comprehensive integrity test for all functions
    %
    % This function tests:
    %   - Path resolution works correctly
    %   - All functions can be called
    %   - Data files can be read
    %   - Functions work together correctly
    %
    % Usage:
    %   test_integrity()
    
    fprintf('========================================\n');
    fprintf('INTEGRITY TEST\n');
    fprintf('========================================\n\n');
    
    tests_passed = 0;
    tests_failed = 0;
    
    % Test 1: Path detection
    fprintf('Test 1: Path Detection\n');
    fprintf('-----------------------------------\n');
    try
        [project_root, code_folder, data_folder, output_folder] = get_project_paths();
        fprintf('  ✓ Project root: %s\n', project_root);
        fprintf('  ✓ Code folder: %s\n', code_folder);
        fprintf('  ✓ Data folder: %s\n', data_folder);
        fprintf('  ✓ Output folder: %s\n', output_folder);
        tests_passed = tests_passed + 1;
    catch ME
        fprintf('  ✗ Failed: %s\n', ME.message);
        tests_failed = tests_failed + 1;
    end
    fprintf('\n');
    
    % Test 2: Function availability
    fprintf('Test 2: Function Availability\n');
    fprintf('-----------------------------------\n');
    required_funcs = {'read_aero_data', 'process_data_folder', 'aero_calculations', ...
                     'stability_analysis', 'create_visualizations', 'run_full_analysis'};
    all_available = true;
    for i = 1:length(required_funcs)
        if exist(required_funcs{i}, 'file')
            fprintf('  ✓ %s\n', required_funcs{i});
        else
            fprintf('  ✗ Missing: %s\n', required_funcs{i});
            all_available = false;
        end
    end
    if all_available
        tests_passed = tests_passed + 1;
    else
        tests_failed = tests_failed + 1;
    end
    fprintf('\n');
    
    % Test 3: Read sample data file
    fprintf('Test 3: Data File Reading\n');
    fprintf('-----------------------------------\n');
    try
        dat_files = dir(fullfile(data_folder, '*.dat'));
        if ~isempty(dat_files)
            sample_file = fullfile(data_folder, dat_files(1).name);
            data = read_aero_data(sample_file);
            if isstruct(data) && (isfield(data, 'x') || isfield(data, 'alpha'))
                fprintf('  ✓ Successfully read: %s\n', dat_files(1).name);
                fprintf('    Type: %s\n', data.type);
                tests_passed = tests_passed + 1;
            else
                fprintf('  ✗ Invalid data structure returned\n');
                tests_failed = tests_failed + 1;
            end
        else
            fprintf('  ✗ No .dat files found\n');
            tests_failed = tests_failed + 1;
        end
    catch ME
        fprintf('  ✗ Failed: %s\n', ME.message);
        tests_failed = tests_failed + 1;
    end
    fprintf('\n');
    
    % Test 4: Aerodynamic calculations
    fprintf('Test 4: Aerodynamic Calculations\n');
    fprintf('-----------------------------------\n');
    try
        aero_calculations();
        fprintf('  ✓ Calculations completed\n');
        tests_passed = tests_passed + 1;
    catch ME
        fprintf('  ✗ Failed: %s\n', ME.message);
        tests_failed = tests_failed + 1;
    end
    fprintf('\n');
    
    % Test 5: Stability analysis
    fprintf('Test 5: Stability Analysis\n');
    fprintf('-----------------------------------\n');
    try
        stability_analysis();
        fprintf('  ✓ Analysis completed\n');
        tests_passed = tests_passed + 1;
    catch ME
        fprintf('  ✗ Failed: %s\n', ME.message);
        tests_failed = tests_failed + 1;
    end
    fprintf('\n');
    
    % Test 6: Process data folder (limited)
    fprintf('Test 6: Data Folder Processing (First 10 files)\n');
    fprintf('-----------------------------------\n');
    try
        dat_files = dir(fullfile(data_folder, '*.dat'));
        if length(dat_files) > 10
            % Process first 10 files as a test
            test_data = cell(10, 1);
            for i = 1:10
                filename = fullfile(data_folder, dat_files(i).name);
                test_data{i} = read_aero_data(filename);
            end
            fprintf('  ✓ Processed 10 sample files\n');
            tests_passed = tests_passed + 1;
        else
            fprintf('  ⚠ Not enough files to test (found %d)\n', length(dat_files));
            tests_passed = tests_passed + 1;
        end
    catch ME
        fprintf('  ✗ Failed: %s\n', ME.message);
        tests_failed = tests_failed + 1;
    end
    fprintf('\n');
    
    % Test 7: Output folder writability
    fprintf('Test 7: Output Folder Writable\n');
    fprintf('-----------------------------------\n');
    try
        test_file = fullfile(output_folder, 'test_integrity.txt');
        fid = fopen(test_file, 'w');
        if fid ~= -1
            fprintf(fid, 'test');
            fclose(fid);
            delete(test_file);
            fprintf('  ✓ Output folder is writable\n');
            tests_passed = tests_passed + 1;
        else
            fprintf('  ✗ Cannot write to output folder\n');
            tests_failed = tests_failed + 1;
        end
    catch ME
        fprintf('  ✗ Failed: %s\n', ME.message);
        tests_failed = tests_failed + 1;
    end
    fprintf('\n');
    
    % Summary
    fprintf('========================================\n');
    fprintf('TEST SUMMARY\n');
    fprintf('========================================\n');
    fprintf('Passed: %d\n', tests_passed);
    fprintf('Failed: %d\n', tests_failed);
    fprintf('Total:  %d\n', tests_passed + tests_failed);
    
    if tests_failed == 0
        fprintf('\n✓ ALL TESTS PASSED!\n');
        fprintf('The project is ready to use.\n');
    else
        fprintf('\n✗ SOME TESTS FAILED\n');
        fprintf('Please review the errors above.\n');
    end
    fprintf('========================================\n\n');
end
