"""Plot helpers (matplotlib)."""

from __future__ import annotations

from pathlib import Path
from typing import Optional

import matplotlib.pyplot as plt
import numpy as np


def save_fig(path: Path, dpi: int = 200) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    plt.tight_layout()
    plt.savefig(path, dpi=dpi)
    plt.close()


def plot_propulsion(case_name: str, outdir: Path, t: np.ndarray, thrust: np.ndarray, pressure: np.ndarray, mdot: np.ndarray, mass: np.ndarray) -> None:
    # Thrust
    plt.figure()
    plt.plot(t, thrust)
    plt.xlabel("Time (s)")
    plt.ylabel("Thrust (N)")
    plt.title(f"Thrust vs Time — {case_name}")
    save_fig(outdir / f"{case_name}_thrust.png")

    # Pressure
    plt.figure()
    plt.plot(t, pressure)
    plt.xlabel("Time (s)")
    plt.ylabel("Bottle Pressure (Pa)")
    plt.title(f"Pressure vs Time — {case_name}")
    save_fig(outdir / f"{case_name}_pressure.png")

    # Mass flow
    plt.figure()
    plt.plot(t, mdot)
    plt.xlabel("Time (s)")
    plt.ylabel("Mass flow (kg/s)")
    plt.title(f"Mass flow vs Time — {case_name}")
    save_fig(outdir / f"{case_name}_mdot.png")

    # Total mass
    plt.figure()
    plt.plot(t, mass)
    plt.xlabel("Time (s)")
    plt.ylabel("Rocket Mass (kg)")
    plt.title(f"Mass vs Time — {case_name}")
    save_fig(outdir / f"{case_name}_mass.png")


def plot_trajectory(case_name: str, outdir: Path, t: np.ndarray, x: np.ndarray, z: np.ndarray, vx: np.ndarray, vz: np.ndarray) -> None:
    # Trajectory
    plt.figure()
    plt.plot(x, z)
    plt.xlabel("Downrange x (m)")
    plt.ylabel("Altitude z (m)")
    plt.title(f"Trajectory — {case_name}")
    save_fig(outdir / f"{case_name}_trajectory.png")

    # Altitude vs time
    plt.figure()
    plt.plot(t, z)
    plt.xlabel("Time (s)")
    plt.ylabel("Altitude z (m)")
    plt.title(f"Altitude vs Time — {case_name}")
    save_fig(outdir / f"{case_name}_altitude.png")

    # Speed vs time
    plt.figure()
    speed = np.sqrt(vx**2 + vz**2)
    plt.plot(t, speed)
    plt.xlabel("Time (s)")
    plt.ylabel("Speed (m/s)")
    plt.title(f"Speed vs Time — {case_name}")
    save_fig(outdir / f"{case_name}_speed.png")
