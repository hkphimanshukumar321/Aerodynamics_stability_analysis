"""Configuration loader + lightweight validation.

Keeps the project reproducible: all parameters live in YAML.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List

import yaml


class ConfigError(ValueError):
    pass


def _req(d: Dict[str, Any], key: str) -> Any:
    if key not in d:
        raise ConfigError(f"Missing required key: {key}")
    return d[key]


def load_yaml(path: str | Path) -> Dict[str, Any]:
    path = Path(path)
    if not path.exists():
        raise ConfigError(f"Config file not found: {path}")
    with path.open("r", encoding="utf-8") as f:
        cfg = yaml.safe_load(f)
    if not isinstance(cfg, dict):
        raise ConfigError("Top-level YAML must be a mapping/dict")
    validate_config(cfg)
    return cfg


def validate_config(cfg: Dict[str, Any]) -> None:
    # Existence checks
    for section in ["environment", "rocket", "launch", "propulsion", "simulation", "cases"]:
        _req(cfg, section)

    env = cfg["environment"]
    rocket = cfg["rocket"]
    launch = cfg["launch"]
    prop = cfg["propulsion"]
    sim = cfg["simulation"]

    # Basic type/value checks
    def pos(name: str, v: Any) -> None:
        if not isinstance(v, (int, float)) or v <= 0:
            raise ConfigError(f"{name} must be a positive number")

    def nonneg(name: str, v: Any) -> None:
        if not isinstance(v, (int, float)) or v < 0:
            raise ConfigError(f"{name} must be a nonnegative number")

    pos("environment.g", env.get("g", 0))
    pos("environment.rho_air", env.get("rho_air", 0))
    pos("environment.p_atm", env.get("p_atm", 0))
    pos("environment.T_air", env.get("T_air", 0))

    pos("rocket.bottle_volume", rocket.get("bottle_volume", 0))
    pos("rocket.body_length", rocket.get("body_length", 0))
    pos("rocket.body_diameter", rocket.get("body_diameter", 0))
    pos("rocket.ref_area", rocket.get("ref_area", 0))
    pos("rocket.dry_mass", rocket.get("dry_mass", 0))

    fins = _req(rocket, "fins")
    for k in ["n", "span", "root_chord", "tip_chord", "sweep_length", "x_root_le_from_nose"]:
        _req(fins, k)
    if not isinstance(fins["n"], int) or fins["n"] < 3:
        raise ConfigError("rocket.fins.n must be an integer >= 3")
    pos("rocket.fins.span", fins["span"])
    pos("rocket.fins.root_chord", fins["root_chord"])
    pos("rocket.fins.tip_chord", fins["tip_chord"])
    nonneg("rocket.fins.sweep_length", fins["sweep_length"])
    nonneg("rocket.fins.x_root_le_from_nose", fins["x_root_le_from_nose"])

    if not isinstance(rocket.get("Cd", 0), (int, float)):
        raise ConfigError("rocket.Cd must be a number")
    pos("launch.rail_length", launch.get("rail_length", 0))
    if not isinstance(launch.get("angle_deg", None), (int, float)):
        raise ConfigError("launch.angle_deg must be a number")

    pos("propulsion.rho_water", prop.get("rho_water", 0))
    pos("propulsion.gamma_air", prop.get("gamma_air", 0))
    pos("propulsion.R_air", prop.get("R_air", 0))
    nozzle = _req(prop, "nozzle")
    pos("propulsion.nozzle.diameter", nozzle.get("diameter", 0))
    pos("propulsion.nozzle.Cd", nozzle.get("Cd", 0))

    if not isinstance(prop.get("p0_gauge", 0), (int, float)):
        raise ConfigError("propulsion.p0_gauge must be a number")
    wf = prop.get("water_fill_fraction", None)
    if not isinstance(wf, (int, float)) or not (0.0 < wf < 0.95):
        raise ConfigError("propulsion.water_fill_fraction must be in (0, 0.95)")

    pos("simulation.dt_prop", sim.get("dt_prop", 0))
    pos("simulation.tmax_prop", sim.get("tmax_prop", 0))
    pos("simulation.tmax_traj", sim.get("tmax_traj", 0))

    cases = cfg["cases"]
    if not isinstance(cases, list) or len(cases) < 1:
        raise ConfigError("cases must be a non-empty list")
    for i, c in enumerate(cases):
        if not isinstance(c, dict):
            raise ConfigError(f"cases[{i}] must be a mapping")
        _req(c, "name")
        if "p0_gauge" in c and not isinstance(c["p0_gauge"], (int, float)):
            raise ConfigError(f"cases[{i}].p0_gauge must be a number")
        if "water_fill_fraction" in c:
            wf2 = c["water_fill_fraction"]
            if not isinstance(wf2, (int, float)) or not (0.0 < wf2 < 0.95):
                raise ConfigError(f"cases[{i}].water_fill_fraction must be in (0, 0.95)")
