# RC Trainer Virtual Flight-Test Repository (MATLAB/Simulink + XFLR5)

This repository provides a **simulation-first deliverables pack** for a foamboard RC trainer aircraft project.
It generates **report-ready** plots and tables for:
- Mass budget and sizing (W/S, T/W, stall speed)
- Level-flight trim estimate
- Linear flight dynamics step responses (virtual flight tests)
- Stability diagnostics (eigenvalues/modes)
- XFLR5 workflow for CLmax + stability and stall speed

## Folder structure
- `matlab/` : one-click MATLAB pipeline (plots/tables -> `results/`)
- `simulink/` : simple longitudinal state-space Simulink model
- `xflr5/` : airfoil + step-by-step workflow

## Quick start (MATLAB)
1. Open MATLAB, set current folder to `matlab/`
2. Edit: `matlab/config/params_user.m`
3. Run:
```matlab
main_run_all
```
Outputs are written to `../results/`.

## Quick start (Simulink)
See `simulink/README.md`.

## XFLR5 workflow
See `xflr5/README_XFLR5.md`.

## MATLAB first run
After unzipping, open MATLAB and run:

    cd <repo>/matlab
    startup
    main_run_all



## Smoke test (recommended)
In MATLAB:
```matlab
cd path_to_repo/matlab
smoke_test
```
If it passes, the full pipeline is correctly installed.
