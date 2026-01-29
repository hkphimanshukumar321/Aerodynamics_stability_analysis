#!/usr/bin/env python3
"""Step-3a: Aero model: polar + L/D vs speed (parabolic CD)."""
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

    rho=float(cfg["aerodynamics"]["air_density_kgm3"])
    cd0=float(cfg["aerodynamics"]["cd0"])
    e=float(cfg["aerodynamics"]["oswald_efficiency_e"])
    cl0=float(cfg["aerodynamics"]["cl0"])
    cla=float(cfg["aerodynamics"]["cl_alpha_per_rad"])
    S=float(cfg["geometry"]["wing_area_m2"])
    span=float(cfg["geometry"]["wing_span_m"])
    AR=span*span/S
    k=1.0/(math.pi*e*AR)

    auw=read_auw(out_dir)
    if not math.isfinite(auw):
        raise SystemExit("Run mass_budget.py first.")
    W=auw*G

    alphas=[math.radians(a) for a in range(-6,16)]
    CLs=[cl0 + cla*a for a in alphas]
    CDs=[cd0 + k*cl*cl for cl in CLs]

    Vs=[8+i*0.5 for i in range(0,41)]
    LD=[]
    for V in Vs:
        CL = W/(0.5*rho*V*V*S)
        CD = cd0 + k*CL*CL
        LD.append(CL/CD)

    with (out_dir/"aero_summary.csv").open("w", newline="", encoding="utf-8") as f:
        wri=csv.writer(f)
        wri.writerow(["Parameter","Value"])
        wri.writerow(["AR", AR])
        wri.writerow(["k", k])
        wri.writerow(["cd0", cd0])
        wri.writerow(["e", e])
        wri.writerow(["cl_alpha_per_rad", cla])

    try:
        import matplotlib.pyplot as plt
        plt.figure()
        plt.plot(CLs, CDs, marker="o")
        plt.xlabel("CL"); plt.ylabel("CD")
        plt.title("Polar: CD = CD0 + k CL^2")
        plt.tight_layout()
        plt.savefig(out_dir/"polar_curve.png", dpi=200)
        plt.close()

        plt.figure()
        plt.plot(Vs, LD)
        plt.xlabel("Speed (m/s)"); plt.ylabel("L/D")
        plt.title("L/D vs Speed (level flight)")
        plt.tight_layout()
        plt.savefig(out_dir/"ld_vs_speed.png", dpi=200)
        plt.close()
    except Exception:
        pass

    print("[aero] wrote aero_summary.csv")

if __name__=="__main__":
    main()
