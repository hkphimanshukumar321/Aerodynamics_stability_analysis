function plot_longitudinal_steps(outdir, tests)
t=tests.lon.elevator.t; y=tests.lon.elevator.y;
figure; plot(t, y(:,4)*180/pi,'LineWidth',1.5);
grid on; xlabel('t (s)'); ylabel('\theta (deg)');
title('Virtual Flight Test: Elevator Step -> Pitch Angle');
saveas(gcf, fullfile(outdir,'lon_elevator_pitch.png')); close(gcf);

t=tests.lon.throttle.t; y=tests.lon.throttle.y;
figure; plot(t, y(:,1),'LineWidth',1.5);
grid on; xlabel('t (s)'); ylabel('u (state units)');
title('Virtual Flight Test: Throttle Step -> Forward Speed State');
saveas(gcf, fullfile(outdir,'lon_throttle_u.png')); close(gcf);
end
