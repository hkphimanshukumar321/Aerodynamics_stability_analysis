function [sizing, mass_tbl] = compute_sizing(p)
W = p.mass.W; S = p.geom.S; rho = p.env.rho;

sizing.WS = W/S;
sizing.TW_static = p.prop.static_thrust_N/W;

CLmax = p.aero.CLmax;
sizing.Vs = sqrt((2*W)/(rho*S*CLmax));
sizing.V_to = 1.2*sizing.Vs;

names = {'Airframe','Battery','Payload','Total'};
masses = [p.mass.airframe; p.mass.battery; p.mass.payload; p.mass.airframe+p.mass.battery+p.mass.payload];
mass_tbl = table(names(:), masses(:), 'VariableNames', {'Item','Mass_kg'});

sizing.m_total = masses(end);
sizing.W_total = sizing.m_total*p.env.g;
end
