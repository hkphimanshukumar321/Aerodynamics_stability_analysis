function plot_thrust_drag(outdir, p, aero, prop, trim)
rho=p.env.rho; S=p.geom.S; W=p.mass.W;
V=aero.V_grid;

CL = W ./ (0.5*rho.*V.^2.*S);
CD = aero.CD0 + aero.k.*CL.^2;
D  = 0.5*rho.*V.^2.*S.*CD;
T  = arrayfun(prop.T_available, V);

figure;
plot(V,D,'LineWidth',1.5); hold on;
plot(V,T,'LineWidth',1.5);
grid on; xlabel('V (m/s)'); ylabel('Force (N)');
title('Thrust Available vs Drag Required (Level Flight)');
legend('Drag required','Thrust available','Location','best');
xline(trim.V,'--','Trim V');
saveas(gcf, fullfile(outdir,'thrust_vs_drag.png')); close(gcf);

tbl=table(V(:),D(:),T(:),'VariableNames',{'V_mps','Drag_N','ThrustAvail_N'});
writetable(tbl, fullfile(outdir,'thrust_drag_table.csv'));
end
