# XFLR5 Workflow (Aero + Stability + Stall Speed)

Goal: produce report-ready **CLmax**, polars, and stability trends.

## 1) Import Airfoil
Use provided `airfoils/NACA2412.dat`.
XFLR5: File → Open → select the DAT.

## 2) Create Wing
Wing & Plane design → Define a New Wing:
- Set span b
- Root chord c (tip chord = root for rectangular)
- Assign NACA2412 airfoil

## 3) 3D Polars
Analysis → 3D Analysis (LLT or VLM2)
- Alpha sweep: -4° to +16° (or until limit)
Export polar data (CSV).

From CL vs alpha, read **CLmax** (peak CL).

## 4) Stability
Define a Plane (main wing + tail) and run:
Analysis → Stability analysis
Sweep CG (e.g., 20%–40% MAC).
Record neutral point / static margin.

## 5) Stall Speed (use in report)
Vs = sqrt(2W / (rho*S*CLmax))

Then update MATLAB:
- set `p.aero.CLmax = (your XFLR5 CLmax)` in `matlab/config/params_user.m`
- rerun `main_run_all`
