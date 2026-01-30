\
from __future__ import annotations
from typing import Dict, Tuple
import pandas as pd
import matplotlib.pyplot as plt

from .common import Environment, weight_N

def compute_weight_balance(env: Environment, masses_kg: Dict[str, float], positions_m: Dict[str, float]) -> Tuple[pd.DataFrame, float, float]:
    rows = []
    total_m = 0.0
    total_mx = 0.0
    for k, m in masses_kg.items():
        x = float(positions_m.get(k, 0.0))
        rows.append({"component": k, "mass_kg": m, "x_m": x, "m*x": m*x})
        total_m += m
        total_mx += m*x

    x_cg = total_mx / total_m if total_m > 0 else float("nan")
    W = weight_N(env, total_m)
    df = pd.DataFrame(rows).sort_values("x_m").reset_index(drop=True)
    df.loc[len(df)] = {"component": "TOTAL", "mass_kg": total_m, "x_m": x_cg, "m*x": total_mx}
    return df, total_m, x_cg

def plot_weight_balance(df: pd.DataFrame, out_png: str):
    d = df[df["component"] != "TOTAL"].copy()
    plt.figure()
    plt.bar(d["component"], d["mass_kg"])
    plt.xticks(rotation=45, ha="right")
    plt.ylabel("Mass (kg)")
    plt.tight_layout()
    plt.savefig(out_png, dpi=200)
    plt.close()
