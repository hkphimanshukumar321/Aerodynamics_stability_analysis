function stab = stability_cg_cp_2l(p)
%STABILITY_CG_CP_2L CG-CP and static margin (calibers) for full vs empty.
%
% Coordinate x is along the rocket axis from nozzle (tail) to nose.
% CP uses a Barrowman-lite approximation (body + fins) for report evidence.

D = p.body_diameter_m;
L = p.body_length_m;

% --- CG model (dry structure + water)
m_dry = p.mass_dry_kg;
x_dry = p.x_cg_dry_m;

% Approximate water column length inside bottle
A_body = pi*(D/2)^2;
Vw0 = p.V_water0_m3;
lw = min(L, Vw0 / A_body);

% Water CG from nozzle: assume water is from nozzle up to length lw
m_w0 = p.m_water0_kg;
x_w = 0.5 * lw;

x_cg_full = (m_dry*x_dry + m_w0*x_w) / (m_dry + m_w0);
x_cg_empty = x_dry;  % no water

% --- CP model (Barrowman-lite)
% Body contribution: for a simple slender body, CP ~ mid-length
x_cp_body = 0.5 * L;
CNa_body = 2.0;  % coarse constant for weighting

% Fin geometry (trapezoid)
N = p.num_fins;
span = p.fin_span_m;
cr = p.fin_root_chord_m;
ct = p.fin_tip_chord_m;
x_le = p.fin_le_x_m;

S = 0.5 * (cr + ct) * span;         % area per fin
AR = (span^2) / S;                 % aspect ratio
beta = 1.0;                          % low-speed

% Approx normal force slope (finite wing) - simplified
CNa_fin = (2*pi*AR) / (2 + sqrt(4 + (AR*beta/pi)^2));
CNa_fins = N * CNa_fin * (S / (pi*(D/2)^2));

% Fin CP (mean aerodynamic chord quarter-chord) location
mac = (2/3) * (cr + ct - (cr*ct)/(cr+ct));
% distance from fin leading edge to MAC quarter-chord for trapezoid
x_cp_fin = x_le + 0.25 * mac;

% Combine CP weighted by normal-force slopes
CNa_total = CNa_body + CNa_fins;
x_cp = (CNa_body*x_cp_body + CNa_fins*x_cp_fin) / CNa_total;

% Static margins (calibers)
SM_full = (x_cp - x_cg_full) / D;
SM_empty = (x_cp - x_cg_empty) / D;

stab = struct();
stab.x_cg_full_m = x_cg_full;
stab.x_cg_empty_m = x_cg_empty;
stab.x_cp_m = x_cp;
stab.SM_full_calibers = SM_full;
stab.SM_empty_calibers = SM_empty;
stab.body_diameter_m = D;
stab.body_length_m = L;
stab.water_fill_fraction = p.water_fill_fraction;
stab.P0_Pa = p.P0_Pa;

end
