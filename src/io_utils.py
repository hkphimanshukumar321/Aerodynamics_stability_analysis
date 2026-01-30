\
from __future__ import annotations
from typing import Any, Dict
import yaml
from .common import Environment, Geometry, Wing, Tail, Aero, Propulsion, Battery

def load_config(path: str) -> Dict[str, Any]:
    with open(path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

def parse_models(cfg: Dict[str, Any]):
    env = Environment(**cfg["environment"])
    wing = Wing(**cfg["geometry"]["wing"])
    tail = Tail(**cfg["geometry"]["tail"])
    geom = Geometry(
        fuselage_length_m=cfg["geometry"]["fuselage_length_m"],
        wing=wing,
        tail=tail,
    )
    aero = Aero(**cfg["aero"])
    propulsion = Propulsion(**cfg["propulsion"])
    battery = Battery(**cfg["battery"])
    masses_kg = cfg["masses_kg"]
    positions_m = cfg["component_positions_m"]
    meta = cfg.get("meta", {})
    return meta, env, geom, aero, propulsion, battery, masses_kg, positions_m
