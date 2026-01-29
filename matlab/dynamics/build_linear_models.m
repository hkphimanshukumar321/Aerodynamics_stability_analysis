function dyn = build_linear_models(p, aero, trim)
g = p.env.g; V = trim.V;
[Jx,Jy,Jz] = dynamics.estimate_inertia(p); %#ok<ASGLU>

% Longitudinal: x=[u w q theta], u=[de dt]
Xu=-0.06*V; Xw=0.02*V;
Zu=-0.10*V; Zw=-0.50*V;
Mu=0.00; Mw=p.aero.cm_alpha*0.8; Mq=p.aero.cm_q*0.15;

Xde=0.0; Zde=-0.2*V; Mde=p.ctrl.cm_de*0.6;
Xdt=0.5; Zdt=0.0;   Mdt=0.0;

A_lon=[Xu Xw  0  -g;
       Zu Zw  V   0;
       Mu Mw  Mq  0;
       0  0   1   0];
B_lon=[Xde Xdt;
       Zde Zdt;
       Mde Mdt;
       0   0];
C_lon=eye(4); D_lon=zeros(4,2);

% Lateral: x=[v p r phi psi], u=[da dr]
Yv=p.aero.cy_beta*0.4*V;
Lp=p.aero.cl_p*0.6*V;
Nr=p.aero.cn_r*0.3*V;

Lda=p.ctrl.cl_da*0.9;
Ndr=p.ctrl.cn_dr*0.9;

A_lat=[Yv 0  V  g 0;
       0  Lp 0  0 0;
       0  0  Nr 0 0;
       0  1  0  0 0;
       0  0  1  0 0];
B_lat=[0  0;
       Lda 0;
       0  Ndr;
       0  0;
       0  0];
C_lat=eye(5); D_lat=zeros(5,2);

dyn.lon.A=A_lon; dyn.lon.B=B_lon; dyn.lon.C=C_lon; dyn.lon.D=D_lon;
dyn.lat.A=A_lat; dyn.lat.B=B_lat; dyn.lat.C=C_lat; dyn.lat.D=D_lat;
dyn.lon.eigs=eig(A_lon);
dyn.lat.eigs=eig(A_lat);
dyn.trimV=V;
end
