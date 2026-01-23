function [all_present, missing] = check_dependencies()
    % CHECK_DEPENDENCIES - Checks if all required functions are available
    %
    % Output:
    %   all_present: true if all dependencies are available
    %   missing: Cell array of missing function names
    
    missing = {};
    all_present = true;
    
    % List of required functions (without .m extension)
    required_functions = {
        'get_project_paths'
        'read_aero_data'
        'process_data_folder'
        'aero_calculations'
        'stability_analysis'
        'create_visualizations'
        'run_full_analysis'
        'validate_setup'
    };
    
    fprintf('Checking dependencies...\n');
    for i = 1:length(required_functions)
        func_name = required_functions{i};
        if exist(func_name, 'file')
            fprintf('  ✓ %s\n', func_name);
        else
            all_present = false;
            missing{end+1} = func_name;
            fprintf('  ✗ Missing: %s\n', func_name);
        end
    end
    
    if all_present
        fprintf('\nAll dependencies are present.\n');
    else
        fprintf('\nMissing dependencies: %s\n', strjoin(missing, ', '));
    end
end
