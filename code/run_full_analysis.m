% RUN_FULL_ANALYSIS - Main script to process data folder and generate outputs
%
% This script:
%   1. Reads all .dat files from the data folder
%   2. Performs aerodynamic calculations
%   3. Generates publishable graphs and visualizations
%   4. Creates summary reports
%
% Usage:
%   run_full_analysis()
%   run_full_analysis('data')  % Specify data folder
%   run_full_analysis('data', 'output')  % Specify data and output folders

function run_full_analysis(data_folder, output_folder)
    % RUN_FULL_ANALYSIS - Main script to process data folder and generate outputs
    %
    % This script automatically detects project paths and works from any location.
    %
    % Usage:
    %   run_full_analysis()  % Uses automatic path detection
    %   run_full_analysis(data_folder)  % Specify custom data folder
    %   run_full_analysis(data_folder, output_folder)  % Specify both folders
    
    % Validate setup first
    fprintf('Validating project setup...\n');
    [is_valid, issues] = validate_setup();
    if ~is_valid
        fprintf('\nWARNING: Setup validation found issues:\n');
        for i = 1:length(issues)
            fprintf('  - %s\n', issues{i});
        end
        fprintf('\nAttempting to continue anyway...\n\n');
    end
    
    % Use automatic path detection if folders not specified
    if nargin < 1 || isempty(data_folder)
        [~, ~, data_folder, output_folder] = get_project_paths();
    else
        if nargin < 2 || isempty(output_folder)
            [~, ~, ~, output_folder] = get_project_paths();
        end
        % Resolve relative paths
        if ~contains(data_folder, filesep) || ~exist(data_folder, 'dir')
            [~, ~, default_data_folder, ~] = get_project_paths();
            test_path = fullfile(default_data_folder, data_folder);
            if exist(test_path, 'dir')
                data_folder = test_path;
            end
        end
        if ~contains(output_folder, filesep)
            [project_root, ~, ~, ~] = get_project_paths();
            output_folder = fullfile(project_root, output_folder);
        end
    end
    
    fprintf('========================================\n');
    fprintf('AIRCRAFT FLIGHT STABILITY ANALYSIS\n');
    fprintf('========================================\n\n');
    fprintf('Data folder: %s\n', data_folder);
    fprintf('Output folder: %s\n\n', output_folder);
    
    % Create output folder structure
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    mkdir(fullfile(output_folder, 'figures'));
    mkdir(fullfile(output_folder, 'reports'));
    mkdir(fullfile(output_folder, 'data_summary'));
    
    % Step 1: Process data folder
    fprintf('Step 1: Processing data files...\n');
    fprintf('-----------------------------------\n');
    [all_data, file_list] = process_data_folder(data_folder);
    fprintf('\n');
    
    % Step 2: Perform aerodynamic calculations
    fprintf('Step 2: Performing aerodynamic calculations...\n');
    fprintf('-----------------------------------\n');
    results = perform_calculations(all_data);
    fprintf('\n');
    
    % Step 3: Generate visualizations
    fprintf('Step 3: Generating visualizations...\n');
    fprintf('-----------------------------------\n');
    create_visualizations(all_data, fullfile(output_folder, 'figures'));
    fprintf('\n');
    
    % Step 4: Generate detailed stability plots
    fprintf('Step 4: Generating detailed stability plots...\n');
    fprintf('-----------------------------------\n');
    generate_detailed_plots(all_data, results, fullfile(output_folder, 'figures'));
    fprintf('\n');
    
    % Step 5: Create summary report
    fprintf('Step 5: Creating summary report...\n');
    fprintf('-----------------------------------\n');
    create_summary_report(all_data, results, file_list, ...
                         fullfile(output_folder, 'reports'));
    fprintf('\n');
    
    % Step 6: Export data summary
    fprintf('Step 6: Exporting data summary...\n');
    fprintf('-----------------------------------\n');
    export_data_summary(all_data, file_list, ...
                       fullfile(output_folder, 'data_summary'));
    fprintf('\n');
    
    fprintf('========================================\n');
    fprintf('ANALYSIS COMPLETE!\n');
    fprintf('========================================\n');
    fprintf('Results saved to: %s\n', output_folder);
    fprintf('  - Figures: %s\n', fullfile(output_folder, 'figures'));
    fprintf('  - Reports: %s\n', fullfile(output_folder, 'reports'));
    fprintf('  - Data Summary: %s\n', fullfile(output_folder, 'data_summary'));
    fprintf('\n');
end

function results = perform_calculations(all_data)
    % Perform aerodynamic calculations on all data
    
    results = struct();
    results.total_files = length(all_data);
    results.coord_files = 0;
    results.coeff_files = 0;
    results.error_files = 0;
    
    % Default parameters for calculations
    default_params = struct();
    default_params.root_chord = 1.41;
    default_params.tip_chord = 1.41;
    default_params.wing_span = 1.0;
    default_params.wing_area = 1.41;
    default_params.wing_weight = 0.345;
    default_params.cg_fraction = 0.5;
    
    % Calculate MAC, AC, CG for default configuration
    MAC = default_params.root_chord;  % Rectangular wing
    AC_position = 0.25 * MAC;
    CG_position = default_params.cg_fraction * MAC;
    static_margin = AC_position - CG_position;
    
    results.default_config = struct();
    results.default_config.MAC = MAC;
    results.default_config.AC_position = AC_position;
    results.default_config.CG_position = CG_position;
    results.default_config.static_margin = static_margin;
    results.default_config.is_stable = static_margin > 0;
    
    % Count data types
    for i = 1:length(all_data)
        if isfield(all_data{i}, 'type')
            if strcmp(all_data{i}.type, 'coordinates')
                results.coord_files = results.coord_files + 1;
            elseif strcmp(all_data{i}.type, 'coefficients')
                results.coeff_files = results.coeff_files + 1;
            end
        end
        if isfield(all_data{i}, 'error')
            results.error_files = results.error_files + 1;
        end
    end
    
    fprintf('  Calculated MAC: %.4f m\n', MAC);
    fprintf('  AC Position: %.4f m (%.1f%% of MAC)\n', AC_position, 25.0);
    fprintf('  CG Position: %.4f m (%.1f%% of MAC)\n', CG_position, 50.0);
    fprintf('  Static Margin: %.4f m\n', static_margin);
    if results.default_config.is_stable
        fprintf('  Configuration: STABLE\n');
    else
        fprintf('  Configuration: UNSTABLE\n');
    end
end

function generate_detailed_plots(all_data, results, output_folder)
    % Generate detailed publication-quality plots
    
    % 1. Comprehensive airfoil comparison
    figure('Position', [100, 100, 1400, 900], 'Visible', 'off');
    
    % Find coordinate data
    coord_data = {};
    for i = 1:min(100, length(all_data))  % Limit to 100 for performance
        if isfield(all_data{i}, 'type') && strcmp(all_data{i}.type, 'coordinates')
            if isfield(all_data{i}, 'x') && ~isempty(all_data{i}.x)
                coord_data{end+1} = all_data{i};
            end
        end
    end
    
    if ~isempty(coord_data)
        subplot(2, 2, 1);
        hold on;
        colors = lines(min(length(coord_data), 20));
        for i = 1:min(20, length(coord_data))
            color_idx = mod(i-1, size(colors, 1)) + 1;
            plot(coord_data{i}.x, coord_data{i}.y, 'Color', colors(color_idx, :), ...
                 'LineWidth', 1.2);
        end
        axis equal;
        grid on;
        xlabel('x/c', 'FontSize', 12);
        ylabel('y/c', 'FontSize', 12);
        title('Airfoil Shape Comparison (Sample)', 'FontSize', 13, 'FontWeight', 'bold');
        hold off;
    end
    
    % 2. Coefficient data comparison
    subplot(2, 2, 2);
    coeff_data = {};
    for i = 1:min(50, length(all_data))
        if isfield(all_data{i}, 'type') && strcmp(all_data{i}.type, 'coefficients')
            if isfield(all_data{i}, 'alpha') && isfield(all_data{i}, 'cl')
                if ~isempty(all_data{i}.alpha) && ~isempty(all_data{i}.cl)
                    coeff_data{end+1} = all_data{i};
                end
            end
        end
    end
    
    if ~isempty(coeff_data)
        hold on;
        colors = lines(min(length(coeff_data), 10));
        for i = 1:min(10, length(coeff_data))
            color_idx = mod(i-1, size(colors, 1)) + 1;
            plot(coeff_data{i}.alpha, coeff_data{i}.cl, ...
                 'Color', colors(color_idx, :), 'LineWidth', 1.5);
        end
        grid on;
        xlabel('Angle of Attack', 'FontSize', 12);
        ylabel('Lift Coefficient (C_L)', 'FontSize', 12);
        title('Lift Coefficient Curves', 'FontSize', 13, 'FontWeight', 'bold');
        hold off;
    end
    
    % 3. Stability margin visualization
    subplot(2, 2, 3);
    cg_range = 0.1:0.05:0.9;
    ac_pos = 0.25;
    static_margins = ac_pos - cg_range;
    
    stable_idx = static_margins > 0;
    unstable_idx = static_margins <= 0;
    
    hold on;
    scatter(cg_range(stable_idx), static_margins(stable_idx), 100, 'g', 'filled', ...
            'DisplayName', 'Stable');
    scatter(cg_range(unstable_idx), static_margins(unstable_idx), 100, 'r', 'filled', ...
            'DisplayName', 'Unstable');
    plot([ac_pos, ac_pos], [min(static_margins)-0.1, max(static_margins)+0.1], ...
         'k--', 'LineWidth', 2, 'DisplayName', 'AC Position');
    plot([min(cg_range), max(cg_range)], [0, 0], 'k-', 'LineWidth', 1);
    xlabel('CG Position (fraction of MAC)', 'FontSize', 12);
    ylabel('Static Margin', 'FontSize', 12);
    title('Stability Map', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'best');
    grid on;
    hold off;
    
    % 4. Data processing summary
    subplot(2, 2, 4);
    categories = {'Coordinates', 'Coefficients', 'Errors'};
    counts = [results.coord_files, results.coeff_files, results.error_files];
    bar(counts, 'FaceColor', [0.2, 0.4, 0.8]);
    set(gca, 'XTickLabel', categories);
    ylabel('Count', 'FontSize', 12);
    title('Data File Distribution', 'FontSize', 13, 'FontWeight', 'bold');
    grid on;
    
    sgtitle('Aircraft Flight Stability Analysis - Comprehensive Results', ...
            'FontSize', 16, 'FontWeight', 'bold');
    
    saveas(gcf, fullfile(output_folder, 'comprehensive_analysis.png'), 'png');
    saveas(gcf, fullfile(output_folder, 'comprehensive_analysis.fig'), 'fig');
    close(gcf);
    
    fprintf('  Generated comprehensive analysis plot\n');
end

function create_summary_report(all_data, results, file_list, output_folder)
    % Create text summary report
    
    report_file = fullfile(output_folder, 'analysis_report.txt');
    fid = fopen(report_file, 'w');
    
    if fid == -1
        warning('Cannot create report file');
        return;
    end
    
    fprintf(fid, '========================================\n');
    fprintf(fid, 'AIRCRAFT FLIGHT STABILITY ANALYSIS REPORT\n');
    fprintf(fid, '========================================\n\n');
    fprintf(fid, 'Generated: %s\n\n', datestr(now));
    
    fprintf(fid, 'DATA PROCESSING SUMMARY\n');
    fprintf(fid, '-----------------------------------\n');
    fprintf(fid, 'Total files processed: %d\n', results.total_files);
    fprintf(fid, 'Coordinate files: %d\n', results.coord_files);
    fprintf(fid, 'Coefficient files: %d\n', results.coeff_files);
    fprintf(fid, 'Error files: %d\n', results.error_files);
    fprintf(fid, 'Success rate: %.1f%%\n\n', ...
            (results.total_files - results.error_files) / results.total_files * 100);
    
    fprintf(fid, 'AERODYNAMIC CALCULATIONS\n');
    fprintf(fid, '-----------------------------------\n');
    fprintf(fid, 'Mean Aerodynamic Chord (MAC): %.4f m\n', results.default_config.MAC);
    fprintf(fid, 'Aerodynamic Center (AC): %.4f m (25.0%% of MAC)\n', ...
            results.default_config.AC_position);
    fprintf(fid, 'Center of Gravity (CG): %.4f m (50.0%% of MAC)\n', ...
            results.default_config.CG_position);
    fprintf(fid, 'Static Margin: %.4f m\n', results.default_config.static_margin);
    if results.default_config.is_stable
        fprintf(fid, 'Configuration Status: STABLE\n\n');
    else
        fprintf(fid, 'Configuration Status: UNSTABLE\n\n');
    end
    
    fprintf(fid, 'STABILITY ANALYSIS\n');
    fprintf(fid, '-----------------------------------\n');
    fprintf(fid, 'The static margin is the distance between the aerodynamic center\n');
    fprintf(fid, 'and the center of gravity. A positive static margin indicates\n');
    fprintf(fid, 'static stability, meaning the aircraft will tend to return to\n');
    fprintf(fid, 'equilibrium after disturbances.\n\n');
    
    if results.default_config.static_margin > 0
        fprintf(fid, 'CONCLUSION: The current configuration is STABLE.\n');
        fprintf(fid, 'The CG is positioned ahead of the AC, providing positive\n');
        fprintf(fid, 'static stability.\n');
    else
        fprintf(fid, 'CONCLUSION: The current configuration is UNSTABLE.\n');
        fprintf(fid, 'The CG should be moved forward to achieve stability.\n');
    end
    
    fprintf(fid, '\n\n');
    fprintf(fid, 'FILES PROCESSED\n');
    fprintf(fid, '-----------------------------------\n');
    fprintf(fid, 'Total: %d files\n', length(file_list));
    fprintf(fid, 'Sample files (first 20):\n');
    for i = 1:min(20, length(file_list))
        fprintf(fid, '  %d. %s\n', i, file_list{i});
    end
    if length(file_list) > 20
        fprintf(fid, '  ... and %d more files\n', length(file_list) - 20);
    end
    
    fclose(fid);
    fprintf('  Created summary report: %s\n', report_file);
end

function export_data_summary(all_data, file_list, output_folder)
    % Export data summary to CSV
    
    csv_file = fullfile(output_folder, 'data_summary.csv');
    fid = fopen(csv_file, 'w');
    
    if fid == -1
        warning('Cannot create CSV file');
        return;
    end
    
    % Write header
    fprintf(fid, 'Filename,Name,Type,Has_X,Has_Y,Has_Alpha,Has_CL,Error\n');
    
    % Write data
    for i = 1:length(all_data)
        filename = file_list{i};
        name = '';
        data_type = 'unknown';
        has_x = 'No';
        has_y = 'No';
        has_alpha = 'No';
        has_cl = 'No';
        error_msg = '';
        
        if isfield(all_data{i}, 'name')
            name = all_data{i}.name;
        end
        if isfield(all_data{i}, 'type')
            data_type = all_data{i}.type;
        end
        if isfield(all_data{i}, 'x') && ~isempty(all_data{i}.x)
            has_x = 'Yes';
        end
        if isfield(all_data{i}, 'y') && ~isempty(all_data{i}.y)
            has_y = 'Yes';
        end
        if isfield(all_data{i}, 'alpha') && ~isempty(all_data{i}.alpha)
            has_alpha = 'Yes';
        end
        if isfield(all_data{i}, 'cl') && ~isempty(all_data{i}.cl)
            has_cl = 'Yes';
        end
        if isfield(all_data{i}, 'error')
            error_msg = all_data{i}.error;
        end
        
        % Escape commas in strings
        name = strrep(name, ',', ';');
        error_msg = strrep(error_msg, ',', ';');
        
        fprintf(fid, '%s,%s,%s,%s,%s,%s,%s,%s\n', ...
                filename, name, data_type, has_x, has_y, has_alpha, has_cl, error_msg);
    end
    
    fclose(fid);
    fprintf('  Exported data summary: %s\n', csv_file);
end
