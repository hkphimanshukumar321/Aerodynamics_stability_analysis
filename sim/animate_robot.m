function animate_robot(cfg, traj)
% ANIMATE_ROBOT  Simple 3D stick-figure animation of the kinematic chain.

robot = cfg.robot;

fig = figure('Color','w'); %#ok<NASGU>
ax = axes('Parent', gcf);
axis(ax, cfg.vis.axis);
axis(ax, 'equal');
grid(ax, 'on');
xlabel(ax, 'X (m)'); ylabel(ax, 'Y (m)'); zlabel(ax, 'Z (m)');
view(ax, 40, 22);
hold(ax, 'on');

% Draw pick/place markers
plot3(cfg.task.pickPos(1), cfg.task.pickPos(2), cfg.task.pickPos(3), 'o', 'MarkerSize', 8, 'LineWidth', 2);
text(cfg.task.pickPos(1), cfg.task.pickPos(2), cfg.task.pickPos(3)+0.02, 'PICK');

plot3(cfg.task.placePos(1), cfg.task.placePos(2), cfg.task.placePos(3), 's', 'MarkerSize', 8, 'LineWidth', 2);
text(cfg.task.placePos(1), cfg.task.placePos(2), cfg.task.placePos(3)+0.02, 'PLACE');

hLine = plot3(0,0,0,'-o','LineWidth',3,'MarkerSize',6);

makeVideo = cfg.makeVideo;
if makeVideo
    vw = VideoWriter(cfg.video.filename, 'MPEG-4');
    vw.FrameRate = cfg.video.fps;
    open(vw);
end

t = traj.t;
q = traj.q;

for k = 1:length(t)
    qk = q(k,:).';
    [~, p_all] = dh_fk(robot, qk);

    set(hLine, 'XData', p_all(1,:), 'YData', p_all(2,:), 'ZData', p_all(3,:));
    title(ax, sprintf('Pick-and-Place Simulation   t = %.2f s', t(k)));

    drawnow;

    if makeVideo
        frame = getframe(gcf);
        writeVideo(vw, frame);
    end

    if cfg.vis.pauseRealtime
        pause(cfg.traj.dt);
    end
end

if makeVideo
    close(vw);
end

hold(ax, 'off');
end
