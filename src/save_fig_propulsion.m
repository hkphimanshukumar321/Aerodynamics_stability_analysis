function save_fig_propulsion(prop, resultsDir, caseName)
%SAVE_FIG_PROPULSION Save propulsion plots to resultsDir.

% Thrust
f1 = figure('Visible','off');
plot(prop.t, prop.T, 'LineWidth', 1.5);
grid on; xlabel('t [s]'); ylabel('Thrust T [N]');
title(sprintf('Thrust vs Time (Case %s)',caseName));
saveas(f1, fullfile(resultsDir, sprintf('fig_thrust_case_%s.png',caseName)));
close(f1);

% Pressure
f2 = figure('Visible','off');
plot(prop.t, prop.P/1e5, 'LineWidth', 1.5);
grid on; xlabel('t [s]'); ylabel('Pressure [bar]');
title(sprintf('Bottle Pressure vs Time (Case %s)',caseName));
saveas(f2, fullfile(resultsDir, sprintf('fig_pressure_case_%s.png',caseName)));
close(f2);

% Mass flow
f3 = figure('Visible','off');
plot(prop.t, prop.mdot, 'LineWidth', 1.5);
grid on; xlabel('t [s]'); ylabel('Mass flow mdot [kg/s]');
title(sprintf('Mass Flow vs Time (Case %s)',caseName));
saveas(f3, fullfile(resultsDir, sprintf('fig_mdot_case_%s.png',caseName)));
close(f3);

% Total mass
f4 = figure('Visible','off');
plot(prop.t, prop.m, 'LineWidth', 1.5);
grid on; xlabel('t [s]'); ylabel('Rocket mass [kg]');
title(sprintf('Rocket Mass vs Time (Case %s)',caseName));
saveas(f4, fullfile(resultsDir, sprintf('fig_mass_case_%s.png',caseName)));
close(f4);

end
