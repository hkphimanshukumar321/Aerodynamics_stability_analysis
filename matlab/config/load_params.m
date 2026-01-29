function p = load_params()
p = params_user();
p.geom.MAC = p.geom.c;
p.mass.W   = p.mass.mtow * p.env.g;
end
