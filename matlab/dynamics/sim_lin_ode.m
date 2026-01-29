function [t,x,y] = sim_lin_ode(A,B,C,x0,u_fun,tFinal)
f=@(t,x) A*x + B*u_fun(t);
opts=odeset('RelTol',1e-6,'AbsTol',1e-9);
[t,x]=ode45(f,[0 tFinal],x0,opts);
y=(C*x')';
end
