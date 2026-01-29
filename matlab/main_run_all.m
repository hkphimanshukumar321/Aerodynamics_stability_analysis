function main_run_all()
% One-click runner: sizing + aero + trim + linear dynamics + 
clc; close all;
addpath(pwd); % parent folder is enough for +packages

p = load_params();
check_params(p);

[sizing, mass_tbl] = compute_sizing(p);
aero = build_aero(p, sizing);
prop = build_propulsion(p);
trim = trim_level_flight(p, aero, prop);
dyn  = build_linear_models(p, aero, trim);
tests = run_virtual_tests(p, dyn);

outdir = fullfile('..','results');
if ~exist(outdir,'dir'); mkdir(outdir); end

write_mass_table(fullfile(outdir,'mass_budget.csv'), mass_tbl);
write_struct(fullfile(outdir,'summary.json'), struct('params',p,'sizing',sizing,'aero',aero,'trim',trim,'dyn',dyn,'tests',tests));
make_all_plots(outdir, p, sizing, aero, prop, trim, dyn, tests);

fprintf('\nDONE. Outputs written to: %s\n', outdir);
end
