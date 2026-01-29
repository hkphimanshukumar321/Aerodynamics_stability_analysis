%% Project 4 — Trim, Thrust Required, and Power Required Analysis (MATLAB)
% Cropped delta wing UAV (wing-alone)
%
% Running this script will:
%  - compute geometry
%  - sweep alpha = 0:0.5:12 deg
%  - compute trim, V, CD, thrust required, power required
%  - compute performance metrics
%  - write a CSV (Excel-friendly) and save all required plots

clear; clc; close all;

% ---- Parameters ----
p = uav_params_project4();
g = compute_geometry(p);

% ---- Pre-allocate results ----
N = numel(p.alpha_rad);

R.alpha_deg     = p.alpha_deg(:);
R.alpha_rad     = p.alpha_rad(:);

R.de_trim_rad   = nan(N,1);
R.de_deg        = nan(N,1);

R.CL            = nan(N,1);
R.CD            = nan(N,1);
R.V             = nan(N,1);
R.Tr            = nan(N,1);
R.Pr            = nan(N,1);

R.CL_over_CD    = nan(N,1);
R.CL32_over_CD  = nan(N,1);
R.valid         = false(N,1);

% ---- Sweep ----
for i = 1:N
    out = trim_at_alpha(p, g, R.alpha_rad(i));
    R.valid(i) = out.valid;

    R.de_trim_rad(i)  = out.de_trim;
    R.de_deg(i)       = rad2deg(out.de_trim);

    R.CL(i)           = out.CL;
    R.CD(i)           = out.CD;
    R.V(i)            = out.V;
    R.Tr(i)           = out.Tr;
    R.Pr(i)           = out.Pr;

    R.CL_over_CD(i)   = out.CL_over_CD;
    R.CL32_over_CD(i) = out.CL32_over_CD;
end

% ---- Remove invalid points (if any) ----
% (e.g., CL <= 0 at some alpha; shouldn't happen with provided coefficients,
% but keep it robust)
fields = fieldnames(R);
mask = R.valid;
for f = 1:numel(fields)
    x = R.(fields{f});
    if isnumeric(x) && size(x,1)==N
        R.(fields{f}) = x(mask,:);
    end
end

% ---- Export to CSV ----
outData = table( ...
    R.alpha_deg, R.de_deg, R.CL, R.CD, R.V, R.Tr, R.Pr, R.CL_over_CD, R.CL32_over_CD, ...
    'VariableNames', {'alpha_deg','deltae_trim_deg','CL','CD','V_mps','ThrustReq_N','PowerReq_W','CL_over_CD','CL32_over_CD'} ...
);

outdir_data = fullfile("outputs","data");
outdir_figs = fullfile("outputs","figures");
if ~exist(outdir_data, "dir"); mkdir(outdir_data); end
if ~exist(outdir_figs, "dir"); mkdir(outdir_figs); end

csvPath = fullfile(outdir_data, "project4_results.csv");
writetable(outData, csvPath);

% ---- Plots ----
plot_results(p, g, R, outdir_figs);

% ---- Console summary ----
fprintf("=== Geometry ===\n");
fprintf("lambda = %.4f\n", g.lambda);
fprintf("S      = %.4f m^2\n", g.S);
fprintf("AR     = %.4f\n", g.AR);
fprintf("k      = %.6f\n", g.k);

% Find min power required (often of interest)
[Pr_min, idx] = min(R.Pr);
fprintf("\n=== Key points ===\n");
fprintf("Min Power Required: %.3f W at alpha=%.2f deg, V=%.3f m/s\n", Pr_min, R.alpha_deg(idx), R.V(idx));

end
