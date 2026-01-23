% MATLAB script for aerodynamic calculations
% Calculates Mean Aerodynamic Chord (MAC), Aerodynamic Center (AC), and CG
% Supports online data intake from URLs (CSV, JSON, or text files)

function aero_calculations(online_data_url)
    % AEROCALCULATIONS - Main function for aerodynamic stability calculations
    %
    % This function calculates:
    %   - Mean Aerodynamic Chord (MAC): Average chord length weighted by area
    %   - Aerodynamic Center (AC): Point where pitching moment is constant
    %   - Center of Gravity (CG): Balance point of the aircraft
    %
    % Input:
    %   online_data_url (optional): URL to fetch aerodynamic data from
    %     Supported formats: CSV, JSON, or text files
    %     If not provided, uses default parameters
    %
    % Output:
    %   Displays calculated values and stability analysis
    
    % Default parameters (used if no online data provided)
    default_params = struct();
    default_params.root_chord = 1.41;      % Root chord (meters)
    default_params.tip_chord = 1.41;       % Tip chord (meters) - for rectangular wing
    default_params.wing_span = 1.0;        % Wing span (meters)
    default_params.wing_area = 1.41;      % Wing area (m^2)
    default_params.wing_weight = 0.345;    % Wing weight (kg)
    default_params.cg_fraction = 0.5;      % CG location as fraction of MAC
    
    % Check if online data URL is provided
    if nargin > 0 && ~isempty(online_data_url)
        fprintf('Fetching data from online source: %s\n', online_data_url);
        try
            params = fetch_online_data(online_data_url);
            fprintf('Successfully loaded online data.\n');
        catch ME
            fprintf('Warning: Failed to load online data. Using default parameters.\n');
            fprintf('Error: %s\n', ME.message);
            params = default_params;
        end
    else
        params = default_params;
        fprintf('Using default parameters. To use online data, provide a URL.\n');
    end
    
    % Calculate Mean Aerodynamic Chord (MAC)
    % For a rectangular wing: MAC = chord (since it's constant)
    % For a tapered wing: MAC = (2/3) * (root_chord + tip_chord - (root_chord*tip_chord)/(root_chord+tip_chord))
    if params.root_chord == params.tip_chord
        MAC = params.root_chord;  % Rectangular wing
    else
        MAC = (2/3) * (params.root_chord + params.tip_chord - ...
              (params.root_chord * params.tip_chord) / (params.root_chord + params.tip_chord));
    end
    
    % Calculate Aerodynamic Center (AC) position
    % For a flat plate, AC is typically at 25% of MAC from leading edge
    % For subsonic flow, AC is at approximately 25% chord
    AC_position_fraction = 0.25;  % 25% of MAC
    AC_position = AC_position_fraction * MAC;
    
    % Calculate Center of Gravity (CG) position
    CG_position = params.cg_fraction * MAC;
    
    % Calculate static margin (distance between CG and AC)
    static_margin = AC_position - CG_position;
    static_margin_fraction = static_margin / MAC;
    
    % Display results
    fprintf('\n=== AERODYNAMIC CALCULATIONS RESULTS ===\n');
    fprintf('Wing Geometry:\n');
    fprintf('  Root Chord: %.4f m\n', params.root_chord);
    fprintf('  Tip Chord: %.4f m\n', params.tip_chord);
    fprintf('  Wing Span: %.4f m\n', params.wing_span);
    fprintf('  Wing Area: %.4f m²\n', params.wing_area);
    fprintf('  Wing Weight: %.4f kg\n', params.wing_weight);
    fprintf('\nCalculated Parameters:\n');
    fprintf('  Mean Aerodynamic Chord (MAC): %.4f m\n', MAC);
    fprintf('  Aerodynamic Center (AC): %.4f m from leading edge (%.1f%% of MAC)\n', ...
            AC_position, AC_position_fraction * 100);
    fprintf('  Center of Gravity (CG): %.4f m from leading edge (%.1f%% of MAC)\n', ...
            CG_position, params.cg_fraction * 100);
    fprintf('  Static Margin: %.4f m (%.1f%% of MAC)\n', ...
            static_margin, static_margin_fraction * 100);
    
    % Stability analysis
    fprintf('\n=== STABILITY ANALYSIS ===\n');
    if static_margin > 0
        fprintf('✓ STABLE CONFIGURATION\n');
        fprintf('  CG is ahead of AC (positive static margin)\n');
        fprintf('  Aircraft will tend to return to equilibrium after disturbances\n');
    elseif static_margin < 0
        fprintf('✗ UNSTABLE CONFIGURATION\n');
        fprintf('  CG is behind AC (negative static margin)\n');
        fprintf('  Aircraft will diverge from equilibrium after disturbances\n');
    else
        fprintf('⚠ NEUTRAL STABILITY\n');
        fprintf('  CG coincides with AC (zero static margin)\n');
        fprintf('  Aircraft has neutral stability\n');
    end
    
    fprintf('\nAerodynamic calculations complete.\n');
end

function params = fetch_online_data(url)
    % FETCH_ONLINE_DATA - Fetches and parses aerodynamic data from online source
    %
    % Input:
    %   url: URL to fetch data from (CSV, JSON, or text format)
    %
    % Output:
    %   params: Structure containing aerodynamic parameters
    
    % Fetch data from URL
    try
        % Use webread for MATLAB or urlread for older versions
        if exist('webread', 'file')
            data = webread(url);
        else
            data = urlread(url);
        end
    catch
        error('Failed to fetch data from URL');
    end
    
    % Determine file type and parse accordingly
    [~, ~, ext] = fileparts(url);
    ext = lower(ext);
    
    params = struct();
    
    if contains(ext, 'json') || contains(url, 'json')
        % Parse JSON data
        if ischar(data) || isstring(data)
            data = jsondecode(data);
        end
        
        % Extract parameters from JSON structure
        if isfield(data, 'root_chord') || isfield(data, 'rootChord')
            params.root_chord = getfield_safe(data, {'root_chord', 'rootChord'});
        else
            params.root_chord = 1.41;
        end
        
        if isfield(data, 'tip_chord') || isfield(data, 'tipChord')
            params.tip_chord = getfield_safe(data, {'tip_chord', 'tipChord'});
        else
            params.tip_chord = params.root_chord;
        end
        
        if isfield(data, 'wing_span') || isfield(data, 'wingSpan')
            params.wing_span = getfield_safe(data, {'wing_span', 'wingSpan'});
        else
            params.wing_span = 1.0;
        end
        
        if isfield(data, 'wing_area') || isfield(data, 'wingArea')
            params.wing_area = getfield_safe(data, {'wing_area', 'wingArea'});
        else
            params.wing_area = params.root_chord * params.wing_span;
        end
        
        if isfield(data, 'wing_weight') || isfield(data, 'wingWeight')
            params.wing_weight = getfield_safe(data, {'wing_weight', 'wingWeight'});
        else
            params.wing_weight = 0.345;
        end
        
        if isfield(data, 'cg_fraction') || isfield(data, 'cgFraction')
            params.cg_fraction = getfield_safe(data, {'cg_fraction', 'cgFraction'});
        else
            params.cg_fraction = 0.5;
        end
        
    elseif contains(ext, 'csv') || contains(url, 'csv')
        % Parse CSV data
        if ischar(data) || isstring(data)
            % Read CSV - assume format: parameter,value
            lines = strsplit(data, '\n');
            for i = 1:length(lines)
                line = strtrim(lines{i});
                if isempty(line) || line(1) == '#', continue; end
                parts = strsplit(line, ',');
                if length(parts) >= 2
                    param_name = strtrim(parts{1});
                    param_value = str2double(strtrim(parts{2}));
                    if ~isnan(param_value)
                        switch lower(param_name)
                            case {'root_chord', 'rootchord', 'root chord'}
                                params.root_chord = param_value;
                            case {'tip_chord', 'tipchord', 'tip chord'}
                                params.tip_chord = param_value;
                            case {'wing_span', 'wingspan', 'wing span'}
                                params.wing_span = param_value;
                            case {'wing_area', 'wingarea', 'wing area'}
                                params.wing_area = param_value;
                            case {'wing_weight', 'wingweight', 'weight'}
                                params.wing_weight = param_value;
                            case {'cg_fraction', 'cgfraction', 'cg fraction', 'cg'}
                                params.cg_fraction = param_value;
                        end
                    end
                end
            end
        end
        
        % Set defaults for missing parameters
        if ~isfield(params, 'root_chord'), params.root_chord = 1.41; end
        if ~isfield(params, 'tip_chord'), params.tip_chord = params.root_chord; end
        if ~isfield(params, 'wing_span'), params.wing_span = 1.0; end
        if ~isfield(params, 'wing_area'), params.wing_area = params.root_chord * params.wing_span; end
        if ~isfield(params, 'wing_weight'), params.wing_weight = 0.345; end
        if ~isfield(params, 'cg_fraction'), params.cg_fraction = 0.5; end
        
    else
        % Try to parse as text with key-value pairs
        if ischar(data) || isstring(data)
            lines = strsplit(data, '\n');
            for i = 1:length(lines)
                line = strtrim(lines{i});
                if isempty(line) || line(1) == '#', continue; end
                % Look for pattern: key = value or key: value
                if contains(line, '=')
                    parts = strsplit(line, '=');
                elseif contains(line, ':')
                    parts = strsplit(line, ':');
                else
                    continue;
                end
                if length(parts) >= 2
                    param_name = strtrim(parts{1});
                    param_value = str2double(strtrim(parts{2}));
                    if ~isnan(param_value)
                        switch lower(param_name)
                            case {'root_chord', 'rootchord', 'root chord'}
                                params.root_chord = param_value;
                            case {'tip_chord', 'tipchord', 'tip chord'}
                                params.tip_chord = param_value;
                            case {'wing_span', 'wingspan', 'wing span'}
                                params.wing_span = param_value;
                            case {'wing_area', 'wingarea', 'wing area'}
                                params.wing_area = param_value;
                            case {'wing_weight', 'wingweight', 'weight'}
                                params.wing_weight = param_value;
                            case {'cg_fraction', 'cgfraction', 'cg fraction', 'cg'}
                                params.cg_fraction = param_value;
                        end
                    end
                end
            end
        end
        
        % Set defaults for missing parameters
        if ~isfield(params, 'root_chord'), params.root_chord = 1.41; end
        if ~isfield(params, 'tip_chord'), params.tip_chord = params.root_chord; end
        if ~isfield(params, 'wing_span'), params.wing_span = 1.0; end
        if ~isfield(params, 'wing_area'), params.wing_area = params.root_chord * params.wing_span; end
        if ~isfield(params, 'wing_weight'), params.wing_weight = 0.345; end
        if ~isfield(params, 'cg_fraction'), params.cg_fraction = 0.5; end
    end
end

function value = getfield_safe(data, field_names)
    % GETFIELD_SAFE - Safely gets field value trying multiple field name variations
    for i = 1:length(field_names)
        if isfield(data, field_names{i})
            value = data.(field_names{i});
            return;
        end
    end
    value = [];
end

% Example usage:
%   aero_calculations()                    % Use default parameters
%   aero_calculations('https://example.com/data.json')  % Fetch from URL
%   aero_calculations('https://example.com/data.csv')   % Fetch CSV from URL
