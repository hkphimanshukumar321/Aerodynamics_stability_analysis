#!/usr/bin/env python3
"""Step-2b: Propulsion sizing: prove thrust >= 2W + estimate hover power."""
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

G = 9.80665

def ensure_dir(p: Path): p.mkdir(parents=True, exist_ok=True)

def read_auw(out_dir: Path) -> float:
    p = out_dir/"mass_breakdown.csv"
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

    auw = read_auw(out_dir)
    if not math.isfinite(auw):
        raise SystemExit("Run mass_budget.py first.")

    tw = float(cfg["propulsion"]["thrust_to_weight_required"])
    W = auw*G
    T_req = tw*W

    rho = float(cfg["aerodynamics"]["air_density_kgm3"])
    D = 0.254  # 10 inch baseline
    A = math.pi*(D/2)**2

    eta = float(cfg["propulsion"]["motor_efficiency"])*float(cfg["propulsion"]["prop_efficiency_hover"])*float(cfg["propulsion"]["esc_efficiency"])
    eta = max(1e-3, eta)

    def P_hover(T):
        ideal = (T**1.5)/math.sqrt(2*rho*A)
        return ideal/eta

    candidates = [12, 16, 20, 24, 28, 32, 36, 40]
    rows=[]
    for T in candidates:
        rows.append((T, int(T>=T_req), P_hover(T)))

    with (out_dir/"propulsion_sizing.csv").open("w", newline="", encoding="utf-8") as f:
        wri = csv.writer(f)
        wri.writerow(["Candidate_thrust_N","Meets_T>=2W","Estimated_hover_power_W"])
        wri.writerows(rows)
        wri.writerow([])
        wri.writerow(["AUW_kg", auw])
        wri.writerow(["Weight_N", W])
        wri.writerow(["Required_thrust_N", T_req])

    try:
        import matplotlib.pyplot as plt
        plt.figure()
        plt.plot([r[0] for r in rows], [r[2] for r in rows], marker="o")
        plt.axvline(T_req, linestyle="--")
        plt.xlabel("Static thrust (N)")
        plt.ylabel("Estimated hover power (W)")
        plt.title("Hover power vs thrust (baseline 10-inch model)")
        plt.tight_layout()
        plt.savefig(out_dir/"hover_power_vs_thrust.png", dpi=200)
        plt.close()
    except Exception:
        pass

    print(f"[propulsion] Required T(2W)={T_req:.1f} N")

if __name__ == "__main__":
    main()
