function g = compute_geometry(p)
%COMPUTE_GEOMETRY  Computes taper ratio, area, AR, and induced drag factor k.
%
% From assignment:
%   lambda = Ct/Cr
%   S = (b/2) * Cr * (1+lambda)
%   AR = b^2 / S
%   k = 1/(pi*e*AR)

g.lambda = p.Ct / p.Cr;

g.S = (p.b/2) * p.Cr * (1 + g.lambda);

g.AR = (p.b^2) / g.S;

g.k = 1 / (pi * p.e * g.AR);

end
