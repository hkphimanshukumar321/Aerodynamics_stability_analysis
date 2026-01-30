function J = jacobian_numeric(robot, q, eps)
% JACOBIAN_NUMERIC  Numerical Jacobian for end-effector position (3xn).
%
% J(:,i) ~= (p(q+eps*e_i) - p(q-eps*e_i)) / (2*eps)

if nargin < 3, eps = 1e-6; end

n = robot.n;
J = zeros(3,n);

[~, p0] = dh_fk(robot, q);
p0e = p0(:,end);

for i = 1:n
    dq = zeros(n,1); dq(i) = eps;
    [~, p_plus]  = dh_fk(robot, q + dq);
    [~, p_minus] = dh_fk(robot, q - dq);
    J(:,i) = (p_plus(:,end) - p_minus(:,end)) / (2*eps);
end

end
