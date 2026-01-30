function cfg = sim_config()
% SIM_CONFIG  Central config for robot + simulation.
%
% Everything adjustable in one place.

cfg = struct();

% ---------------- Robot (4-DOF) ----------------
% 4 revolute joints; position task in 3D with redundancy.
% DH convention used in src/dh_fk.m:
%   A_i = RotZ(theta_i) * TransZ(d_i) * TransX(a_i) * RotX(alpha_i)

cfg.robot = robot_params_4dof();

% ---------------- Task / Waypoints -------------
cfg.task = struct();

% World coordinates (meters)
cfg.task.pickPos  = [0.35;  0.10; 0.10];  % [x;y;z]
cfg.task.placePos = [0.25; -0.20; 0.15];

cfg.task.approachDz = 0.12;   % approach height above pick/place
cfg.task.liftDz     = 0.18;   % lift after pick

% ---------------- IK settings ------------------
cfg.ik = struct();
cfg.ik.maxIters  = 300;
cfg.ik.tolPos    = 1e-6;   % meters
cfg.ik.lambda    = 1e-2;   % DLS damping
cfg.ik.stepScale = 1.0;    % multiply dq step

% ---------------- Trajectory settings ----------
cfg.traj = struct();
cfg.traj.dt = 0.01;           % seconds
cfg.traj.segTime = 2.0;       % seconds per segment
cfg.traj.v0 = 0; cfg.traj.vf = 0;
cfg.traj.a0 = 0; cfg.traj.af = 0;

% ---------------- Simulation / Visualization ----
cfg.vis = struct();
cfg.vis.axis = [-0.2 0.6 -0.4 0.4 0 0.6];  % [xmin xmax ymin ymax zmin zmax]
cfg.vis.showFrames = false;
cfg.vis.pauseRealtime = false;  % set true to match wall clock

cfg.makeVideo = true;
cfg.video.fps = 30;
cfg.video.filename = fullfile('results','demo_pick_place.mp4');

% ---------------- Evaluation -------------------
cfg.eval = struct();
cfg.eval.numRandTests = 200;
cfg.eval.targetErrSpec = 1e-3; % 1 mm

end
