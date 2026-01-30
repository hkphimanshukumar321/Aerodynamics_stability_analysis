\
from __future__ import annotations
from typing import Dict
import math
import pandas as pd

from .common import Geometry, Aero, Wing, safe_div, aspect_ratio

def tail_volume_coefficients(geom: Geometry) -> Dict[str, float]:
    S = geom.wing.area_m2
    b = geom.wing.span_m
    cbar = geom.wing.mean_chord_m
    St = geom.tail.horizontal_area_m2
    Sv = geom.tail.vertical_area_m2
    lt = geom.tail.tail_arm_h_m
    lv = geom.tail.tail_arm_v_m
    Vh = safe_div(St*lt, S*cbar)
    Vv = safe_div(Sv*lv, S*b)
    return {"Vh": Vh, "Vv": Vv}

def neutral_point_estimate_x_ac(geom: Geometry, aero: Aero,
                               x_ac_w_m: float,
                               a_w_per_rad: float = 5.7,
                               a_t_per_rad: float = 4.0,
                               eta_tail: float = 0.9,
                               downwash_deda: float = 0.30) -> float:
    """
    Very simplified neutral-point estimate:
      x_np = x_ac_w + eta * Vh * (a_t/a_w) * (1 - de/da) * cbar
    where x locations are from the same reference (nose).
    """
    vols = tail_volume_coefficients(geom)
    Vh = vols["Vh"]
    cbar = geom.wing.mean_chord_m
    delta = eta_tail * Vh * safe_div(a_t_per_rad, a_w_per_rad) * (1.0 - downwash_deda) * cbar
    return x_ac_w_m + delta

def stability_summary(geom: Geometry, aero: Aero, x_cg_m: float,
                      x_le_mac_m: float,
                      x_ac_w_m: float) -> pd.DataFrame:
    vols = tail_volume_coefficients(geom)
    x_np = neutral_point_estimate_x_ac(geom, aero, x_ac_w_m=x_ac_w_m)
    cbar = geom.wing.mean_chord_m
    static_margin = safe_div((x_np - x_cg_m), cbar)  # positive => statically stable
    cg_percent_mac = safe_div((x_cg_m - x_le_mac_m), cbar) * 100.0
    np_percent_mac = safe_div((x_np - x_le_mac_m), cbar) * 100.0
    return pd.DataFrame([{
        "Vh": vols["Vh"],
        "Vv": vols["Vv"],
        "x_cg_m": x_cg_m,
        "x_np_m": x_np,
        "static_margin_cbar": static_margin,
        "cg_percent_MAC": cg_percent_mac,
        "np_percent_MAC": np_percent_mac
    }])
