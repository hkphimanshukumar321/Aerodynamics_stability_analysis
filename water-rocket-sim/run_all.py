#!/usr/bin/env python3
"""One-command runner.

Usage:
  python run_all.py --config configs/default.yaml

Outputs:
  results/<case_name>_*.png
  results/summary.csv
  results/stability.csv

Designed to be error-free and minimal effort from user.
"""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Dict, Any

import pandas as pd

from src.config import load_yaml
from src.propulsion import compute_propulsion_profile
from src.trajectory import simulate_trajectory
from src.stability import compute_stability
from src.plotting import plot_propulsion, plot_trajectory


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", type=str, default="configs/default.yaml", help="Path to YAML config")
    ap.add_argument("--outdir", type=str, default="results", help="Output directory")
    args = ap.parse_args()

    cfg = load_yaml(args.config)
    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    summary_rows = []
    stability_rows = []

    for case in cfg["cases"]:
        name = case["name"]

        # 1) Propulsion
        prof = compute_propulsion_profile(cfg, case)

        # 2) Stability
        stab = compute_stability(cfg, case)

        # 3) Trajectory
        traj = simulate_trajectory(cfg, case, prof)

        # 4) Plots
        plot_propulsion(name, outdir, prof.t, prof.thrust, prof.pressure, prof.mdot, prof.mass)
        plot_trajectory(name, outdir, traj.t, traj.x, traj.z, traj.vx, traj.vz)

        # 5) Summary metrics
        # Burn time = last time thrust > 0
        import numpy as np

        idx = np.where(prof.thrust > 1e-6)[0]
        t_burn = float(prof.t[idx[-1]]) if len(idx) else 0.0
        I_tot = prof.total_impulse()

        summary_rows.append(
            {
                "case": name,
                "p0_gauge_Pa": float(case.get("p0_gauge", cfg["propulsion"]["p0_gauge"])),
                "water_fill_fraction": float(case.get("water_fill_fraction", cfg["propulsion"]["water_fill_fraction"])),
                "total_impulse_Ns": I_tot,
                "burn_time_s": t_burn,
                "apogee_m": traj.apogee,
                "time_of_flight_s": traj.tof,
                "range_m": traj.range,
            }
        )

        stability_rows.append(
            {
                "case": name,
                "x_cg_full_m": stab.x_cg_full,
                "x_cg_empty_m": stab.x_cg_empty,
                "x_cp_m": stab.x_cp,
                "static_margin_full_calibers": stab.static_margin_full,
                "static_margin_empty_calibers": stab.static_margin_empty,
            }
        )

    # Save tables
    df_sum = pd.DataFrame(summary_rows).sort_values(by="case")
    df_stab = pd.DataFrame(stability_rows).sort_values(by="case")

    df_sum.to_csv(outdir / "summary.csv", index=False)
    df_stab.to_csv(outdir / "stability.csv", index=False)

    # Also dump a short markdown report fragment for easy copy into your report
    md = []
    md.append("# Water Rocket Simulation Results\n")
    md.append("## Summary\n")
    md.append(df_sum.to_markdown(index=False))
    md.append("\n## Stability (Static Margin)\n")
    md.append(df_stab.to_markdown(index=False))
    (outdir / "results.md").write_text("\n".join(md), encoding="utf-8")

    print(f"Done. Outputs saved to: {outdir.resolve()}")


if __name__ == "__main__":
    main()
