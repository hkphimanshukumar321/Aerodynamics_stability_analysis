function aero = build_aero(p, sizing)
AR = p.geom.AR; e = p.aero.e_oswald;
aero.k = 1/(pi*e*AR);
aero.CD0 = p.aero.CD0;
aero.CLmax = p.aero.CLmax;

a0 = 2*pi; % thin-airfoil approx
aero.CLalpha = a0/(1 + a0/(pi*e*AR));

CL = linspace(-0.2, aero.CLmax, 200);
CD = aero.CD0 + aero.k.*CL.^2;

aero.polar.CL = CL;
aero.polar.CD = CD;

LD = CL./CD;
[aero.LDmax, idx] = max(LD);
aero.CL_LDmax = CL(idx);

aero.V_grid = linspace(0.5*sizing.Vs, 2.0*sizing.Vs, 100);
end
