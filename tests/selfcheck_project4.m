%% Self-checks for Project 4
% Run AFTER running src/main_project4.m, or run standalone.

clear; clc;

p = uav_params_project4();
g = compute_geometry(p);

% Basic geometry sanity
assert(g.lambda > 0 && g.lambda < 1, "Taper ratio should be (0,1) for this wing.");
assert(g.S > 0, "Planform area must be positive.");
assert(g.AR > 0, "Aspect ratio must be positive.");
assert(g.k > 0, "Induced drag factor k must be positive.");

% Check trim and level flight at a representative alpha
alpha_test = deg2rad(6);
out = trim_at_alpha(p, g, alpha_test);
assert(out.valid, "Expected valid trim at alpha=6 deg.");
assert(out.CL > 0, "Expected positive CL.");
assert(out.V > 0, "Expected positive V.");
assert(out.Tr > 0 && out.Pr > 0, "Expected positive thrust and power required.");

% Check trim condition Cm=0 (numerical)
Cm = p.Cm0 + p.Cm_alpha*alpha_test + p.Cm_de*out.de_trim;
assert(abs(Cm) < 1e-12, "Trim condition Cm=0 failed numerically.");

disp("All self-checks PASSED.");
