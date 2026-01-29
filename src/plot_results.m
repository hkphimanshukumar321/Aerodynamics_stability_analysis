function plot_results(p, g, R, outdir)
%PLOT_RESULTS  Generates the 8 required plots and saves them to PNG.
%
% R is a struct with vector fields:
%   alpha_deg, de_deg, CL, CD, V, Tr, Pr, CL_over_CD, CL32_over_CD

if ~exist(outdir, "dir"); mkdir(outdir); end

% Helper for saving
savefig_png = @(fh, name) exportgraphics(fh, fullfile(outdir, name), "Resolution", 200);

% 1) Trim angle of attack (here: alpha itself vs V)
fh = figure('Name','Trim AoA'); 
plot(R.V, R.alpha_deg, 'LineWidth', 1.5); grid on;
xlabel('Flight velocity V [m/s]'); ylabel('Trim angle of attack \alpha [deg]');
title('Trim \alpha vs V');
savefig_png(fh, "01_trim_alpha_vs_V.png");

% 2) Trim elevator deflection
fh = figure('Name','Trim elevator'); 
plot(R.alpha_deg, R.de_deg, 'LineWidth', 1.5); grid on;
xlabel('\alpha [deg]'); ylabel('\delta_{e,trim} [deg]');
title('Trim elevator deflection vs \alpha');
savefig_png(fh, "02_deltae_trim_vs_alpha.png");

% 3) Lift coefficient
fh = figure('Name','CL'); 
plot(R.alpha_deg, R.CL, 'LineWidth', 1.5); grid on;
xlabel('\alpha [deg]'); ylabel('C_L [-]');
title('Lift coefficient vs \alpha');
savefig_png(fh, "03_CL_vs_alpha.png");

% 4) Drag coefficient
fh = figure('Name','CD'); 
plot(R.alpha_deg, R.CD, 'LineWidth', 1.5); grid on;
xlabel('\alpha [deg]'); ylabel('C_D [-]');
title('Drag coefficient vs \alpha');
savefig_png(fh, "04_CD_vs_alpha.png");

% 5) Thrust required
fh = figure('Name','Thrust required'); 
plot(R.V, R.Tr, 'LineWidth', 1.5); grid on;
xlabel('V [m/s]'); ylabel('T_r [N]');
title('Thrust required vs V');
savefig_png(fh, "05_ThrustRequired_vs_V.png");

% 6) Power required
fh = figure('Name','Power required'); 
plot(R.V, R.Pr, 'LineWidth', 1.5); grid on;
xlabel('V [m/s]'); ylabel('P_r [W]');
title('Power required vs V');
savefig_png(fh, "06_PowerRequired_vs_V.png");

% 7) CL/CD
fh = figure('Name','CL/CD'); 
plot(R.alpha_deg, R.CL_over_CD, 'LineWidth', 1.5); grid on;
xlabel('\alpha [deg]'); ylabel('C_L/C_D [-]');
title('Aerodynamic efficiency C_L/C_D vs \alpha');
savefig_png(fh, "07_CLoverCD_vs_alpha.png");

% 8) CL^(3/2)/CD
fh = figure('Name','CL^(3/2)/CD'); 
plot(R.alpha_deg, R.CL32_over_CD, 'LineWidth', 1.5); grid on;
xlabel('\alpha [deg]'); ylabel('C_L^{3/2}/C_D [-]');
title('Endurance/loiter metric C_L^{3/2}/C_D vs \alpha');
savefig_png(fh, "08_CL32overCD_vs_alpha.png");

end
