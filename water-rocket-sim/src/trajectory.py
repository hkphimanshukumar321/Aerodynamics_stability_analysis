"""2D trajectory simulation.

Passing requirement: simulate trajectory with thrust + drag + gravity, and
report key metrics (apogee, time-of-flight, range) for each case.

Approach:
- Phase 1: motion constrained to launch rail (1D along rail axis)
- Phase 2: free-flight in 2D (x horizontal, z vertical)

Thrust and vehicle mass come from propulsion profile (interpolated).
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Any, Callable

import numpy as np
from scipy.integrate import solve_ivp

from .propulsion import PropulsionProfile


@dataclass
class TrajectoryResult:
    t: np.ndarray
    x: np.ndarray
    z: np.ndarray
    vx: np.ndarray
    vz: np.ndarray
    apogee: float
    tof: float
    range: float


def _interp1(tq: float, t: np.ndarray, y: np.ndarray) -> float:
    if tq <= t[0]:
        return float(y[0])
    if tq >= t[-1]:
        return float(y[-1])
    return float(np.interp(tq, t, y))


def simulate_trajectory(cfg: Dict[str, Any], case_overrides: Dict[str, Any], prof: PropulsionProfile) -> TrajectoryResult:
    env = cfg["environment"]
    rocket = cfg["rocket"]
    launch = cfg["launch"]
    sim = cfg["simulation"]

    g = float(env["g"])
    rho_air = float(env["rho_air"])
    wind_x = float(env.get("wind_x", 0.0))

    Cd = float(rocket["Cd"])
    Aref = float(rocket["ref_area"])

    rail_L = float(launch["rail_length"])
    theta = np.deg2rad(float(launch["angle_deg"]))

    tmax = float(sim["tmax_traj"])
    rtol = float(sim.get("rtol", 1e-7))
    atol = float(sim.get("atol", 1e-9))

    # Convenience accessors
    def T_of(t: float) -> float:
        return _interp1(t, prof.t, prof.thrust)

    def m_of(t: float) -> float:
        return _interp1(t, prof.t, prof.mass)

    # ------------------------- Phase 1: along rail -------------------------
    # State: [s, v] along rail direction
    def f_rail(t: float, y: np.ndarray) -> np.ndarray:
        s, v = float(y[0]), float(y[1])

        m = max(1e-6, m_of(t))
        T = T_of(t)

        # Relative airspeed along axis (wind projected)
        v_rel = v - wind_x * np.cos(theta)
        D = 0.5 * rho_air * Cd * Aref * v_rel * abs(v_rel)

        # Gravity component along rail (opposes upward motion)
        g_along = g * np.sin(theta)

        a = (T - D) / m - g_along
        return np.array([v, a], dtype=float)

    def event_rail_end(t: float, y: np.ndarray) -> float:
        return y[0] - rail_L

    event_rail_end.terminal = True
    event_rail_end.direction = 1

    y0_rail = np.array([0.0, 0.0], dtype=float)
    sol1 = solve_ivp(
        f_rail,
        t_span=(0.0, tmax),
        y0=y0_rail,
        events=event_rail_end,
        rtol=rtol,
        atol=atol,
        max_step=0.02,
    )

    t1 = sol1.t
    s1, v1 = sol1.y[0], sol1.y[1]

    # If rail never ended, we still continue with free-flight from last point
    if sol1.t_events and len(sol1.t_events[0]) > 0:
        t_rail_end = float(sol1.t_events[0][0])
        s_end = rail_L
        v_end = float(np.interp(t_rail_end, t1, v1))
    else:
        t_rail_end = float(t1[-1])
        s_end = float(s1[-1])
        v_end = float(v1[-1])

    x_end = s_end * np.cos(theta)
    z_end = s_end * np.sin(theta)
    vx_end = v_end * np.cos(theta)
    vz_end = v_end * np.sin(theta)

    # ------------------------- Phase 2: free-flight 2D -------------------------
    # State: [x, z, vx, vz]
    def f_free(t: float, y: np.ndarray) -> np.ndarray:
        x, z, vx, vz = map(float, y)
        m = max(1e-6, m_of(t))
        T = T_of(t)

        # Relative wind
        vrel_x = vx - wind_x
        vrel_z = vz
        vrel = np.hypot(vrel_x, vrel_z)

        # Drag
        if vrel < 1e-6:
            Dx, Dz = 0.0, 0.0
        else:
            Dmag = 0.5 * rho_air * Cd * Aref * vrel**2
            Dx = Dmag * (vrel_x / vrel)
            Dz = Dmag * (vrel_z / vrel)

        # Thrust direction: assume aligned with velocity; if near-zero, keep launch direction
        if (vx**2 + vz**2) > 1e-8:
            ux, uz = vx / np.hypot(vx, vz), vz / np.hypot(vx, vz)
        else:
            ux, uz = np.cos(theta), np.sin(theta)

        Tx, Tz = T * ux, T * uz

        ax = (Tx - Dx) / m
        az = (Tz - Dz) / m - g

        return np.array([vx, vz, ax, az], dtype=float)

    def event_ground(t: float, y: np.ndarray) -> float:
        # z = 0 crossing on descent
        return y[1]

    event_ground.terminal = True
    event_ground.direction = -1

    y0_free = np.array([x_end, z_end, vx_end, vz_end], dtype=float)
    sol2 = solve_ivp(
        f_free,
        t_span=(t_rail_end, tmax),
        y0=y0_free,
        events=event_ground,
        rtol=rtol,
        atol=atol,
        max_step=0.05,
    )

    # Combine time histories
    t2 = sol2.t
    x2, z2, vx2, vz2 = sol2.y

    # Build combined arrays (avoid duplicating rail-end point)
    # Convert rail-phase to x,z for plotting
    x1 = s1 * np.cos(theta)
    z1 = s1 * np.sin(theta)
    vx1 = v1 * np.cos(theta)
    vz1 = v1 * np.sin(theta)

    if len(t2) > 0 and len(t1) > 0:
        # Remove last point of phase 1 if it matches first point of phase 2
        if abs(t1[-1] - t2[0]) < 1e-12:
            t1c = t1[:-1]
            x1c, z1c, vx1c, vz1c = x1[:-1], z1[:-1], vx1[:-1], vz1[:-1]
        else:
            t1c = t1
            x1c, z1c, vx1c, vz1c = x1, z1, vx1, vz1
    else:
        t1c = t1
        x1c, z1c, vx1c, vz1c = x1, z1, vx1, vz1

    t_all = np.concatenate([t1c, t2])
    x_all = np.concatenate([x1c, x2])
    z_all = np.concatenate([z1c, z2])
    vx_all = np.concatenate([vx1c, vx2])
    vz_all = np.concatenate([vz1c, vz2])

    # Key metrics
    apogee = float(np.max(z_all))
    tof = float(t_all[-1])
    rng = float(x_all[-1])

    return TrajectoryResult(
        t=t_all,
        x=x_all,
        z=z_all,
        vx=vx_all,
        vz=vz_all,
        apogee=apogee,
        tof=tof,
        range=rng,
    )
