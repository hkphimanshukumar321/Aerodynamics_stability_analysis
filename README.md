# Robotic Manipulator Simulation (MATLAB-only, no toolboxes required)

This repo implements a complete **simulation-only** robotic manipulator project in MATLAB:
- URDF/CAD is *not required*; we use a **DH-parameter** kinematic model.
- Forward kinematics (FK), numerical Jacobian, and **Damped Least Squares (DLS)** inverse kinematics (IK).
- Pick-and-place task planning with **quintic joint-space trajectories**.
- Generates plots + metrics and optionally a demo video (`.mp4`) using `VideoWriter`.

## Requirements
- MATLAB R2018b+ recommended (older versions may still work).
- **No Robotics System Toolbox required.** Uses only base MATLAB functions.

## One-command run (recommended)
From the repo root in MATLAB:
```matlab
run_all
```

This will:
1. Run self-tests (FK/IK sanity + mm-level IK verification)
2. Solve IK for pick/place waypoints
3. Generate smooth quintic trajectories
4. Animate the robot in 3D (stick model)
5. Save results to `results/`:
   - `ik_error_stats.csv`
   - `traj_q.png`, `traj_qdot.png`, `traj_qddot.png`
   - `workspace.png`
   - `demo_pick_place.mp4` (if video enabled)

## File layout
- `src/` : core math (FK/IK/Jacobian/trajectory)
- `sim/` : scenario definition + animation
- `results/` : generated outputs

## Notes on accuracy target (<1 mm)
The IK solver targets **position-only** (3D) with a 4-DOF arm. With proper damping and tolerances,
the end-effector position error reaches sub-mm for typical reachable targets.

If you change link lengths or targets, re-run `run_all` and inspect `results/ik_error_stats.csv`.

## Troubleshooting
- If video writing fails, set `cfg.makeVideo = false;` in `sim/sim_config.m`.
- If IK fails to converge, increase `cfg.ik.maxIters` or damping `cfg.ik.lambda`.
