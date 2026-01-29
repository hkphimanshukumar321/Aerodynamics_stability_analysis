#!/usr/bin/env python3
"""Step-2a: Mass budget + AUW estimate (simulation-first)."""
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

def ensure_dir(p: Path): p.mkdir(parents=True, exist_ok=True)

def main():
    repo = Path(__file__).resolve().parents[1]
    cfg = load_yaml_minimal(repo/"0_requirements/requirements.yaml")
    out_dir = repo/cfg.get("outputs",{}).get("artifacts_dir","report/artifacts")
    ensure_dir(out_dir)

    payload = float(cfg["mission"]["payload_mass_kg"])
    avionics = float(cfg["mission"]["avionics_mass_kg"])
    battery = float(cfg["battery"]["mass_kg"])

    # Conservative lumped estimates (editable)
    airframe = 0.35
    motor_esc_prop = 0.22
    misc = 0.08

    masses = [
        ("Payload", payload),
        ("Avionics", avionics),
        ("Battery", battery),
        ("Airframe (est.)", airframe),
        ("Motor+ESC+Prop (est.)", motor_esc_prop),
        ("Misc", misc),
    ]
    auw = sum(m for _,m in masses)

    with (out_dir/"mass_breakdown.csv").open("w", newline="", encoding="utf-8") as f:
        wri = csv.writer(f)
        wri.writerow(["Component","Mass_kg"])
        wri.writerows(masses)
        wri.writerow(["AUW_total", auw])

    try:
        import matplotlib.pyplot as plt
        plt.figure()
        plt.bar([k for k,_ in masses], [m for _,m in masses])
        plt.ylabel("Mass (kg)")
        plt.title(f"Mass Breakdown (AUW={auw:.2f} kg)")
        plt.xticks(rotation=20, ha="right")
        plt.tight_layout()
        plt.savefig(out_dir/"mass_breakdown.png", dpi=200)
        plt.close()
    except Exception:
        pass

    print(f"[mass_budget] AUW={auw:.3f} kg")

if __name__ == "__main__":
    main()
