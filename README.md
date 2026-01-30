# MATLAB Water Rocket Simulation (2L Bottle)

This repository provides a **simulation-only** evidence package for a **2L PET bottle water rocket**. It produces:

- **Propulsion evidence**: \(T(t)\), \(P(t)\), \(\dot m(t)\), \(m(t)\), total impulse
- **Trajectory evidence**: \(x(t),y(t),z(t)\), altitude/time, speed/time, 3D trajectory
- **Stability proof**: \(x_{CG}\) (full/empty), \(x_{CP}\) (Barrowman-lite), static margin (calibers)

All plots and tables are automatically saved to `results/`.

## Requirements
- MATLAB R2019b+ (uses `ode45`, `writetable`, `animatedline`).

## One-click run
Open MATLAB, set the working directory to this repo, then run:

```matlab
run_all('A')   % Case A (default)
```

Other predefined cases:

```matlab
run_all('B')
run_all('C')
```

## Output files
After running, check `results/`:
- `propulsion_case_*.csv`, `trajectory_case_*.csv`, `stability_case_*.csv`
- `fig_thrust_*.png`, `fig_pressure_*.png`, `fig_traj3d_*.png`, etc.
- `summary_case_*.txt`

## Notes / assumptions (transparent)
- Aerodynamics uses a constant \(C_D\) (tune/sweep in config).
- Attitude dynamics are not modeled; thrust aligns with launch rail during rail phase and aligns with velocity after rail.
- Stability is computed using a **Barrowman-lite** approximation for CP.

If you want a higher-fidelity 6DOF rigid-body model later (pitch/yaw dynamics + aerodynamic moments), the structure here can be extended.
