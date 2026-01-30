# Foamboard RC Trainer — Virtual Design & Validation Repository

This repository implements a **Design–Analysis–Virtual Validation** workflow for the "Foamboard RC Trainer Aircraft" project when physical fabrication/flight testing resources are unavailable.

It is aligned with the project brief deliverables:
- **Design methodology**
- **Calculations and assumptions**
- **Virtual flight evaluation (trim/stability/performance)**
- **Figures/tables for the report**

> Baseline constraints from the brief: wingspan 1050 mm, fuselage length 720 mm, MTOW 860 g, 4-channel controls. (See `/docs/project_brief.pdf`.)

---

## 1) What you will produce (deliverables-equivalent)

- Geometry parameter table (from appendix plan → digitized parameters)
- Weight breakdown + CG estimate
- Wing loading, stall speed, cruise performance, endurance estimate
- Static stability indicators (tail volume coefficients + simple neutral-point estimate)
- Plots and CSV tables ready to paste into the report

All results are written to `./outputs/`.

---

## 2) Quickstart

### 2.1 Create environment
```bash
python -m venv .venv
# Windows: .venv\Scripts\activate
source .venv/bin/activate
pip install -r requirements.txt
```

### 2.2 Edit the configuration
Update:
- `configs/aircraft.yaml` (geometry, masses, aero, propulsion, battery)
- Optionally add more accurate values once you digitize the appendix plan.

### 2.3 Run the pipeline
```bash
python src/run_all.py --config configs/aircraft.yaml
```

Outputs:
- `outputs/weight_balance.csv`, `outputs/weight_balance.png`
- `outputs/performance_summary.csv`, `outputs/performance_curves.png`
- `outputs/stability_summary.csv`

---

## 3) Suggested geometry workflow (Appendix → numbers)

The appendix provides a plan. Convert it to numeric parameters using either:
- **OpenVSP** (recommended) to build a parametric model and read off reference area, MAC, tail arms, etc.
- Or manual measurement from the printed plan (A4 tiled print) and scale using the known wingspan (1.05 m).

Minimum parameters you need for this repo:
- Wing: span `b`, area `S`, mean chord `c_bar`, taper `lambda`
- Tail: horizontal area `S_t`, vertical area `S_v`, tail arms `l_t`, `l_v`
- Aerodynamics: `CL_max`, `CD0`, Oswald efficiency `e`

---

## 4) Engineering models used (simple & defendable)

- Wing loading: `W/S`
- Stall speed: `Vs = sqrt( 2W / (rho S CL_max) )`
- Drag polar: `CD = CD0 + k CL^2`, where `k = 1/(pi e AR)`
- Level-flight trim proxy via CL required at speed
- Tail volume coefficients:
  - `Vh = (S_t*l_t)/(S*c_bar)`
  - `Vv = (S_v*l_v)/(S*b)`
- Neutral point (very simplified): wing AC + tail contribution

These are **first-order** estimates suitable for an academic mini project when experimental tests are not possible.

---

## 5) Folder structure

```
configs/   -> aircraft inputs (YAML)
src/       -> analysis code
outputs/   -> generated plots and CSVs
docs/      -> project brief + report figure placeholders
notebooks/ -> optional interactive exploration
```

---

## 6) License
MIT (for academic use).
