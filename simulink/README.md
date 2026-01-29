# Simulink Model

File: `rc_trainer_linear_model.mdl`

This is a simple longitudinal state-space model driven by elevator/throttle steps.

## Steps
1) Run in MATLAB:
```matlab
main_run_all
```

2) Bring matrices into workspace:
```matlab
A_lon = dyn.lon.A; B_lon = dyn.lon.B; C_lon = dyn.lon.C; D_lon = dyn.lon.D;
```

3) Open and run:
```matlab
open_system('simulink/rc_trainer_linear_model.mdl')
sim('simulink/rc_trainer_linear_model.mdl')
```
