function plot_lateral_steps(outdir, tests)
t=tests.lat.aileron.t; y=tests.lat.aileron.y;
figure; plot(t, y(:,4)*180/pi,'LineWidth',1.5);
grid on; xlabel('t (s)'); ylabel('\phi (deg)');
title('Virtual Flight Test: Aileron Step -> Roll Angle');
saveas(gcf, fullfile(outdir,'lat_aileron_roll.png')); close(gcf);

t=tests.lat.rudder.t; y=tests.lat.rudder.y;
figure; plot(t, y(:,3)*180/pi,'LineWidth',1.5);
grid on; xlabel('t (s)'); ylabel('r (deg/s) [state units]');
title('Virtual Flight Test: Rudder Step -> Yaw Rate State');
saveas(gcf, fullfile(outdir,'lat_rudder_yawrate.png')); close(gcf);
end
