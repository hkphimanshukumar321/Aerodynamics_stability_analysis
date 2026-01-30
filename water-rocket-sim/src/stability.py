"""Static stability (CG/CP) estimation for a 2L-bottle water rocket.

Goal (passing requirement): provide a defensible stability argument via
static margin = (CP - CG) / body_diameter.

We use a Barrowman-style estimate for CP dominated by fins, plus a simple
body contribution.

Notes:
- This is a low-Mach, small-angle model; good enough for coursework proof.
- CP is not strongly time-varying, but CG shifts as water is expelled.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Any

import numpy as np


@dataclass
class StabilityResult:
    x_cg_full: float
    x_cg_empty: float
    x_cp: float
    static_margin_full: float
    static_margin_empty: float


def _fin_cnalpha(n_fins: int, span: float, body_d: float, root_chord: float, tip_chord: float) -> float:
    """Normal-force slope contribution for fins (Barrowman)."""
    # Mid-chord line length
    s = span
    Cr, Ct = root_chord, tip_chord
    # Reference area scaling per Barrowman
    # (s/D)^2 factor captures fin leverage
    term1 = (n_fins * (s / body_d) ** 2)
    term2 = 1.0 + np.sqrt(1.0 + (2.0 * s / (Cr + Ct)) ** 2)
    return float(term1 / term2)


def _fin_xcp_from_nose(x_root_le: float, root_chord: float, tip_chord: float, sweep: float) -> float:
    """CP location of trapezoidal fin set (Barrowman)."""
    Cr, Ct = root_chord, tip_chord
    # Distance from fin leading edge at root to mean aerodynamic chord quarter-chord
    x = x_root_le + (sweep * (Cr + 2.0 * Ct) / (3.0 * (Cr + Ct))) + (Cr + Ct - (Cr * Ct) / (Cr + Ct)) / 4.0
    return float(x)


def estimate_cp(cfg: Dict[str, Any]) -> float:
    """Estimate overall CP (x from nose)."""
    rocket = cfg["rocket"]
    L = float(rocket["body_length"])
    D = float(rocket["body_diameter"])

    fins = rocket["fins"]
    n = int(fins["n"])
    s = float(fins["span"])
    Cr = float(fins["root_chord"])
    Ct = float(fins["tip_chord"])
    sweep = float(fins["sweep_length"])
    x_root_le = float(fins["x_root_le_from_nose"])

    # Body contribution (very simplified): CP around mid-body
    cn_body = 1.0
    xcp_body = 0.5 * L

    # Fin contribution (Barrowman-style)
    cn_fins = _fin_cnalpha(n, s, D, Cr, Ct)
    xcp_fins = _fin_xcp_from_nose(x_root_le, Cr, Ct, sweep)

    # Weighted average
    x_cp = (cn_body * xcp_body + cn_fins * xcp_fins) / (cn_body + cn_fins)
    return float(x_cp)


def estimate_cg_full_empty(cfg: Dict[str, Any], case_overrides: Dict[str, Any]) -> tuple[float, float]:
    """Compute CG at (full water) and (empty water), x from nose."""
    env = cfg["environment"]
    rocket = cfg["rocket"]
    prop = cfg["propulsion"]

    Vb = float(rocket["bottle_volume"])
    L = float(rocket["body_length"])

    rho_w = float(prop["rho_water"])
    Patm = float(env["p_atm"])
    Tamb = float(env["T_air"])
    R = float(prop["R_air"])

    p0_g = float(case_overrides.get("p0_gauge", prop["p0_gauge"]))
    wf = float(case_overrides.get("water_fill_fraction", prop["water_fill_fraction"]))

    Vw0 = wf * Vb
    Vair0 = Vb - Vw0
    P0 = Patm + p0_g

    m_dry = float(rocket["dry_mass"])
    x_cg_dry = float(rocket["dry_cg_from_nose"])

    # Air mass (small but included)
    m_air0 = P0 * Vair0 / (R * Tamb)
    m_air_end = Patm * Vb / (R * Tamb)  # after equalizing to ambient (approx)

    # Water CG: assume water occupies tail segment of length proportional to volume fraction
    # Coordinate: x from nose, tail at x=L.
    h = wf * L
    x_cg_water = L - 0.5 * h

    # Air CG: assume distributed in remaining volume; approximate at centroid of air volume.
    # With water present, air occupies the nose side segment.
    x_cg_air0 = 0.5 * (L - h)
    x_cg_air_end = 0.5 * L

    # Full (water + air + dry)
    m_full = m_dry + rho_w * Vw0 + m_air0
    x_full = (m_dry * x_cg_dry + (rho_w * Vw0) * x_cg_water + m_air0 * x_cg_air0) / m_full

    # Empty water
    m_empty = m_dry + m_air_end
    x_empty = (m_dry * x_cg_dry + m_air_end * x_cg_air_end) / m_empty

    return float(x_full), float(x_empty)


def compute_stability(cfg: Dict[str, Any], case_overrides: Dict[str, Any]) -> StabilityResult:
    rocket = cfg["rocket"]
    D = float(rocket["body_diameter"])

    x_cp = estimate_cp(cfg)
    x_cg_full, x_cg_empty = estimate_cg_full_empty(cfg, case_overrides)

    sm_full = (x_cp - x_cg_full) / D
    sm_empty = (x_cp - x_cg_empty) / D

    return StabilityResult(
        x_cg_full=x_cg_full,
        x_cg_empty=x_cg_empty,
        x_cp=x_cp,
        static_margin_full=float(sm_full),
        static_margin_empty=float(sm_empty),
    )
