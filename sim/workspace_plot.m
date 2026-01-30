function workspace_plot(cfg)
% WORKSPACE_PLOT  Random joint samples -> end-effector cloud, saved as image.

robot = cfg.robot;
N = cfg.eval.numRandTests;

P = zeros(3,N);

for k = 1:N
    q = robot.qlim(:,1) + (robot.qlim(:,2)-robot.qlim(:,1)).*rand(robot.n,1);
    [~, p_all] = dh_fk(robot, q);
    P(:,k) = p_all(:,end);
end

fig = figure('Color','w');
scatter3(P(1,:), P(2,:), P(3,:), 18, 'filled');
grid on; axis equal;
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
title('End-effector Workspace (random joint sampling)');

outFile = fullfile('results','workspace.png');
if exist('exportgraphics','file')
    exportgraphics(fig, outFile);
else
    saveas(fig, outFile);
end
close(fig);
end
