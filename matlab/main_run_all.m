function main_run_all()
% One-click runner: sizing + aero + trim + linear dynamics + plots.
clc; close all;
addpath(pwd); % parent folder is enough for +packages

p = config.load_params();
utils.check_params(p);

[sizing, mass_tbl] = sizing.compute_sizing(p);
aero = aero.build_aero(p, sizing);
prop = propulsion.build_propulsion(p);
trim = performance.trim_level_flight(p, aero, prop);
dyn  = dynamics.build_linear_models(p, aero, trim);
tests = dynamics.run_virtual_tests(p, dyn);

outdir = fullfile('..','results');
if ~exist(outdir,'dir'); mkdir(outdir); end

io.write_mass_table(fullfile(outdir,'mass_budget.csv'), mass_tbl);
io.write_struct(fullfile(outdir,'summary.json'), struct('params',p,'sizing',sizing,'aero',aero,'trim',trim,'dyn',dyn,'tests',tests));
plots.make_all_plots(outdir, p, sizing, aero, prop, trim, dyn, tests);

fprintf('\nDONE. Outputs written to: %s\n', outdir);
end
