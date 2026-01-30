# 2L Water Rocket Simulation (Trajectory + Thrust + Stability)

This repo is **simulation-only** and meets the typical *passing* deliverables:
- **Propulsion evidence:** `T(t)`, `P(t)`, `\dot m(t)`, `m(t)`, total impulse
- **Trajectory evidence:** altitude, speed, and 2D trajectory
- **Stability proof:** CG vs CP and static margin (full vs empty)

## Quick start

```bash
pip install -r requirements.txt
python run_all.py --config configs/default.yaml
```

Outputs are written to `results/`:
- `*_thrust.png`, `*_pressure.png`, `*_mdot.png`, `*_mass.png`
- `*_trajectory.png`, `*_altitude.png`, `*_speed.png`
- `summary.csv`, `stability.csv`, `results.md`

## How to change test cases
Edit `configs/default.yaml` under `cases:` to sweep:
- `p0_gauge` (Pa)
- `water_fill_fraction` (0–1)

## Model notes (what is implemented)

### Propulsion
1) **Water phase:** incompressible nozzle jet + adiabatic air expansion
\[
P(t)V_{air}(t)^\gamma = \text{const},\quad v_e=\sqrt{\tfrac{2(P-P_a)}{\rho_w}},\quad \dot m = C_d\rho_w A_n v_e,\quad T\approx \dot m v_e
\]
2) **Air phase:** simplified **isothermal** blowdown with compressible nozzle flow (choked / unchoked logic).

### Trajectory
- **Rail-constrained (1D)** until `rail_length`
- **Free-flight (2D)** with thrust aligned to velocity and quadratic drag

### Stability
- CG shifts due to water depletion (full → empty)
- CP estimated with a Barrowman-style fin contribution + simple body term
- Static margin reported in calibers: \((x_{CP}-x_{CG})/D\)

## Folder layout
- `src/`: simulation code
- `configs/`: YAML configs
- `results/`: generated plots/tables

