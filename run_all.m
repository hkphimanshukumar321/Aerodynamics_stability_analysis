function run_all()
% RUN_ALL  End-to-end pipeline: test -> plan -> simulate -> save results.
%
% Usage:
%   run_all

clc; close all;

addpath(genpath(fullfile(pwd, 'src')));
addpath(genpath(fullfile(pwd, 'sim')));

cfg = sim_config();

fprintf('[1/4] Running self-tests...\n');
self_test(cfg);

fprintf('[2/4] Planning pick-and-place (IK for waypoints)...\n');
plan = plan_pick_place(cfg);

fprintf('[3/4] Generating trajectories...\n');
traj = generate_trajectories(cfg, plan);

fprintf('[4/4] Simulating + exporting results...\n');
simulate_and_export(cfg, plan, traj);

fprintf('\nDONE. See results/ folder.\n');
end
