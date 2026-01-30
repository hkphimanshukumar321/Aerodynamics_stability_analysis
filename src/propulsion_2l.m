function prop = propulsion_2l(p)
%PROPULSION_2L Water rocket thrust model for a 2L PET bottle.
%
% Produces a thrust curve by simulating:
%   1) Water expulsion: Bernoulli nozzle flow + adiabatic air expansion
%   2) Air blowdown: compressible nozzle flow, isothermal bottle gas
%
% Returns struct prop with fields:
%   t [s], T [N], P [Pa], mdot [kg/s], m [kg], phase [string]
%   burnTime_s, totalImpulse_Ns

% --- Parameters
Pa = p.P_atm;
An = p.nozzle_area_m2;
Cd = p.discharge_coeff;
gamma = p.gamma;
rho_w = p.rho_water;
R = p.R;
dt = p.dt_prop_s;
Vb = p.bottle_volume_m3;
T_gas = p.T0_K;  % isothermal gas temperature during air blowdown

% --- Initial state
P = p.P0_Pa;
V_air = p.V_air0_m3;
m_w = p.m_water0_kg;
m_air = p.m_air0_kg;
t = 0.0;

% --- Storage
t_arr = zeros(0,1);
T_arr = zeros(0,1);
P_arr = zeros(0,1);
mdot_arr = zeros(0,1);
m_arr = zeros(0,1);
phase_arr = strings(0,1);

% --- Adiabatic invariant for water phase
K = P * (V_air^gamma);

% =========================
% 1) Water expulsion phase
% =========================
while (m_w > 1e-6) && (P > Pa*(1+1e-4))
    dp = max(P - Pa, 0);
    v_e = Cd * sqrt(2*dp/rho_w);
    mdot = rho_w * An * v_e;
    T = mdot * v_e;

    % log
    t_arr(end+1,1) = t;
    T_arr(end+1,1) = T;
    P_arr(end+1,1) = P;
    mdot_arr(end+1,1) = mdot;
    m_arr(end+1,1) = p.mass_dry_kg + m_w + m_air;
    phase_arr(end+1,1) = "water";

    % integrate
    dm = mdot * dt;
    m_w = max(m_w - dm, 0);
    V_air = min(Vb, V_air + dm/rho_w);
    P = K / (V_air^gamma);
    t = t + dt;

    % numerical guard
    if t > 10
        break;
    end
end

% =========================
% 2) Air blowdown phase
% =========================
while (m_air > 1e-7) && (P > Pa*(1+0.01))
    [mdot, Ve, Pe] = nozzle_air_flow(P, T_gas, Pa, An, gamma, R, Cd);
    T = mdot*Ve + (Pe - Pa)*An;

    % log
    t_arr(end+1,1) = t;
    T_arr(end+1,1) = T;
    P_arr(end+1,1) = P;
    mdot_arr(end+1,1) = mdot;
    m_arr(end+1,1) = p.mass_dry_kg + m_w + m_air;
    phase_arr(end+1,1) = "air";

    % integrate
    dm = mdot * dt;
    m_air = max(m_air - dm, 0);
    P = m_air * R * T_gas / Vb;
    t = t + dt;

    if t > 15
        break;
    end
end

% If simulation produced no points, error out (bad config)
if isempty(t_arr)
    error('Propulsion simulation produced empty output. Check configuration.');
end

% Finalize
prop.t = t_arr;
prop.T = T_arr;
prop.P = P_arr;
prop.mdot = mdot_arr;
prop.m = m_arr;
prop.phase = phase_arr;
prop.totalImpulse_Ns = trapz(prop.t, max(prop.T,0));

idx_last = find(prop.T > 1e-3, 1, 'last');
if isempty(idx_last)
    prop.burnTime_s = 0;
else
    prop.burnTime_s = prop.t(idx_last);
end

end
