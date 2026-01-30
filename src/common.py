\
from __future__ import annotations
from dataclasses import dataclass
from typing import Dict, Any, Tuple
import math

def clamp(x: float, lo: float, hi: float) -> float:
    return max(lo, min(hi, x))

def safe_div(a: float, b: float, default: float = float("nan")) -> float:
    return a / b if abs(b) > 1e-12 else default

@dataclass
class Environment:
    rho: float
    g: float

@dataclass
class Wing:
    span_m: float
    area_m2: float
    mean_chord_m: float
    taper_ratio: float
    dihedral_deg: float = 0.0

@dataclass
class Tail:
    horizontal_area_m2: float
    vertical_area_m2: float
    tail_arm_h_m: float
    tail_arm_v_m: float

@dataclass
class Geometry:
    fuselage_length_m: float
    wing: Wing
    tail: Tail

@dataclass
class Aero:
    CL_max: float
    CD0: float
    oswald_e: float

@dataclass
class Propulsion:
    thrust_available_N: float
    prop_diameter_in: float | None = None
    motor_kv: float | None = None

@dataclass
class Battery:
    cells: int
    capacity_mAh: float
    nominal_cell_voltage_V: float
    usable_fraction: float
    avg_current_A: float

def aspect_ratio(wing: Wing) -> float:
    return safe_div(wing.span_m**2, wing.area_m2)

def induced_k(aero: Aero, wing: Wing) -> float:
    AR = aspect_ratio(wing)
    return safe_div(1.0, math.pi * aero.oswald_e * AR)

def dynamic_pressure(env: Environment, V: float) -> float:
    return 0.5 * env.rho * V * V

def weight_N(env: Environment, mass_kg: float) -> float:
    return mass_kg * env.g
