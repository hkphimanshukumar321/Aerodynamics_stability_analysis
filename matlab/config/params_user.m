function p = params_user()
% Edit only this file. Units: m, kg, N, m^2, rad.

% Environment
p.env.rho = 1.225;
p.env.g   = 9.81;

% Geometry (update with your design)
p.geom.b = 1.05;          % span (m) [spec: 1050 mm]
p.geom.c = 0.228;        % mean chord (m) [estimated from appendix wing plan]
p.geom.S = p.geom.b*p.geom.c;
p.geom.AR = p.geom.b^2/p.geom.S;

% Masses (update)
p.mass.mtow     = 0.86;   % kg (MTOW limit per brief: 860 g)
p.mass.airframe = 0.56;   % kg (airframe limit per brief: 560 g, excluding battery)
p.mass.battery  = 0.18;   % kg (example 3S 2200 mAh class; adjust if you choose 2S/3S)
p.mass.payload  = 0.00;   % kg

% Inertia (leave [] to auto-estimate)
p.mass.inertia.Jx = [];
p.mass.inertia.Jy = [];
p.mass.inertia.Jz = [];

% CG target as fraction of chord (for report narrative)
p.cg.target_frac_c = 0.30;

% Aero (update CLmax later from XFLR5)
p.CLmax    = 1.2;
p.CD0      = 0.045;
p.e_oswald = 0.75;

% Rough stability/control scalars (virtual test model parameters)
p.cm_alpha = -0.6;
p.cm_q     = -8.0;
p.cl_p     = -0.5;
p.cn_r     = -0.2;
p.cy_beta  = -0.6;

p.ctrl.cm_de = -1.0;  % dCm/d(de) per rad
p.ctrl.cl_da =  0.08; % dCl/d(da) per rad
p.ctrl.cn_dr =  0.06; % dCn/d(dr) per rad

% Propulsion (update by datasheet or thrust test)
p.prop.static_thrust_N       = 9.0;   % N (datasheet/bench estimate for 2206 + 5–7" prop)
p.prop.thrust_drop_per_mps   = 0.20;  % N per (m/s)
p.prop.max_power_W           = 180;   % W
p.prop.eta_prop              = 0.55;

% Virtual test setup
p.test.V_trim    = 12.0;  % m/s (typical small trainer cruise; can be adjusted)
p.test.step_deg  = 5;     % deg
p.test.t_final   = 10;    % s
end
