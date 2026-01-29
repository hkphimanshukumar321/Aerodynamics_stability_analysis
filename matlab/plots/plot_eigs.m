function plot_eigs(outdir, dyn)
lon=dyn.lon.eigs; lat=dyn.lat.eigs;
writetable(table(real(lon),imag(lon),'VariableNames',{'Real','Imag'}), fullfile(outdir,'lon_eigs.csv'));
writetable(table(real(lat),imag(lat),'VariableNames',{'Real','Imag'}), fullfile(outdir,'lat_eigs.csv'));

figure;
plot(real(lon),imag(lon),'x','LineWidth',1.5); hold on;
plot(real(lat),imag(lat),'o','LineWidth',1.5);
grid on; xlabel('Real'); ylabel('Imag');
title('Eigenvalues (Stability Modes)');
legend('Longitudinal','Lateral','Location','best');
saveas(gcf, fullfile(outdir,'eigs_complex_plane.png')); close(gcf);
end
