function check_params(p)
assert(p.env.rho>0,'Invalid rho');
assert(p.geom.S>0,'Invalid wing area');
assert(p.mass.mtow>0,'Invalid MTOW');
assert(p.aero.CLmax>0.2,'CLmax too low');
assert(p.prop.static_thrust_N>0,'Invalid thrust');
assert(p.test.t_final>0,'Invalid sim time');
end
