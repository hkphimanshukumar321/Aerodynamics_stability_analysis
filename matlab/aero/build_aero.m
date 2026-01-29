function aero = build_aero(p, sizing)
AR = p.geom.AR; e = p.e_oswald;
k = 1/(pi*e*AR);
CD0 = p.CD0;
CLmax = p.CLmax;

a0 = 2*pi; % thin-airfoil approx
CLalpha = a0/(1 + a0/(pi*e*AR));

CL = linspace(-0.2, CLmax, 200);
CD = CD0 + k.*CL.^2;

polar.CL = CL;
polar.CD = CD;

LD = CL./CD;
[LDmax, idx] = max(LD);
CL_LDmax = CL(idx);

V_grid = linspace(0.5*Vs, 2.0*Vs, 100);
end
