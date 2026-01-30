function [T_all, p_all] = dh_fk(robot, q)
% DH_FK  Forward kinematics using standard DH convention.
%
% Inputs:
%   robot.DH : [a alpha d theta_offset] per joint
%   q        : (n x 1) joint vector (rad)
%
% Outputs:
%   T_all : 4x4x(n+1), T(:,:,1)=I (base), T(:,:,i+1)=T_0i
%   p_all : 3x(n+1) joint positions in world frame

n = robot.n;
DH = robot.DH;

T_all = zeros(4,4,n+1);
T_all(:,:,1) = eye(4);
p_all = zeros(3,n+1);
p_all(:,1) = [0;0;0];

T = eye(4);

for i = 1:n
    a = DH(i,1);
    alpha = DH(i,2);
    d = DH(i,3);
    th0 = DH(i,4);

    theta = q(i) + th0;

    A = dh_A(a, alpha, d, theta);
    T = T * A;

    T_all(:,:,i+1) = T;
    p_all(:,i+1) = T(1:3,4);
end

end

function A = dh_A(a, alpha, d, theta)
ct = cos(theta); st = sin(theta);
ca = cos(alpha); sa = sin(alpha);

A = [ ct   -st*ca   st*sa   a*ct;
      st    ct*ca  -ct*sa   a*st;
      0      sa      ca       d;
      0       0       0       1 ];
end
