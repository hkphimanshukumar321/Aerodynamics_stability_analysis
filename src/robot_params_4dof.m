function robot = robot_params_4dof()
% ROBOT_PARAMS_4DOF  4-DOF arm parameters (meters, radians).
%
% Geometry: yaw at base + 3 pitch joints (approx). This is a simple
% educational manipulator; we use numerical IK so exact geometry is flexible.

robot = struct();
robot.n = 4;

% Link lengths (meters)
L1 = 0.18;   % base-to-shoulder vertical offset
L2 = 0.22;   % upper arm
L3 = 0.20;   % forearm
L4 = 0.12;   % wrist/tool

% DH parameters [a, alpha, d, theta_offset]
% theta_i = q_i + theta_offset
% Using a simple chain:
% 1) base yaw about z, then lift to shoulder
% 2) shoulder pitch
% 3) elbow pitch
% 4) wrist pitch (tool length along x)
%
% For visualization, this behaves well in 3D for position targets.

robot.DH = [ ...
    0.00   pi/2   L1   0.0;   % joint1
    L2     0.0    0.0  0.0;   % joint2
    L3     0.0    0.0  0.0;   % joint3
    L4     0.0    0.0  0.0];  % joint4

% Joint limits [min max] rad
robot.qlim = [ ...
    -pi      pi;       % yaw
    -pi/2    pi/2;     % shoulder
    -pi/2    pi/2;     % elbow
    -pi/2    pi/2];    % wrist

robot.home = [0; 0.2; -0.4; 0.2];

% Tool frame is at end of link4 (end-effector position = FK translation).
end
