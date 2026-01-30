function [q_sol, info] = ik_dls_position(robot, q0, p_target, cfg)
% IK_DLS_POSITION  Damped Least Squares IK for position-only task.
%
% Minimizes ||p(q) - p_target|| using iterative DLS:
%   dq = (J^T J + lambda^2 I)^(-1) J^T e
%
% Inputs:
%   robot    : struct
%   q0       : initial guess (n x 1)
%   p_target : desired EE position (3 x 1)
%   cfg      : cfg.ik fields (maxIters, tolPos, lambda, stepScale)
%
% Outputs:
%   q_sol    : solution
%   info     : struct with fields (converged, iters, err, errHist)

q = q0(:);
n = robot.n;

lambda = cfg.ik.lambda;
maxIters = cfg.ik.maxIters;
tol = cfg.ik.tolPos;
stepScale = cfg.ik.stepScale;

errHist = zeros(maxIters,1);
converged = false;

for k = 1:maxIters
    [~, p_all] = dh_fk(robot, q);
    p = p_all(:,end);
    e = p_target - p;        % 3x1
    err = norm(e);
    errHist(k) = err;

    if err < tol
        converged = true;
        break;
    end

    J = jacobian_numeric(robot, q); % 3xn

    % DLS step
    A = (J.'*J + (lambda^2)*eye(n));
    dq = A \ (J.'*e);

    q = q + stepScale * dq;

    % enforce joint limits softly (clip)
    q = min(max(q, robot.qlim(:,1)), robot.qlim(:,2));
end

q_sol = q;

info = struct();
info.converged = converged;
info.iters = k;
info.err = err;
info.errHist = errHist(1:k);

end
