\
from __future__ import annotations
from typing import Dict, Tuple
import math
import pandas as pd
import matplotlib.pyplot as plt

from .common import Environment, Geometry, Aero, Propulsion, Battery, aspect_ratio, induced_k, dynamic_pressure, weight_N, safe_div

def stall_speed(env: Environment, W: float, S: float, CLmax: float) -> float:
    return math.sqrt(safe_div(2.0*W, env.rho*S*CLmax))

def drag_and_power(env: Environment, geom: Geometry, aero: Aero, W: float, V: float) -> Tuple[float, float, float]:
    S = geom.wing.area_m2
    q = dynamic_pressure(env, V)
    CL = safe_div(W, q*S)
    k = induced_k(aero, geom.wing)
    CD = aero.CD0 + k * CL * CL
    D = q * S * CD
    P = D * V
    return D, P, CL

def endurance_minutes(batt: Battery) -> float:
    # usable Ah = capacity_mAh/1000 * usable_fraction
    usable_Ah = (batt.capacity_mAh/1000.0) * batt.usable_fraction
    hours = safe_div(usable_Ah, batt.avg_current_A, default=float("nan"))
    return hours * 60.0

def battery_energy_Wh(batt: Battery) -> float:
    Vnom = batt.cells * batt.nominal_cell_voltage_V
    Ah = batt.capacity_mAh/1000.0
    return Vnom * Ah * batt.usable_fraction

def performance_sweep(env: Environment, geom: Geometry, aero: Aero, propulsion: Propulsion, W: float, V_min: float, V_max: float, n: int = 50) -> pd.DataFrame:
    Vs = stall_speed(env, W, geom.wing.area_m2, aero.CL_max)
    V_min = max(V_min, 1.05*Vs)
    V_max = max(V_max, V_min + 1e-3)
    speeds = [V_min + (V_max-V_min)*i/(n-1) for i in range(n)]
    rows = []
    for V in speeds:
        D, P, CL = drag_and_power(env, geom, aero, W, V)
        rows.append({
            "V_mps": V,
            "V_kmh": 3.6*V,
            "Drag_N": D,
            "Power_W": P,
            "CL": CL,
            "T_required_N": D,
            "T_available_N": propulsion.thrust_available_N,
            "T_margin_N": propulsion.thrust_available_N - D
        })
    return pd.DataFrame(rows)

def plot_performance_curves(df: pd.DataFrame, out_png: str):
    plt.figure()
    plt.plot(df["V_kmh"], df["T_required_N"], label="Thrust required (N)")
    plt.plot(df["V_kmh"], df["T_available_N"], label="Thrust available (N)")
    plt.xlabel("Speed (km/h)")
    plt.ylabel("Thrust (N)")
    plt.legend()
    plt.tight_layout()
    plt.savefig(out_png, dpi=200)
    plt.close()

def summary(env: Environment, geom: Geometry, aero: Aero, propulsion: Propulsion, battery: Battery, mass_kg: float) -> pd.DataFrame:
    W = weight_N(env, mass_kg)
    S = geom.wing.area_m2
    AR = aspect_ratio(geom.wing)
    k = induced_k(aero, geom.wing)
    Vs = stall_speed(env, W, S, aero.CL_max)
    wing_loading = safe_div(W, S)
    tw = safe_div(propulsion.thrust_available_N, W)

    end_min = endurance_minutes(battery)
    E_Wh = battery_energy_Wh(battery)

    return pd.DataFrame([{
        "mass_kg": mass_kg,
        "W_N": W,
        "wing_area_m2": S,
        "wing_loading_Nm2": wing_loading,
        "AR": AR,
        "CD0": aero.CD0,
        "k_induced": k,
        "CL_max": aero.CL_max,
        "Vs_mps": Vs,
        "Vs_kmh": 3.6*Vs,
        "thrust_available_N": propulsion.thrust_available_N,
        "T_over_W": tw,
        "battery_energy_Wh": E_Wh,
        "endurance_est_min": end_min
    }])
