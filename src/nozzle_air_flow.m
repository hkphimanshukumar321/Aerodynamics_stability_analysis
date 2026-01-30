function [mdot, Ve, Pe] = nozzle_air_flow(P0, T0, Pa, A, gamma, R, Cd)
%NOZZLE_AIR_FLOW Compressible nozzle mass flow and exit velocity.
%
% Inputs:
%   P0, T0 : stagnation (bottle) pressure and temperature
%   Pa     : ambient pressure
%   A      : nozzle area
%   gamma  : ratio of specific heats
%   R      : specific gas constant
%   Cd     : discharge coefficient
%
% Outputs:
%   mdot [kg/s], Ve [m/s], Pe [Pa]

% Choking condition for isentropic nozzle
Pcrit = P0 * (2/(gamma+1))^(gamma/(gamma-1));

if Pa <= Pcrit
    % Choked flow (M=1 at throat)
    Pe = Pcrit;
    Te = T0 * (2/(gamma+1));
    Ve = sqrt(gamma * R * Te);

    mdot = Cd * A * P0 * sqrt(gamma/(R*T0)) * (2/(gamma+1))^((gamma+1)/(2*(gamma-1)));
else
    % Unchoked: assume exit pressure equals ambient
    Pe = Pa;
    pr = Pa / P0;
    % Solve for exit Mach from pressure ratio
    M2 = (2/(gamma-1)) * ( (1/pr)^((gamma-1)/gamma) - 1 );
    M2 = max(M2, 0);
    M = sqrt(M2);

    Te = T0 / (1 + (gamma-1)/2 * M^2);
    a = sqrt(gamma * R * Te);
    Ve = M * a;

    rhoe = Pe / (R * Te);
    mdot = Cd * A * rhoe * Ve;
end

% Numerical guards
if ~isfinite(mdot) || mdot < 0
    mdot = 0;
end
if ~isfinite(Ve) || Ve < 0
    Ve = 0;
end

end
