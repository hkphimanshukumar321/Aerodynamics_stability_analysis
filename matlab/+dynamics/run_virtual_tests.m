function tests = run_virtual_tests(p, dyn)
tFinal=p.test.t_final; step=p.test.step_deg*pi/180;

% Longitudinal: y=[u w q theta]
A=dyn.lon.A; B=dyn.lon.B; C=dyn.lon.C; x0=zeros(4,1);
u1=@(t)[(t>=1)*step; 0];     [t1,~,y1]=dynamics.sim_lin_ode(A,B,C,x0,u1,tFinal);
u2=@(t)[0; (t>=1)*0.2];      [t2,~,y2]=dynamics.sim_lin_ode(A,B,C,x0,u2,tFinal);
tests.lon.elevator.t=t1; tests.lon.elevator.y=y1;
tests.lon.throttle.t=t2; tests.lon.throttle.y=y2;

% Lateral: y=[v p r phi psi]
A=dyn.lat.A; B=dyn.lat.B; C=dyn.lat.C; x0=zeros(5,1);
u3=@(t)[(t>=1)*step; 0];     [t3,~,y3]=dynamics.sim_lin_ode(A,B,C,x0,u3,tFinal);
u4=@(t)[0; (t>=1)*step];     [t4,~,y4]=dynamics.sim_lin_ode(A,B,C,x0,u4,tFinal);
tests.lat.aileron.t=t3; tests.lat.aileron.y=y3;
tests.lat.rudder.t=t4;  tests.lat.rudder.y=y4;
end
