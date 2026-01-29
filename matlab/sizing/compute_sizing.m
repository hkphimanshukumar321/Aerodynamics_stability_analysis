function [sizing, mass_tbl] = compute_sizing(p)
W = p.mass.W; S = p.geom.S; rho = p.env.rho;

WS = W/S;
TW_static = p.prop.static_thrust_N/W;

CLmax = p.CLmax;
Vs = sqrt((2*W)/(rho*S*CLmax));
V_to = 1.2*Vs;

names = {'Airframe','Battery','Payload','Total'};
masses = [p.mass.airframe; p.mass.battery; p.mass.payload; p.mass.airframe+p.mass.battery+p.mass.payload];
mass_tbl = table(names(:), masses(:), 'VariableNames', {'Item','Mass_kg'});

m_total = masses(end);
W_total = m_total*p.env.g;
end
