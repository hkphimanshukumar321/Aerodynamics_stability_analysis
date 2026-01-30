function simulate_and_export(cfg, plan, traj)
% SIMULATE_AND_EXPORT  Animate, compute metrics, and save results/plots.

robot = cfg.robot;

% --- Compute end-effector tracking error over trajectory ---
N = length(traj.t);
p = zeros(3,N);
for k = 1:N
    qk = traj.q(k,:).';
    [~, p_all] = dh_fk(robot, qk);
    p(:,k) = p_all(:,end);
end

% Desired path is not a continuous Cartesian trajectory; we evaluate
% waypoint errors (main spec) + overall smoothness.
wpErr = zeros(size(plan.P,2),1);
for i = 1:size(plan.P,2)
    qi = plan.Q(:,i);
    [~, p_all] = dh_fk(robot, qi);
    wpErr(i) = norm(p_all(:,end) - plan.P(:,i));
end

% Export IK stats
statsFile = fullfile('results','ik_error_stats.csv');
fid = fopen(statsFile,'w');
fprintf(fid,'waypoint,err_m\n');
for i = 1:length(wpErr)
    fprintf(fid,'%s,%.12g\n', strtrim(plan.wpNames(i,:)), wpErr(i));
end
fclose(fid);

% --- Plot trajectories ---
plot_joint_traj(traj.t, traj.q,    'q (rad)',  fullfile('results','traj_q.png'));
plot_joint_traj(traj.t, traj.qd,   'qdot (rad/s)', fullfile('results','traj_qdot.png'));
plot_joint_traj(traj.t, traj.qdd,  'qddot (rad/s^2)', fullfile('results','traj_qddot.png'));

% --- Workspace plot (sample random joints) ---
workspace_plot(cfg);

% --- Animate ---
animate_robot(cfg, traj);

end

function plot_joint_traj(t, X, ylab, outFile)
fig = figure('Color','w');
plot(t, X, 'LineWidth', 1.2);
grid on; xlabel('Time (s)'); ylabel(ylab);
title(strrep(ylab,'_','\_'));
legend(arrayfun(@(i) sprintf('Joint %d',i), 1:size(X,2), 'UniformOutput', false), ...
    'Location','bestoutside');
drawnow;
if exist('exportgraphics','file')
    exportgraphics(fig, outFile);
else
    % Fallback for older MATLAB versions
    saveas(fig, outFile);
end
close(fig);
end
