function plan = plan_pick_place(cfg)
% PLAN_PICK_PLACE  Define cartesian waypoints and solve IK for each.

robot = cfg.robot;

% Waypoints in Cartesian
p_pick  = cfg.task.pickPos;
p_place = cfg.task.placePos;

p_pre_pick  = p_pick  + [0;0;cfg.task.approachDz];
p_pre_place = p_place + [0;0;cfg.task.approachDz];

p_lift = p_pick + [0;0;cfg.task.liftDz];

wps = [ ...
    'home      ';
    'pre_pick  ';
    'pick      ';
    'lift      ';
    'pre_place ';
    'place     ';
    'home2     '];

P = zeros(3, size(wps,1));
P(:,1) = fk_pos(robot, robot.home);
P(:,2) = p_pre_pick;
P(:,3) = p_pick;
P(:,4) = p_lift;
P(:,5) = p_pre_place;
P(:,6) = p_place;
P(:,7) = fk_pos(robot, robot.home);

% Solve IK sequentially (warm start)
Q = zeros(robot.n, size(P,2));
infoArr = cell(1,size(P,2));

q_guess = robot.home;

for k = 1:size(P,2)
    [q_sol, info] = ik_dls_position(robot, q_guess, P(:,k), cfg);
    if ~info.converged
        error('IK failed at waypoint %d (%s). Final err=%.3e m', k, strtrim(wps(k,:)), info.err);
    end
    Q(:,k) = q_sol;
    infoArr{k} = info;
    q_guess = q_sol;
end

plan = struct();
plan.wpNames = wps;
plan.P = P;
plan.Q = Q;
plan.ikInfo = infoArr;

end

function p = fk_pos(robot, q)
[~, p_all] = dh_fk(robot, q);
p = p_all(:,end);
end
