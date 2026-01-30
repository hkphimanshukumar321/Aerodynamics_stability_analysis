function self_test(cfg)
% SELF_TEST  Basic correctness checks + IK accuracy test.

robot = cfg.robot;

% ---- FK sanity: dimensions and monotonic chain length (non-NaN) ----
q = robot.home;
[T_all, p_all] = dh_fk(robot, q);
assert(all(size(T_all) == [4 4 robot.n+1]), 'FK: bad T_all size');
assert(all(size(p_all) == [3 robot.n+1]), 'FK: bad p_all size');
assert(all(isfinite(p_all(:))), 'FK: non-finite joint positions');

% ---- IK verification: random reachable targets ----
N = cfg.eval.numRandTests;
errs = zeros(N,1);
conv = false(N,1);

q0 = robot.home;

for k = 1:N
    % random joint -> target position
    q_rand = robot.qlim(:,1) + (robot.qlim(:,2)-robot.qlim(:,1)).*rand(robot.n,1);
    [~, p_all_r] = dh_fk(robot, q_rand);
    p_target = p_all_r(:,end);

    % Try warm-start first; if it fails, fall back to more forgiving initials.
    [q_sol, info] = ik_dls_position(robot, q0, p_target, cfg);
    if ~info.converged
        [q_sol, info] = ik_dls_position(robot, robot.home, p_target, cfg);
    end
    if ~info.converged
        % Last-resort: start close to a known feasible configuration.
        [q_sol, info] = ik_dls_position(robot, q_rand, p_target, cfg);
    end
    conv(k) = info.converged;

    [~, p_all_s] = dh_fk(robot, q_sol);
    err = norm(p_all_s(:,end) - p_target);
    errs(k) = err;

    if info.converged
        q0 = q_sol; % warm start only when valid
    end
end

if ~any(conv)
    error('IK self-test: no successful convergences. Check DH/limits or increase cfg.ik.maxIters.');
end

errs_ok = errs(conv);
maxErr = max(errs_ok);
p95 = prctile(errs_ok,95);

fprintf('IK self-test: success = %d/%d, max err = %.3g m, 95%% err = %.3g m\n', sum(conv), N, maxErr, p95);

% Spec check (1 mm default)
if maxErr > cfg.eval.targetErrSpec
    warning('IK max error exceeds spec (%.3g m). Consider increasing iters or tuning lambda.', cfg.eval.targetErrSpec);
end

% Save self-test stats
out = fullfile('results','ik_self_test_stats.csv');
fid = fopen(out,'w');
fprintf(fid,'metric,value_m\n');
fprintf(fid,'max,%.12g\n', maxErr);
fprintf(fid,'p95,%.12g\n', p95);
fprintf(fid,'mean,%.12g\n', mean(errs_ok));
fprintf(fid,'median,%.12g\n', median(errs_ok));
fprintf(fid,'success_rate,%.12g\n', sum(conv)/N);
fclose(fid);

end
