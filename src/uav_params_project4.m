function p = uav_params_project4()
%UAV_PARAMS_PROJECT4  Centralized parameters for Project 4.
%   Returns struct p with geometry, aero coefficients, and flight constants.
%
%   Units:
%     Length: m
%     Mass: kg
%     Density: kg/m^3
%     g: m/s^2
%     Angles: radians

% --------------------------
% Geometry (given)
% --------------------------
p.Cr = 0.9;      % root chord [m]
p.Ct = 0.15;     % tip chord  [m]
p.b  = 1.5;      % span       [m]
p.e  = 0.89;     % Oswald efficiency factor [-]

% --------------------------
% Aerodynamic coefficients (given)
% --------------------------
p.CD0     = 0.03;
p.Cm0     = 0.01;

p.CL_alpha = 2.92;   % per rad
p.CL_de    = 0.265;  % per rad (assumed, as typical derivative)

p.Cm_alpha = -0.292; % per rad
p.Cm_de    = -0.4;   % per rad

% NOTE: Assignment sheet shows "CL = CL0 + CL_alpha*alpha + CL_de*de".
% If CL0 is not specified, we assume CL0 = 0.
p.CL0 = 0.0;

% --------------------------
% Flight conditions (given)
% --------------------------
p.m   = 3.5;     % mass [kg]
p.g   = 10.0;    % gravity [m/s^2] (use given)
p.rho = 1.225;   % sea-level density [kg/m^3]

% Computed weight
p.W = p.m * p.g; % [N]

% --------------------------
% Sweep definition (given)
% --------------------------
p.alpha_deg = 0:0.5:12;   % [deg]
p.alpha_rad = deg2rad(p.alpha_deg);

end
