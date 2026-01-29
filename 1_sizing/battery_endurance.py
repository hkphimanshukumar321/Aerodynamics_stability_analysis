#!/usr/bin/env python3
"""Step-2c: Battery energy and endurance bounds (hover-only and cruise-only)."""
from pathlib import Path
import csv, math

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

G=9.80665

def ensure_dir(p: Path): p.mkdir(parents=True, exist_ok=True)

def read_min_hover_power(prop_csv: Path) -> float:
    """
    Parse propulsion_sizing.csv and return the minimum hover power among candidates
    that satisfy thrust >= 2W.

    The CSV also contains summary lines appended at the end (AUW_kg, Weight_N, ...).
    Those are skipped safely.
    """
    best = None
    if not prop_csv.exists():
        return float("nan")

    with prop_csv.open("r", encoding="utf-8") as f:
        r = csv.DictReader(f)
        for row in r:
            cand = (row.get("Candidate_thrust_N") or "").strip()
            # stop/skip if we reached the summary section or empty lines
            try:
                float(cand)
            except Exception:
                break

            meets_raw = (row.get("Meets_T>=2W") or "").strip()
            try:
                meets = int(float(meets_raw))  # accept "1", "1.0"
            except Exception:
                continue

            if meets == 1:
                try:
                    P = float(row["Estimated_hover_power_W"])
                except Exception:
                    continue
                best = P if best is None else min(best, P)

    return float(best) if best is not None else float("nan")

def read_auw(out_dir: Path)->float:
    p=out_dir/"mass_breakdown.csv"
    if not p.exists(): return float("nan")
    for line in p.read_text(encoding="utf-8").splitlines()[::-1]:
        if line.startswith("AUW_total"):
            return float(line.split(",")[1])
    return float("nan")

def main():
    repo = Path(__file__).resolve().parents[1]
    cfg = load_yaml_minimal(repo/"0_requirements/requirements.yaml")
    out_dir = repo/cfg.get("outputs",{}).get("artifacts_dir","report/artifacts")
    ensure_dir(out_dir)

    V = float(cfg["battery"]["nominal_voltage_V"])
    C_Ah = float(cfg["battery"]["capacity_mAh"])/1000.0
    usable = float(cfg["battery"]["usable_fraction"])
    E_Wh = V*C_Ah*usable

    P_hover = read_min_hover_power(out_dir/"propulsion_sizing.csv")
    if not math.isfinite(P_hover):
        raise SystemExit("Run propulsion_sizing.py first.")

    auw = read_auw(out_dir)
    if not math.isfinite(auw):
        raise SystemExit("Run mass_budget.py first.")
    W = auw*G

    rho=float(cfg["aerodynamics"]["air_density_kgm3"])
    S=float(cfg["geometry"]["wing_area_m2"])
    Vc=float(cfg["mission"]["cruise_speed_mps"])
    cd0=float(cfg["aerodynamics"]["cd0"])
    e=float(cfg["aerodynamics"]["oswald_efficiency_e"])
    span=float(cfg["geometry"]["wing_span_m"])
    AR=span*span/S
    k=1.0/(math.pi*e*AR)

    CL = W/(0.5*rho*Vc*Vc*S)
    CD = cd0 + k*CL*CL
    D = 0.5*rho*Vc*Vc*S*CD

    eta = float(cfg["propulsion"]["motor_efficiency"])*float(cfg["propulsion"]["prop_efficiency_cruise"])*float(cfg["propulsion"]["esc_efficiency"])
    eta=max(1e-3,eta)
    P_cruise = (D*Vc)/eta

    t_hover = 60.0*E_Wh/max(1e-9,P_hover)
    t_cruise = 60.0*E_Wh/max(1e-9,P_cruise)

    with (out_dir/"endurance_estimates.csv").open("w", newline="", encoding="utf-8") as f:
        wri=csv.writer(f)
        wri.writerow(["Quantity","Value"])
        wri.writerow(["Battery_energy_Wh", E_Wh])
        wri.writerow(["Hover_power_W (min feasible)", P_hover])
        wri.writerow(["Cruise_power_W", P_cruise])
        wri.writerow(["Endurance_hover_only_min", t_hover])
        wri.writerow(["Endurance_cruise_only_min", t_cruise])
        wri.writerow(["Cruise_CL", CL])
        wri.writerow(["Cruise_CD", CD])
        wri.writerow(["Cruise_Drag_N", D])

    try:
        import matplotlib.pyplot as plt
        plt.figure()
        plt.bar(["Hover-only","Cruise-only"], [t_hover, t_cruise])
        plt.ylabel("Minutes")
        plt.title("Endurance Bounds")
        plt.tight_layout()
        plt.savefig(out_dir/"endurance_bounds.png", dpi=200)
        plt.close()
    except Exception:
        pass

    print(f"[battery] E={E_Wh:.1f}Wh hover={t_hover:.1f}min cruise={t_cruise:.1f}min")

if __name__ == "__main__":
    main()
