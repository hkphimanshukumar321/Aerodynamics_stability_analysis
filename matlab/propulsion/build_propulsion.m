function prop = build_propulsion(p)
prop.T0 = p.prop.static_thrust_N;
prop.kV = p.prop.thrust_drop_per_mps;
prop.max_power_W = p.prop.max_power_W;
prop.eta_prop = p.prop.eta_prop;
prop.T_available = @(V) max(0, prop.T0 - prop.kV.*V);
end
