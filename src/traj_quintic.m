function seg = traj_quintic(q0, qf, T, dt, v0, vf, a0, af)
% TRAJ_QUINTIC  Quintic polynomial trajectory per joint.
%
% q(t) = a0 + a1 t + a2 t^2 + a3 t^3 + a4 t^4 + a5 t^5
% with boundary conditions on position, velocity, acceleration at t=0 and t=T.

q0 = q0(:); qf = qf(:);
n = length(q0);

if nargin < 5, v0 = 0; vf = 0; a0 = 0; af = 0; end
v0 = v0(:); vf = vf(:); a0 = a0(:); af = af(:);

t = (0:dt:T).';
m = length(t);

Q  = zeros(m,n);
Qd = zeros(m,n);
Qdd= zeros(m,n);

% Precompute powers
t1 = t;
t2 = t.^2; t3 = t.^3; t4 = t.^4; t5 = t.^5;

for i = 1:n
    % Solve for coefficients
    % [q0; v0; a0; qf; vf; af] = M * a
    M = [ ...
        1    0      0        0         0         0;
        0    1      0        0         0         0;
        0    0      2        0         0         0;
        1    T     T^2     T^3       T^4       T^5;
        0    1    2*T    3*T^2     4*T^3     5*T^4;
        0    0      2     6*T     12*T^2    20*T^3 ];
    b = [q0(i); v0(i); a0(i); qf(i); vf(i); af(i)];
    a = M \ b;

    Q(:,i)   = a(1) + a(2)*t1 + a(3)*t2 + a(4)*t3 + a(5)*t4 + a(6)*t5;
    Qd(:,i)  = a(2) + 2*a(3)*t1 + 3*a(4)*t2 + 4*a(5)*t3 + 5*a(6)*t4;
    Qdd(:,i) = 2*a(3) + 6*a(4)*t1 + 12*a(5)*t2 + 20*a(6)*t3;
end

seg = struct();
seg.t = t;
seg.q = Q;
seg.qd = Qd;
seg.qdd = Qdd;
end
