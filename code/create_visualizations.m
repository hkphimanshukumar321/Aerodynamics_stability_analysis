function create_visualizations(all_data, output_folder, selected_files)
    % CREATE_VISUALIZATIONS - Generates publishable graphs and visualizations
    %
    % Input:
    %   all_data: Cell array of data structures from process_data_folder
    %   output_folder: (optional) Folder to save figures
    %                 If not provided, uses project output folder
    %   selected_files: (optional) Indices or names of specific files to plot
    
    % Use automatic path detection if output folder not specified
    if nargin < 2 || isempty(output_folder)
        [~, ~, ~, output_folder] = get_project_paths();
        output_folder = fullfile(output_folder, 'figures');
    else
        % Resolve relative paths
        if ~contains(output_folder, filesep)
            [project_root, ~, ~, ~] = get_project_paths();
            output_folder = fullfile(project_root, output_folder);
        end
    end
    
    if nargin < 3
        selected_files = [];
    end
    
    % Create output folder if it doesn't exist
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    
    % Separate coordinate and coefficient data
    coord_data = {};
    coeff_data = {};
    coord_names = {};
    coeff_names = {};
    
    for i = 1:length(all_data)
        if isfield(all_data{i}, 'type')
            if strcmp(all_data{i}.type, 'coordinates')
                coord_data{end+1} = all_data{i};
                coord_names{end+1} = all_data{i}.name;
            elseif strcmp(all_data{i}.type, 'coefficients')
                coeff_data{end+1} = all_data{i};
                coeff_names{end+1} = all_data{i}.name;
            end
        end
    end
    
    fprintf('Found %d coordinate files and %d coefficient files\n', ...
            length(coord_data), length(coeff_data));
    
    % 1. Plot airfoil shapes (sample of first 20)
    if ~isempty(coord_data)
        plot_airfoil_shapes(coord_data(1:min(20, length(coord_data))), output_folder);
    end
    
    % 2. Plot coefficient curves
    if ~isempty(coeff_data)
        plot_coefficient_curves(coeff_data, output_folder);
    end
    
    % 3. Statistical summary plots
    plot_statistics(all_data, output_folder);
    
    % 4. Stability analysis visualization
    plot_stability_analysis(all_data, output_folder);
    
    fprintf('Visualizations saved to %s\n', output_folder);
end

function plot_airfoil_shapes(coord_data, output_folder)
    % Plot airfoil coordinate shapes
    figure('Position', [100, 100, 1200, 800], 'Visible', 'off');
    
    num_plots = min(length(coord_data), 20);
    cols = 5;
    rows = ceil(num_plots / cols);
    
    for i = 1:num_plots
        subplot(rows, cols, i);
        if isfield(coord_data{i}, 'x') && ~isempty(coord_data{i}.x)
            plot(coord_data{i}.x, coord_data{i}.y, 'b-', 'LineWidth', 1.5);
            axis equal;
            grid on;
            title(strrep(coord_data{i}.name, '_', '\_'), 'FontSize', 8);
            xlabel('x/c', 'FontSize', 7);
            ylabel('y/c', 'FontSize', 7);
            xlim([-0.1, 1.1]);
        end
    end
    
    sgtitle('Airfoil Coordinate Shapes (Sample)', 'FontSize', 14, 'FontWeight', 'bold');
    saveas(gcf, fullfile(output_folder, 'airfoil_shapes.png'), 'png');
    saveas(gcf, fullfile(output_folder, 'airfoil_shapes.fig'), 'fig');
    close(gcf);
end

function plot_coefficient_curves(coeff_data, output_folder)
    % Plot lift coefficient vs angle of attack
    figure('Position', [100, 100, 1000, 600], 'Visible', 'off');
    
    hold on;
    colors = lines(min(length(coeff_data), 10));
    
    for i = 1:min(length(coeff_data), 50)  % Limit to 50 for readability
        if isfield(coeff_data{i}, 'alpha') && isfield(coeff_data{i}, 'cl')
            if ~isempty(coeff_data{i}.alpha) && ~isempty(coeff_data{i}.cl)
                color_idx = mod(i-1, size(colors, 1)) + 1;
                plot(coeff_data{i}.alpha, coeff_data{i}.cl, ...
                     'Color', colors(color_idx, :), 'LineWidth', 1.5, ...
                     'DisplayName', strrep(coeff_data{i}.name, '_', '\_'));
            end
        end
    end
    
    grid on;
    xlabel('Angle of Attack (normalized or degrees)', 'FontSize', 12);
    ylabel('Lift Coefficient (C_L)', 'FontSize', 12);
    title('Lift Coefficient vs Angle of Attack', 'FontSize', 14, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 8);
    hold off;
    
    saveas(gcf, fullfile(output_folder, 'coefficient_curves.png'), 'png');
    saveas(gcf, fullfile(output_folder, 'coefficient_curves.fig'), 'fig');
    close(gcf);
end

function plot_statistics(all_data, output_folder)
    % Create statistical summary plots
    figure('Position', [100, 100, 1200, 800], 'Visible', 'off');
    
    % Count data types
    coord_count = 0;
    coeff_count = 0;
    error_count = 0;
    
    for i = 1:length(all_data)
        if isfield(all_data{i}, 'type')
            if strcmp(all_data{i}.type, 'coordinates')
                coord_count = coord_count + 1;
            elseif strcmp(all_data{i}.type, 'coefficients')
                coeff_count = coeff_count + 1;
            end
        end
        if isfield(all_data{i}, 'error')
            error_count = error_count + 1;
        end
    end
    
    % Pie chart of data types
    subplot(2, 2, 1);
    pie([coord_count, coeff_count, error_count], ...
        {'Coordinates', 'Coefficients', 'Errors'});
    title('Data Type Distribution', 'FontSize', 12, 'FontWeight', 'bold');
    
    % Bar chart
    subplot(2, 2, 2);
    bar([coord_count, coeff_count, error_count]);
    set(gca, 'XTickLabel', {'Coordinates', 'Coefficients', 'Errors'});
    ylabel('Count', 'FontSize', 11);
    title('Data Type Counts', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;
    
    % File processing success rate
    subplot(2, 2, 3);
    success_rate = (length(all_data) - error_count) / length(all_data) * 100;
    bar([success_rate, 100 - success_rate]);
    set(gca, 'XTickLabel', {'Success', 'Failed'});
    ylabel('Percentage', 'FontSize', 11);
    title(sprintf('Processing Success Rate: %.1f%%', success_rate), ...
          'FontSize', 12, 'FontWeight', 'bold');
    ylim([0, 100]);
    grid on;
    
    % Total files processed
    subplot(2, 2, 4);
    text(0.5, 0.5, sprintf('Total Files Processed:\n%d', length(all_data)), ...
         'FontSize', 16, 'FontWeight', 'bold', ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    axis off;
    
    sgtitle('Data Processing Statistics', 'FontSize', 14, 'FontWeight', 'bold');
    
    saveas(gcf, fullfile(output_folder, 'statistics.png'), 'png');
    saveas(gcf, fullfile(output_folder, 'statistics.fig'), 'fig');
    close(gcf);
end

function plot_stability_analysis(all_data, output_folder)
    % Create stability analysis visualization
    figure('Position', [100, 100, 1000, 700], 'Visible', 'off');
    
    % Calculate stability parameters for coefficient data
    cg_positions = 0.3:0.1:0.7;  % Various CG positions
    ac_position = 0.25;  % Standard AC position
    
    subplot(2, 2, 1);
    static_margins = ac_position - cg_positions;
    plot(cg_positions, static_margins, 'b-o', 'LineWidth', 2, 'MarkerSize', 8);
    hold on;
    plot([ac_position, ac_position], [min(static_margins)-0.05, max(static_margins)+0.05], ...
         'r--', 'LineWidth', 2, 'DisplayName', 'AC Position');
    plot([min(cg_positions), max(cg_positions)], [0, 0], 'k--', 'LineWidth', 1);
    xlabel('CG Position (fraction of MAC)', 'FontSize', 11);
    ylabel('Static Margin', 'FontSize', 11);
    title('Static Margin vs CG Position', 'FontSize', 12, 'FontWeight', 'bold');
    legend('Static Margin', 'AC Position', 'Neutral', 'Location', 'best');
    grid on;
    hold off;
    
    % Stability region diagram
    subplot(2, 2, 2);
    fill([0, ac_position, ac_position, 0], [1, 1, 0, 0], 'g', 'FaceAlpha', 0.3, ...
         'DisplayName', 'Stable Region');
    hold on;
    fill([ac_position, 1, 1, ac_position], [1, 1, 0, 0], 'r', 'FaceAlpha', 0.3, ...
         'DisplayName', 'Unstable Region');
    plot([ac_position, ac_position], [0, 1], 'k--', 'LineWidth', 2, ...
         'DisplayName', 'AC Position');
    xlabel('CG Position (fraction of MAC)', 'FontSize', 11);
    ylabel('Normalized', 'FontSize', 11);
    title('Stability Region Diagram', 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'best');
    xlim([0, 1]);
    ylim([0, 1]);
    grid on;
    hold off;
    
    % Sample stability analysis for different configurations
    subplot(2, 2, 3);
    sample_cg = [0.2, 0.3, 0.4, 0.5, 0.6];
    sample_ac = 0.25;
    stability = sample_cg < sample_ac;
    bar(sample_cg, double(stability), 'FaceColor', [0.2, 0.6, 0.2]);
    hold on;
    plot([sample_ac, sample_ac], [0, 1.2], 'r--', 'LineWidth', 2);
    xlabel('CG Position', 'FontSize', 11);
    ylabel('Stability (1=Stable, 0=Unstable)', 'FontSize', 11);
    title('Stability vs CG Position', 'FontSize', 12, 'FontWeight', 'bold');
    ylim([-0.1, 1.2]);
    grid on;
    hold off;
    
    % MAC calculation visualization
    subplot(2, 2, 4);
    root_chord = 1.41;
    tip_chord = 1.41;
    MAC = root_chord;  % For rectangular wing
    x_mac = [0, MAC, MAC, 0];
    y_mac = [-0.1, -0.1, 0.1, 0.1];
    fill(x_mac, y_mac, 'b', 'FaceAlpha', 0.3);
    hold on;
    plot([MAC*0.25, MAC*0.25], [-0.15, 0.15], 'r-', 'LineWidth', 3, ...
         'DisplayName', 'AC (25% MAC)');
    plot([MAC*0.5, MAC*0.5], [-0.15, 0.15], 'g-', 'LineWidth', 3, ...
         'DisplayName', 'CG (50% MAC)');
    xlabel('Distance from Leading Edge (m)', 'FontSize', 11);
    ylabel('Normalized', 'FontSize', 11);
    title('Mean Aerodynamic Chord (MAC)', 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'best');
    grid on;
    hold off;
    
    sgtitle('Aircraft Stability Analysis', 'FontSize', 14, 'FontWeight', 'bold');
    
    saveas(gcf, fullfile(output_folder, 'stability_analysis.png'), 'png');
    saveas(gcf, fullfile(output_folder, 'stability_analysis.fig'), 'fig');
    close(gcf);
end
