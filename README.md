# Project 4 — Trim, Thrust Required, and Power Required (Cropped Delta Wing UAV)

This repository contains a MATLAB implementation (plus optional Excel-friendly outputs)
to analyze steady level **trim**, **thrust required**, and **power required** for a cropped
delta wing UAV over an angle-of-attack sweep.

## Assignment scope (what this repo delivers)
- Pre-processing geometry (taper ratio, area, AR, induced-drag factor)
- Trim solution: elevator deflection δe,trim from Cm = 0
- Aerodynamics: CL(α,δe), CD = CD0 + k CL^2
- Level-flight equilibrium: solve V from L=W
- Performance: thrust required Tr = D and power required Pr = Tr·V
- Metrics: CL/CD and CL^(3/2)/CD
- Plots (8 required figures) + exported data (CSV)

## Quick start
1. Open MATLAB.
2. Set the working directory to this repository root.
3. Run:

```matlab
run("src/main_project4.m");
```

Outputs are written to:
- `outputs/data/project4_results.csv`
- `outputs/figures/*.png`

## Files
- `src/main_project4.m` — main driver (single-run, produces figures + CSV)
- `src/uav_params_project4.m` — all given constants in one place
- `src/compute_geometry.m` — λ, S, AR, k
- `src/trim_at_alpha.m` — δe,trim and CL, CD, V, Tr, Pr at a given α
- `src/plot_results.m` — plotting utilities
- `tests/selfcheck_project4.m` — quick numerical sanity checks

## Notes / assumptions
- Sea-level density ρ and constant g are used as provided.
- Angles are handled in radians internally; plots are shown in degrees.
- The assignment sheet does not explicitly provide CL0. This implementation uses **CL0 = 0**
  (common for a symmetric reference line). If your instructor specifies a different CL0,
  change it in `src/uav_params_project4.m`.

## Reproducibility
The code is deterministic (no randomness).
