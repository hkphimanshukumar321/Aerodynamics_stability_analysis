function trim = trim_level_flight(p, aero, prop)
rho = p.env.rho; W = p.mass.W; S = p.geom.S;
V = p.test.V_trim;

trim.V  = V;
trim.CL = W/(0.5*rho*V^2*S);
trim.CD = CD0 + k*trim.CL^2;
trim.D  = 0.5*rho*V^2*S*trim.CD;

trim.T_available = prop.T_available(V);
trim.thrust_margin = trim.T_available - trim.D;

trim.P_req = trim.D*V/max(1e-6, prop.eta_prop);
trim.throttle_frac = min(1, trim.P_req/max(1e-6, p.prop.max_power_W));
end
