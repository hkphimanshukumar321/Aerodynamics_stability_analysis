function data = read_aero_data(filename)
    % READ_AERO_DATA - Reads aerodynamic data from .dat files
    %
    % This function reads airfoil data files in various formats:
    %   - Airfoil coordinates (x, y pairs)
    %   - Coefficient data (CL vs alpha or similar)
    %
    % Input:
    %   filename: Path to .dat file
    %
    % Output:
    %   data: Structure containing:
    %     - name: Airfoil name
    %     - x: X coordinates (normalized chord)
    %     - y: Y coordinates (normalized chord)
    %     - alpha: Angle of attack (if coefficient data)
    %     - cl: Lift coefficient (if available)
    %     - cd: Drag coefficient (if available)
    %     - cm: Moment coefficient (if available)
    %     - type: 'coordinates' or 'coefficients'
    
    data = struct();
    data.name = '';
    data.x = [];
    data.y = [];
    data.alpha = [];
    data.cl = [];
    data.cd = [];
    data.cm = [];
    data.type = 'unknown';
    
    try
        % Resolve file path if relative (try multiple locations)
        if ~exist(filename, 'file')
            % Try relative to current directory
            if ~contains(filename, filesep)
                % Try to find in common locations
                try
                    [~, ~, data_folder, ~] = get_project_paths();
                    test_path = fullfile(data_folder, filename);
                    if exist(test_path, 'file')
                        filename = test_path;
                    end
                catch
                    % If get_project_paths fails, try current directory
                    if exist(fullfile(pwd, filename), 'file')
                        filename = fullfile(pwd, filename);
                    end
                end
            end
        end
        
        % Verify file exists
        if ~exist(filename, 'file')
            error('File not found: %s', filename);
        end
        
        % Read file
        fid = fopen(filename, 'r');
        if fid == -1
            error('Cannot open file: %s (check permissions)', filename);
        end
        
        % Read first line (usually airfoil name)
        first_line = fgetl(fid);
        if ischar(first_line)
            data.name = strtrim(first_line);
        end
        
        % Read data lines
        file_data = [];
        line_num = 0;
        while ~feof(fid)
            line = fgetl(fid);
            if ischar(line) && ~isempty(strtrim(line))
                line_num = line_num + 1;
                % Try to parse as numbers
                numbers = str2num(line); %#ok<ST2NM>
                if ~isempty(numbers) && length(numbers) >= 2
                    file_data = [file_data; numbers(1:min(2, length(numbers)))];
                end
            end
        end
        fclose(fid);
        
        if isempty(file_data)
            return;
        end
        
        % Determine data type based on value ranges
        % Airfoil coordinates: x typically 0-1, y typically -0.1 to 0.1
        % Coefficient data: first column might be > 1 (angle of attack in degrees)
        %                   or 0-1 (normalized), second column typically -1 to 1
        
        x_col = file_data(:, 1);
        y_col = file_data(:, 2);
        
        % Check if this looks like coefficient data
        % (angles of attack typically > 1, or if normalized, coefficients vary more)
        if max(abs(x_col)) > 1.5 || (max(abs(y_col)) > 0.5 && max(abs(x_col)) <= 1.1)
            % Likely coefficient data (alpha vs CL or similar)
            data.type = 'coefficients';
            data.alpha = x_col;
            data.cl = y_col;  % Assume CL, but could be other coefficient
            data.x = [];
            data.y = [];
        else
            % Likely airfoil coordinates
            data.type = 'coordinates';
            data.x = x_col;
            data.y = y_col;
            data.alpha = [];
            data.cl = [];
        end
        
    catch ME
        warning('Error reading file %s: %s', filename, ME.message);
        data = struct();
    end
end
