# Tail-sitter VTOL UAV (Simulation-only) — MATLAB + Python

## What you do (minimal)
1) (Optional) edit: `0_requirements/requirements.yaml`
2) Run Python (Steps 1–3):
   ```bash
   python 6_simulation/run_all.py
   ```
3) Run MATLAB (Steps 4–5):
   ```matlab
   run 6_simulation/run_all.m
   ```

## Outputs (report-ready)
All outputs go to: `report/artifacts/`
- requirements_table.csv (+ mission_profile.png)
- mass_breakdown.csv (+ mass_breakdown.png)
- propulsion_sizing.csv (+ hover_power_vs_thrust.png)
- endurance_estimates.csv (+ endurance_bounds.png)
- aero_summary.csv (+ polar_curve.png, ld_vs_speed.png)
- spar_analysis.csv (+ spar_deflection.png)
- motor_mount_stress.csv
- sim_summary.csv (+ sim_time_series.png)

No PX4, no Gazebo.
