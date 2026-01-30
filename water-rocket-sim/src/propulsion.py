"""Water-rocket propulsion model.

Implements two phases:
1) Water expulsion: bottle air expands adiabatically (P*V^gamma = const)
2) Air blowdown: simplified isothermal blowdown with compressible nozzle flow

The outputs are a time profile of thrust, mass, and internal pressure.

This is designed for report-level evidence: T(t), P(t), m(t), mdot(t) and
total impulse.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Any

import numpy as np


@dataclass
class PropulsionProfile:
    t: np.ndarray
    thrust: np.ndarray
    pressure: np.ndarray
    mdot: np.ndarray
    mass: np.ndarray
    phase: np.ndarray  # 0=water, 1=air, 2=coast

    def total_impulse(self) -> float:
        return float(np.trapz(self.thrust, self.t))


def _nozzle_area(d: float) -> float:
    return float(np.pi * (d * 0.5) ** 2)


def compute_propulsion_profile(cfg: Dict[str, Any], case_overrides: Dict[str, Any]) -> PropulsionProfile:
    env = cfg["environment"]
    rocket = cfg["rocket"]
    prop = cfg["propulsion"]
    sim = cfg["simulation"]

    # Apply case overrides
    p0_g = float(case_overrides.get("p0_gauge", prop["p0_gauge"]))
    wf = float(case_overrides.get("water_fill_fraction", prop["water_fill_fraction"]))

    # Constants
    rho_w = float(prop["rho_water"])
    gamma = float(prop["gamma_air"])
    R = float(prop["R_air"])
    Patm = float(env["p_atm"])
    Tamb = float(env["T_air"])

    Vb = float(rocket["bottle_volume"])
    dt = float(sim["dt_prop"])
    tmax = float(sim["tmax_prop"])

    nozzle_d = float(prop["nozzle"]["diameter"])
    Cd_n = float(prop["nozzle"]["Cd"])
    An = _nozzle_area(nozzle_d)

    # Initial state
    Vw0 = wf * Vb
    Vair0 = Vb - Vw0
    P0 = Patm + p0_g

    # Air mass in bottle (ideal gas)
    m_air0 = P0 * Vair0 / (R * Tamb)

    m_dry = float(rocket["dry_mass"])
    m0 = m_dry + rho_w * Vw0 + m_air0

    n_steps = int(np.ceil(tmax / dt)) + 1
    t = np.zeros(n_steps)
    thrust = np.zeros(n_steps)
    pressure = np.zeros(n_steps)
    mdot = np.zeros(n_steps)
    mass = np.zeros(n_steps)
    phase = np.full(n_steps, 2, dtype=int)

    # -------- Phase 1: Water expulsion (adiabatic air expansion) --------
    Vw = Vw0
    Vair = Vair0
    m = m0

    # Adiabatic constant for trapped air
    K = P0 * (Vair0 ** gamma)

    i = 0
    while i < n_steps:
        t[i] = i * dt

        # Determine pressure from adiabatic expansion (until water runs out)
        if Vw > 0:
            P = K / (Vair ** gamma)
        else:
            P = Patm

        pressure[i] = P
        mass[i] = m

        # Stop thrust if internal pressure <= ambient
        if P <= Patm + 1.0:
            phase[i] = 2
            thrust[i] = 0.0
            mdot[i] = 0.0
            break

        if Vw <= 0:
            break

        # Exit velocity from Bernoulli (incompressible water jet)
        ve = np.sqrt(max(0.0, 2.0 * (P - Patm) / rho_w))
        mdot_w = Cd_n * rho_w * An * ve

        # Thrust (momentum term; pressure term neglected as Pe ~ Patm)
        T = mdot_w * ve

        phase[i] = 0
        thrust[i] = T
        mdot[i] = mdot_w

        # Update water volume and air volume
        dVw = (mdot_w / rho_w) * dt
        Vw_new = max(0.0, Vw - dVw)
        Vair_new = Vb - Vw_new

        # Update total mass (water leaves)
        m -= mdot_w * dt

        Vw, Vair = Vw_new, Vair_new
        i += 1

    i_water_end = i

    # -------- Phase 2: Air blowdown (simplified isothermal tank) --------
    # Start air phase if we still have pressure above ambient
    if i_water_end < n_steps:
        # Pressure at transition (use last valid values)
        if i_water_end > 0:
            P_start = pressure[i_water_end - 1]
        else:
            P_start = P0

        # Remaining air mass at start of air phase
        # Use ideal gas at current air volume (which is now Vb)
        m_air = P_start * Vb / (R * Tamb)

        # Replace state mass to be consistent (air mass included in total mass)
        # At this point, remaining water is zero.
        m = m_dry + m_air

        # Choking threshold
        pr_crit = ((gamma + 1.0) / 2.0) ** (gamma / (gamma - 1.0))

        while i < n_steps:
            t[i] = i * dt

            # Tank pressure from air mass (isothermal, V constant)
            P = (m_air * R * Tamb) / Vb
            pressure[i] = P
            mass[i] = m

            if P <= Patm + 1.0 or m_air <= 0:
                phase[i] = 2
                thrust[i] = 0.0
                mdot[i] = 0.0
                break

            # Nozzle mass flow for compressible air
            # Use standard isentropic relations, with tank as stagnation.
            # If choked: P/Pa >= pr_crit
            if (P / Patm) >= pr_crit:
                # Choked flow
                mdot_a = Cd_n * An * P * np.sqrt(gamma / (R * Tamb)) * (2.0 / (gamma + 1.0)) ** (
                    (gamma + 1.0) / (2.0 * (gamma - 1.0))
                )
                # Exit velocity at throat (approx): a*sqrt(2/(gamma+1))
                a = np.sqrt(gamma * R * Tamb)
                ve = a * np.sqrt(2.0 / (gamma + 1.0))
            else:
                # Unchoked (subsonic)
                term = (Patm / P) ** (2.0 / gamma) - (Patm / P) ** ((gamma + 1.0) / gamma)
                term = max(0.0, term)
                mdot_a = Cd_n * An * P * np.sqrt(2.0 * gamma / (R * Tamb * (gamma - 1.0)) * term)
                # Exit velocity approx from isentropic nozzle expansion
                ve = np.sqrt(max(0.0, 2.0 * gamma / (gamma - 1.0) * R * Tamb * (1.0 - (Patm / P) ** ((gamma - 1.0) / gamma))))

            T = mdot_a * ve

            phase[i] = 1
            thrust[i] = T
            mdot[i] = mdot_a

            # Update air mass and total mass
            m_air_new = max(0.0, m_air - mdot_a * dt)
            m = m_dry + m_air_new

            m_air = m_air_new
            i += 1

    # Trim arrays to used length
    last = np.nonzero(t > 0)[0]
    if len(last) == 0:
        n = 1
    else:
        n = int(last[-1]) + 1

    return PropulsionProfile(
        t=t[:n],
        thrust=thrust[:n],
        pressure=pressure[:n],
        mdot=mdot[:n],
        mass=mass[:n],
        phase=phase[:n],
    )
