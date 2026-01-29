function out = trim_at_alpha(p, g, alpha_rad)
%TRIM_AT_ALPHA  Computes trim and performance quantities at a given alpha.
%
% Trim condition:
%   Cm = Cm0 + Cm_alpha*alpha + Cm_de*de = 0  => de_trim
%
% Lift:
%   CL = CL0 + CL_alpha*alpha + CL_de*de_trim
%
% Drag polar:
%   CD = CD0 + k*CL^2
%
% Level flight:
%   W = 0.5*rho*V^2*S*CL  => V
%
% Thrust required:
%   Tr = D = 0.5*rho*V^2*S*CD
%
% Power required:
%   Pr = Tr*V

% ---- Trim elevator deflection ----
out.de_trim = -(p.Cm0 + p.Cm_alpha*alpha_rad) / p.Cm_de;  % [rad]

% ---- Lift coefficient at trim ----
out.CL = p.CL0 + p.CL_alpha*alpha_rad + p.CL_de*out.de_trim;

% Guard: CL must be positive for real V in level flight.
if out.CL <= 0
    out.V  = NaN;
    out.CD = NaN;
    out.Tr = NaN;
    out.Pr = NaN;
    out.valid = false;
    return;
end

% ---- Drag coefficient ----
out.CD = p.CD0 + g.k * out.CL^2;

% ---- Level-flight speed ----
out.V = sqrt( (2*p.W) / (p.rho*g.S*out.CL) );

% ---- Thrust and power required ----
q = 0.5*p.rho*out.V^2; % dynamic pressure
out.Tr = q * g.S * out.CD;   % [N]
out.Pr = out.Tr * out.V;     % [W]

% ---- Performance metrics ----
out.CL_over_CD = out.CL / out.CD;
out.CL32_over_CD = (out.CL^(3/2)) / out.CD;

out.valid = true;

end
