function run_all()
% One-command MATLAB pipeline (Steps 4–5).
% Run AFTER:
%   python 6_simulation/run_all.py
repo_root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(repo_root,'3_structure'));
addpath(fullfile(repo_root,'4_dynamics'));
beam_spar_analysis(repo_root);
motor_mount_stress(repo_root);
tailsitter_6dof(repo_root);
fprintf('[run_all.m] Complete. Check report/artifacts/\n');
end
