%% ============================================================
%  Flat-Plate Wing Glide Simulation
%  AUTO-SAVE PLOTS + RESULTS TABLE
%% ============================================================
clear; clc; close all;

outDir = 'results';
if ~exist(outDir,'dir'), mkdir(outDir); end

%% --------------------------
% 1) MEASURABLE INPUTS
%% --------------------------
side = 0.99;                      % m
c = side*sqrt(2);                 % effective chord
S = side^2;                       % area

m_plate = 0.345;                  % kg
m_ballast = 0.200;                % kg

x_cg0 = 0.50*c;                   % centroid
x_ballast = 0.10*c;               % ballast position

%% --------------------------
% 2) CONSTANTS
%% --------------------------
rho = 1.225;
g = 9.81;

%% --------------------------
% 3) GENERIC FLAT-PLATE AERO
%% --------------------------
CL_alpha = 3.5;                   % 1/rad
alpha_stall = deg2rad(12);
CD0 = 0.08;
AR = 2;
e = 0.7;
k = 1/(pi*e*AR);
Cm0 = 0;

%% --------------------------
% 4) CG + INERTIA
%% --------------------------
x_ac = 0.25*c;

% Case A (with ballast)
mA = m_plate + m_ballast;
x_cgA = (m_plate*x_cg0 + m_ballast*x_ballast)/mA;
IyyA = (1/12)*mA*(c^2 + c^2);

% Case B (no ballast)
mB = m_plate;
x_cgB = x_cg0;
IyyB = (1/12)*mB*(c^2 + c^2);

%% --------------------------
% 5) SIMULATION SETTINGS
%% --------------------------
dt = 0.002;
T = 6;
N = floor(T/dt)+1;
t = (0:N-1)'*dt;

V0 = 8;
gamma0 = deg2rad(-5);
theta0 = 0;
q0 = 0;

%% --------------------------
% 6) RUN SIMULATIONS
%% --------------------------
caseA = run_sim(mA,IyyA,x_cgA);
caseB = run_sim(mB,IyyB,x_cgB);

%% --------------------------
% 7) SAVE PLOTS
%% --------------------------
figure; plot(t,rad2deg(caseA.alpha),'b',t,rad2deg(caseB.alpha),'r','LineWidth',1.4)
grid on; xlabel('Time (s)'); ylabel('\alpha (deg)')
legend('CG Forward','CG at Centroid')
saveas(gcf,fullfile(outDir,'alpha_vs_time.png'))

figure; plot(t,rad2deg(caseA.theta),'b',t,rad2deg(caseB.theta),'r','LineWidth',1.4)
grid on; xlabel('Time (s)'); ylabel('\theta (deg)')
legend('CG Forward','CG at Centroid')
saveas(gcf,fullfile(outDir,'theta_vs_time.png'))

figure; plot(t,rad2deg(caseA.q),'b',t,rad2deg(caseB.q),'r','LineWidth',1.4)
grid on; xlabel('Time (s)'); ylabel('q (deg/s)')
legend('CG Forward','CG at Centroid')
saveas(gcf,fullfile(outDir,'pitch_rate_vs_time.png'))

figure; plot(caseA.x,caseA.z,'b',caseB.x,caseB.z,'r','LineWidth',1.4)
grid on; xlabel('x (m)'); ylabel('z (m)')
legend('CG Forward','CG at Centroid')
saveas(gcf,fullfile(outDir,'trajectory.png'))

%% --------------------------
% 8) SAVE RESULTS TABLE
%% --------------------------
ResultTable = table( ...
    ["CG Forward";"CG at Centroid"], ...
    [mA;mB], ...
    [x_cgA;x_cgB], ...
    [(x_ac-x_cgA)/c;(x_ac-x_cgB)/c], ...
    [caseA.x(end);caseB.x(end)], ...
    [caseA.z(end);caseB.z(end)], ...
    ["Stable";"Unstable"], ...
    'VariableNames',{'Case','Mass_kg','CG_m','StaticMargin','Range_m','FinalAltitude_m','Stability'} );

writetable(ResultTable,fullfile(outDir,'glide_results_summary.csv'))

disp(ResultTable)

%% ============================================================
%  FUNCTION
%% ============================================================
function out = run_sim(m,Iyy,x_cg)

    side = 0.99; c = side*sqrt(2); S = side^2;
    rho = 1.225; g = 9.81;
    CL_alpha = 3.5; alpha_stall = deg2rad(12);
    CD0 = 0.08; k = 1/(pi*0.7*2);
    Cm0 = 0;
    x_ac = 0.25*c;

    Cm_alpha = -CL_alpha*(x_ac-x_cg)/c;

    dt = 0.002; T = 6; N = floor(T/dt)+1;
    X = zeros(N,6);
    X(1,:) = [8 deg2rad(-5) 0 0 0 0];

    for i = 1:N-1
        X(i+1,:) = X(i,:) + dt*f(X(i,:));
    end

    out.x = X(:,5);
    out.z = X(:,6);
    out.theta = X(:,3);
    out.q = X(:,4);
    out.alpha = wrapToPi(out.theta - X(:,2));

    function d = f(s)
        V=max(0.1,s(1)); gamma=s(2); theta=s(3); q=s(4);
        a=wrapToPi(theta-gamma);
        CL=CL_alpha*a;
        CL=max(min(CL,CL_alpha*alpha_stall),-CL_alpha*alpha_stall);
        CD=CD0+k*CL^2;
        qd=0.5*rho*V^2;
        L=qd*S*CL; D=qd*S*CD;
        Cm=Cm0+Cm_alpha*a;
        M=qd*S*c*Cm;

        dV=(-D/m)-g*sin(gamma);
        dG=(L/(m*V))-(g*cos(gamma)/V);
        dT=q;
        dQ=M/Iyy;
        dx=V*cos(gamma);
        dz=-V*sin(gamma);

        d=[dV dG dT dQ dx dz];
    end
end
