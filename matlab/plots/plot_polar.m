function plot_polar(outdir, aero)
figure; plot(polar.CD, polar.CL, 'LineWidth', 1.5);
grid on; xlabel('C_D'); ylabel('C_L');
title('Drag Polar (Analytic): C_D = C_{D0} + k C_L^2');
saveas(gcf, fullfile(outdir,'aero_drag_polar.png')); close(gcf);
end
