# Report Asset Guide

After running:
`python src/run_all.py --config configs/aircraft.yaml`

Use these in your report:

## Tables
- `outputs/weight_balance.csv` : component masses and CG
- `outputs/performance_summary.csv` : W/S, Vs, T/W, endurance estimate
- `outputs/stability_summary.csv` : Vh, Vv, neutral point, static margin

## Figures
- `outputs/weight_balance.png` : mass distribution bar chart
- `outputs/performance_curves.png` : thrust required vs available

## Recommended wording
Replace "Flight test observations" with **Virtual flight evaluation**, and cite:
- Stall speed estimate, cruise feasibility (T_margin > 0), endurance estimate
- Static margin sign/magnitude (positive indicates stability)

Update config values once you digitize the appendix plan.
