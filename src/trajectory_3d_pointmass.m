function traj = trajectory_3d_pointmass(p, prop)
%TRAJECTORY_3D_POINTMASS 3D point-mass rocket flight simulation.
%
% State: [x y z vx vy vz]
% Forces: thrust (from prop), drag, gravity.
% - During launch rail phase: thrust direction fixed to rail.
% - After rail: thrust direction aligned with velocity (practical approximation).
%
% Outputs struct traj with fields t, x, y, z, vx, vy, vz, v, apogee_m, ...

% Precompute thrust and mass interpolants
T_of_t = @(tq) interp1(prop.t, prop.T, tq, 'linear', 0);
m_of_t = @(tq) interp1(prop.t, prop.m, tq, 'linear', prop.m(end));

% Launch orientation
el = deg2rad(p.launch_elevation_deg);
az = deg2rad(p.launch_azimuth_deg);
rail_dir = [cos(el)*cos(az); cos(el)*sin(az); sin(el)];
rail_dir = rail_dir / norm(rail_dir);

% Initial state
x0 = 0; y0 = 0; z0 = p.launch_height_m;
v0 = 0;  % start at rest on rail
s0 = [x0; y0; z0; 0; 0; 0];

% ODE integration
opts = odeset('Events', @(t,s) ground_event(t,s));
[t_out, s_out] = ode45(@(t,s) eom(t,s,T_of_t,m_of_t,rail_dir,p), [0 p.t_max_s], s0, opts);

x = s_out(:,1);
y = s_out(:,2);
z = s_out(:,3);
vx = s_out(:,4);
vy = s_out(:,5);
vz = s_out(:,6);
v = sqrt(vx.^2 + vy.^2 + vz.^2);

[apogee_m, idxA] = max(z);
t_apogee = t_out(idxA);
t_land = t_out(end);

traj.t = t_out;
traj.x = x;
traj.y = y;
traj.z = z;
traj.vx = vx;
traj.vy = vy;
traj.vz = vz;
traj.v = v;
traj.apogee_m = apogee_m;
traj.t_apogee_s = t_apogee;
traj.t_land_s = t_land;

end

function ds = eom(t, s, T_of_t, m_of_t, rail_dir, p)
% Equations of motion
x = s(1); y = s(2); z = s(3); %#ok<NASGU>
v = s(4:6);

m = max(m_of_t(t), 1e-6);
T = max(T_of_t(t), 0);

% Determine thrust direction
pos = [x; y; z];
rail_progress = dot(pos - [0;0;p.launch_height_m], rail_dir);

if rail_progress < p.rail_length_m
    uT = rail_dir;
else
    if norm(v) > 1e-3
        uT = v / norm(v);
    else
        uT = rail_dir;
    end
end

Fthrust = T * uT;

% Aerodynamic drag (relative to wind)
v_rel = v - p.wind_mps;
vrel_mag = norm(v_rel);
if vrel_mag > 1e-6
    Fdrag = -0.5 * p.rho_air * p.Cd * p.ref_area_m2 * vrel_mag^2 * (v_rel / vrel_mag);
else
    Fdrag = [0;0;0];
end

Fgrav = [0; 0; -m*p.g];

acc = (Fthrust + Fdrag + Fgrav) / m;

ds = zeros(6,1);
ds(1:3) = v;
ds(4:6) = acc;
end

function [value, isterminal, direction] = ground_event(~, s)
% Event: stop when z hits ground (z <= 0) after launch
z = s(3);
value = z;
isterminal = 1;
direction = -1;
end
