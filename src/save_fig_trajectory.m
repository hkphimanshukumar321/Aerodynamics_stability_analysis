function save_fig_trajectory(traj, resultsDir, caseName)
%SAVE_FIG_TRAJECTORY Save trajectory plots + a simple 3D animation frame.

% Altitude vs time
f1 = figure('Visible','off');
plot(traj.t, traj.z, 'LineWidth', 1.5);
grid on; xlabel('t [s]'); ylabel('Altitude z [m]');
title(sprintf('Altitude vs Time (Case %s)',caseName));
saveas(f1, fullfile(resultsDir, sprintf('fig_altitude_case_%s.png',caseName)));
close(f1);

% Speed vs time
f2 = figure('Visible','off');
plot(traj.t, traj.v, 'LineWidth', 1.5);
grid on; xlabel('t [s]'); ylabel('Speed [m/s]');
title(sprintf('Speed vs Time (Case %s)',caseName));
saveas(f2, fullfile(resultsDir, sprintf('fig_speed_case_%s.png',caseName)));
close(f2);

% 2D ground track (x-z)
f3 = figure('Visible','off');
plot(traj.x, traj.z, 'LineWidth', 1.5);
grid on; xlabel('x [m]'); ylabel('z [m]');
title(sprintf('Trajectory (x-z) (Case %s)',caseName));
saveas(f3, fullfile(resultsDir, sprintf('fig_traj_xz_case_%s.png',caseName)));
close(f3);

% 3D trajectory (static)
f4 = figure('Visible','off');
plot3(traj.x, traj.y, traj.z, 'LineWidth', 1.5);
grid on; xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
view(3);
title(sprintf('3D Trajectory (Case %s)',caseName));
saveas(f4, fullfile(resultsDir, sprintf('fig_traj3d_case_%s.png',caseName)));
close(f4);

% 3D animation (saved as GIF)
try
    gifPath = fullfile(resultsDir, sprintf('anim_traj3d_case_%s.gif',caseName));
    make_traj_gif(traj, gifPath);
catch ME
    warning('GIF generation failed: %s', ME.message);
end

end

function make_traj_gif(traj, gifPath)
%MAKE_TRAJ_GIF Simple animated marker over the 3D trajectory.

f = figure('Visible','off');
ax = axes(f);
plot3(ax, traj.x, traj.y, traj.z, 'LineWidth', 1.2);
grid(ax,'on');
xlabel(ax,'x [m]'); ylabel(ax,'y [m]'); zlabel(ax,'z [m]');
view(ax,3);
hold(ax,'on');
marker = plot3(ax, traj.x(1), traj.y(1), traj.z(1), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'auto');

% Downsample frames for speed
N = numel(traj.t);
idx = unique(round(linspace(1, N, min(200, N))));

for k = 1:numel(idx)
    i = idx(k);
    set(marker, 'XData', traj.x(i), 'YData', traj.y(i), 'ZData', traj.z(i));
    drawnow;

    frame = getframe(f);
    im = frame2im(frame);
    [A,map] = rgb2ind(im,256);
    if k == 1
        imwrite(A,map,gifPath,'gif','LoopCount',inf,'DelayTime',0.03);
    else
        imwrite(A,map,gifPath,'gif','WriteMode','append','DelayTime',0.03);
    end
end

close(f);
end
