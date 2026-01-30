\
from __future__ import annotations
import argparse
import os
import pandas as pd

from .io_utils import load_config, parse_models
from .weight_balance import compute_weight_balance, plot_weight_balance
from .performance import performance_sweep, plot_performance_curves, summary as perf_summary
from .stability import stability_summary

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", required=True, help="Path to configs/aircraft.yaml")
    ap.add_argument("--outdir", default="outputs", help="Output directory")
    # Optional reference points for stability calcs:
    ap.add_argument("--x_le_mac_m", type=float, default=0.30, help="Leading edge of MAC from nose (m) (EDIT after digitizing)")
    ap.add_argument("--x_ac_w_m", type=float, default=0.35, help="Wing aerodynamic center from nose (m) (EDIT after digitizing)")
    args = ap.parse_args()

    cfg = load_config(args.config)
    meta, env, geom, aero, propulsion, battery, masses_kg, positions_m = parse_models(cfg)

    outdir = args.outdir
    os.makedirs(outdir, exist_ok=True)

    # Weight & balance
    df_wb, m_total, x_cg = compute_weight_balance(env, masses_kg, positions_m)
    df_wb.to_csv(os.path.join(outdir, "weight_balance.csv"), index=False)
    plot_weight_balance(df_wb, os.path.join(outdir, "weight_balance.png"))

    # Performance summary + sweep curves
    df_perf_sum = perf_summary(env, geom, aero, propulsion, battery, m_total)
    df_perf_sum.to_csv(os.path.join(outdir, "performance_summary.csv"), index=False)

    df_sweep = performance_sweep(env, geom, aero, propulsion, W=df_perf_sum.loc[0, "W_N"], V_min=6.0, V_max=25.0, n=60)
    df_sweep.to_csv(os.path.join(outdir, "performance_sweep.csv"), index=False)
    plot_performance_curves(df_sweep, os.path.join(outdir, "performance_curves.png"))

    # Stability
    df_stab = stability_summary(geom, aero, x_cg_m=x_cg, x_le_mac_m=args.x_le_mac_m, x_ac_w_m=args.x_ac_w_m)
    df_stab.to_csv(os.path.join(outdir, "stability_summary.csv"), index=False)

    # Small console print
    name = meta.get("name", "Aircraft")
    print(f"== {name} ==")
    print(df_perf_sum.to_string(index=False))
    print(df_stab.to_string(index=False))
    print(f"Outputs written to: {outdir}/")

if __name__ == "__main__":
    main()
