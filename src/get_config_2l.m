function p = get_config_2l(caseName)
%GET_CONFIG_2L  Configuration for a 2L PET bottle water rocket.
%
% Units are SI.

if nargin < 1
    caseName = 'A';
end
caseName = upper(string(caseName));

%% Physical constants
p.g = 9.80665;            % m/s^2
p.rho_air = 1.225;        % kg/m^3
p.rho_water = 1000;       % kg/m^3
p.P_atm = 101325;         % Pa
p.gamma = 1.4;            % air adiabatic index
p.R = 287.05;             % J/(kg*K)

%% Rocket geometry (2L bottle baseline)
% Typical 2L bottle length ~0.32 m, diameter ~0.105 m (varies by brand).
%
% Coordinate x is along the rocket axis from nozzle (tail) to nose.

p.bottle_volume_m3 = 2.0e-3;       % 2 L
p.body_diameter_m = 0.105;         % m
p.body_length_m = 0.32;            % m
p.ref_area_m2 = pi*(p.body_diameter_m/2)^2;

% Nozzle
p.nozzle_diameter_m = 0.021;       % m (typical water rocket nozzle)
p.nozzle_area_m2 = pi*(p.nozzle_diameter_m/2)^2;
p.discharge_coeff = 0.95;          % nozzle discharge coeff

%% Mass properties
p.mass_dry_kg = 0.15;              % bottle + fins + payload (tune)

% Approximate dry mass CG location (from nozzle), in meters
p.x_cg_dry_m = 0.20;

%% Aerodynamics
p.Cd = 0.55;                       % constant drag coefficient (tune/sweep)

%% Launch conditions
p.launch_elevation_deg = 45;       % degrees above horizontal
p.launch_azimuth_deg = 0;          % degrees (yaw); 0 -> +x
p.rail_length_m = 1.0;             % launch rail length
p.launch_height_m = 0.2;           % initial z

% Wind model (constant wind in inertial frame)
p.wind_mps = [0; 0; 0];            % [wx; wy; wz]

%% Fin geometry (for CP approximation)
% Simple trapezoidal fins (4 fins assumed)
p.num_fins = 4;
p.fin_span_m = 0.06;               % m
p.fin_root_chord_m = 0.08;         % m
p.fin_tip_chord_m = 0.04;          % m
p.fin_le_x_m = 0.23;               % leading edge position from nozzle

%% Case-specific propulsion settings
switch caseName
    case 'A'
        p.water_fill_fraction = 0.35;     % fraction of bottle volume filled with water
        p.P_gauge_Pa = 4.0e5;             % gauge pressure (Pa) above atmosphere
    case 'B'
        p.water_fill_fraction = 0.30;
        p.P_gauge_Pa = 5.0e5;
    case 'C'
        p.water_fill_fraction = 0.40;
        p.P_gauge_Pa = 3.5e5;
    otherwise
        error('Unknown caseName. Use A, B, or C.');
end

% Derived initial states
p.P0_Pa = p.P_atm + p.P_gauge_Pa;
p.V_water0_m3 = p.water_fill_fraction * p.bottle_volume_m3;
p.V_air0_m3 = p.bottle_volume_m3 - p.V_water0_m3;
p.m_water0_kg = p.rho_water * p.V_water0_m3;

% Initial air mass (ideal gas at assumed room temperature)
p.T0_K = 293.15;
p.m_air0_kg = p.P0_Pa * p.V_air0_m3 / (p.R * p.T0_K);

% Thrust model integration step
p.dt_prop_s = 1e-3;

% Trajectory integration max time
p.t_max_s = 30;

% Safety checks
validate_config(p);
end

function validate_config(p)
req = {'g','rho_air','rho_water','P_atm','gamma','R','bottle_volume_m3','body_diameter_m','body_length_m',...
    'nozzle_area_m2','discharge_coeff','mass_dry_kg','Cd','launch_elevation_deg','launch_azimuth_deg','rail_length_m',...
    'P0_Pa','V_air0_m3','V_water0_m3','m_water0_kg','m_air0_kg'};
for k=1:numel(req)
    if ~isfield(p, req{k})
        error('Missing required config field: %s', req{k});
    end
end
if p.V_air0_m3 <= 0 || p.V_water0_m3 < 0
    error('Invalid initial volumes.');
end
if p.nozzle_area_m2 <= 0
    error('Nozzle area must be positive.');
end
end
