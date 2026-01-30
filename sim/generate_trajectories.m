function traj = generate_trajectories(cfg, plan)
% GENERATE_TRAJECTORIES  Build multi-segment quintic trajectories between waypoint joint angles.

Qwp = plan.Q;
nSeg = size(Qwp,2)-1;

dt = cfg.traj.dt;
Tseg = cfg.traj.segTime;

tAll = [];
qAll = [];
qdAll = [];
qddAll = [];

for s = 1:nSeg
    q0 = Qwp(:,s);
    qf = Qwp(:,s+1);

    seg = traj_quintic(q0, qf, Tseg, dt, ...
        cfg.traj.v0*zeros(size(q0)), cfg.traj.vf*zeros(size(q0)), ...
        cfg.traj.a0*zeros(size(q0)), cfg.traj.af*zeros(size(q0)));

    if s > 1
        % remove duplicate first sample to avoid time overlap
        seg.t(1) = [];
        seg.q(1,:) = [];
        seg.qd(1,:) = [];
        seg.qdd(1,:) = [];
    end

    if isempty(tAll)
        tAll = seg.t;
    else
        tAll = [tAll; tAll(end) + seg.t];
    end
    qAll   = [qAll; seg.q];
    qdAll  = [qdAll; seg.qd];
    qddAll = [qddAll; seg.qdd];
end

traj = struct();
traj.t = tAll;
traj.q = qAll;
traj.qd = qdAll;
traj.qdd = qddAll;
end
