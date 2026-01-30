function run_all(caseName)
%RUN_ALL  End-to-end evidence generation for a 2L water rocket.
%
% Usage:
%   run_all('A')   % predefined case A
%   run_all('B')
%   run_all('C')
%
% Outputs saved to ./results

if nargin < 1
    caseName = 'A';
end

addpath(fullfile(pwd,'src'));

p = get_config_2l(caseName);
resultsDir = fullfile(pwd,'results');
if ~exist(resultsDir,'dir'); mkdir(resultsDir); end

fprintf('--- Water Rocket MATLAB Simulation (case %s) ---\n', caseName);

%% 1) Propulsion simulation
prop = propulsion_2l(p);

% Save propulsion table
Tp = table(prop.t(:), prop.T(:), prop.P(:), prop.mdot(:), prop.m(:), string(prop.phase(:)), ...
    'VariableNames', {'t_s','Thrust_N','Pressure_Pa','mdot_kgps','mass_kg','phase'});
propCsv = fullfile(resultsDir, sprintf('propulsion_case_%s.csv',caseName));
writetable(Tp, propCsv);

% Plots
save_fig_propulsion(prop, resultsDir, caseName);

%% 2) Trajectory simulation (3D point-mass)
traj = trajectory_3d_pointmass(p, prop);

Tt = table(traj.t(:), traj.x(:), traj.y(:), traj.z(:), traj.v(:), traj.vx(:), traj.vy(:), traj.vz(:), ...
    'VariableNames', {'t_s','x_m','y_m','z_m','speed_mps','vx_mps','vy_mps','vz_mps'});
trajCsv = fullfile(resultsDir, sprintf('trajectory_case_%s.csv',caseName));
writetable(Tt, trajCsv);

save_fig_trajectory(traj, resultsDir, caseName);

%% 3) Stability analysis
stab = stability_cg_cp_2l(p);

Ts = struct2table(stab);
stabCsv = fullfile(resultsDir, sprintf('stability_case_%s.csv',caseName));
writetable(Ts, stabCsv);

%% 4) Summary text
summaryTxt = fullfile(resultsDir, sprintf('summary_case_%s.txt',caseName));
fid = fopen(summaryTxt,'w');
if fid < 0
    warning('Could not open summary file for writing.');
else
    fprintf(fid, 'Water Rocket Simulation Summary (Case %s)\n', caseName);
    fprintf(fid, '===========================================\n\n');
    fprintf(fid, 'Apogee (max altitude): %.2f m\n', traj.apogee_m);
    fprintf(fid, 'Time to apogee: %.2f s\n', traj.t_apogee_s);
    fprintf(fid, 'Time of flight (landing): %.2f s\n\n', traj.t_land_s);
    fprintf(fid, 'Total impulse: %.2f N*s\n', prop.totalImpulse_Ns);
    fprintf(fid, 'Burn time: %.2f s\n', prop.burnTime_s);
    fprintf(fid, 'Max thrust: %.2f N\n\n', max(prop.T));

    fprintf(fid, 'Stability (static margin, calibers)\n');
    fprintf(fid, '-----------------------------------\n');
    fprintf(fid, 'Full bottle SM: %.2f\n', stab.SM_full_calibers);
    fprintf(fid, 'Empty bottle SM: %.2f\n\n', stab.SM_empty_calibers);

    fprintf(fid, 'Outputs written to:\n');
    fprintf(fid, '  %s\n', resultsDir);
    fclose(fid);
end

fprintf('Done. Results saved under: %s\n', resultsDir);

end
