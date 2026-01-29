#!/usr/bin/env python3
"""Step-1: Requirements artifacts (CSV + mission profile plot)."""
from pathlib import Path
import csv

def load_yaml_minimal(path: Path) -> dict:
    data: dict = {}
    stack: list[tuple[int, dict]] = [(0, data)]
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.split('#', 1)[0].rstrip()
        if not line.strip():
            continue
        indent = len(raw) - len(raw.lstrip(' '))
        if ':' not in line:
            continue
        key, val = [x.strip() for x in line.split(':', 1)]
        while stack and indent < stack[-1][0]:
            stack.pop()
        parent = stack[-1][1]
        if val == "":
            parent[key] = {}
            stack.append((indent + 2, parent[key]))
        else:
            v = val
            if isinstance(v, str) and v.lower() in ("true", "false"):
                v = v.lower() == "true"
            else:
                try:
                    if any(c in v.lower() for c in (".", "e")):
                        v = float(v)
                    else:
                        v = int(v)
                except Exception:
                    v = v.strip('"').strip("'")
            parent[key] = v
    return data

def ensure_dir(p: Path) -> None:
    p.mkdir(parents=True, exist_ok=True)

def write_requirements_csv(cfg: dict, out_csv: Path) -> None:
    m, b, p = cfg["mission"], cfg["battery"], cfg["propulsion"]
    rows = [
        ("Payload mass (kg)", m["payload_mass_kg"]),
        ("Avionics mass (kg)", m["avionics_mass_kg"]),
        ("Target range (km)", m["target_range_km"]),
        ("Target endurance (min)", m["target_endurance_min"]),
        ("Cruise speed (m/s)", m["cruise_speed_mps"]),
        ("Required thrust-to-weight", p["thrust_to_weight_required"]),
        ("Battery (S)", b["cells_S"]),
        ("Battery nominal voltage (V)", b["nominal_voltage_V"]),
        ("Battery capacity (mAh)", b["capacity_mAh"]),
        ("Battery usable fraction", b["usable_fraction"]),
    ]
    with out_csv.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f); w.writerow(["Requirement","Value"]); w.writerows(rows)

def plot_mission_profile(cfg: dict, out_png: Path) -> None:
    try:
        import matplotlib.pyplot as plt
    except Exception:
        return
    t_total = float(cfg["mission"]["target_endurance_min"])
    t_hover = min(3.0, 0.15 * t_total)
    t_land  = min(3.0, 0.15 * t_total)
    t_cruise = max(0.0, t_total - (t_hover + t_land))
    phases = ["VTOL/Transition", "Cruise out", "Cruise back", "VTOL/Land"]
    times  = [t_hover, 0.5*t_cruise, 0.5*t_cruise, t_land]
    plt.figure()
    plt.bar(phases, times)
    plt.ylabel("Time (min)")
    plt.title("Mission Time Budget")
    plt.xticks(rotation=15, ha="right")
    plt.tight_layout()
    plt.savefig(out_png, dpi=200); plt.close()

def main():
    repo = Path(__file__).resolve().parents[1]
    cfg = load_yaml_minimal(repo/"0_requirements/requirements.yaml")
    out_dir = repo/cfg.get("outputs",{}).get("artifacts_dir","report/artifacts")
    ensure_dir(out_dir)
    write_requirements_csv(cfg, out_dir/"requirements_table.csv")
    plot_mission_profile(cfg, out_dir/"mission_profile.png")
    print(f"[step1] wrote artifacts in: {out_dir}")

if __name__ == "__main__":
    main()
