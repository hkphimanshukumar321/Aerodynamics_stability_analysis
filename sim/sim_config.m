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
% Pick/place are chosen to be comfortably reachable given the default 4-DOF
% geometry and joint limits (so IK is robust out-of-the-box).
cfg.task.pickPos  = [0.380;  0.118; 0.121];  % [x;y;z]
cfg.task.placePos = [0.295; -0.202; 0.146];

cfg.task.approachDz = 0.12;   % approach height above pick/place
cfg.task.liftDz     = 0.18;   % lift after pick

% ---------------- IK settings ------------------
cfg.ik = struct();
% NOTE: tolerances/robustness tuned for purely numerical Jacobian.
% A 1e-6 m tolerance is often too strict with finite-difference Jacobians.
cfg.ik.maxIters  = 800;
cfg.ik.tolPos    = 1e-4;   % meters (0.1 mm)
cfg.ik.lambda    = 5e-2;   % DLS damping (higher -> more robust)
cfg.ik.stepScale = 1.0;    % base step scale (solver does its own line-search)

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
