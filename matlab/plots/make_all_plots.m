function make_all_plots(outdir, p, sizing, aero, prop, trim, dyn, tests)
plots.plot_polar(outdir, aero);
plots.plot_thrust_drag(outdir, p, aero, prop, trim);
plots.plot_longitudinal_steps(outdir, tests);
plots.plot_lateral_steps(outdir, tests);
plots.plot_eigs(outdir, dyn);

fn=fullfile(outdir,'report_numbers.txt');
fid=fopen(fn,'w');
fprintf(fid,'Wing loading W/S = %.2f N/m^2\n', sizing.WS);
fprintf(fid,'Static T/W = %.2f\n', sizing.TW_static);
fprintf(fid,'Stall speed Vs = %.2f m/s\n', sizing.Vs);
fprintf(fid,'Takeoff speed V_to = %.2f m/s\n', sizing.V_to);
fprintf(fid,'Trim V = %.2f m/s\n', trim.V);
fprintf(fid,'Trim CL = %.3f\n', trim.CL);
fprintf(fid,'Trim Drag D = %.2f N\n', trim.D);
fprintf(fid,'Thrust available at trim = %.2f N\n', trim.T_available);
fprintf(fid,'Thrust margin at trim = %.2f N\n', trim.thrust_margin);
fprintf(fid,'Estimated throttle fraction at trim = %.2f\n', trim.throttle_frac);
fclose(fid);
end
