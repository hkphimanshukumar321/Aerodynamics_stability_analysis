#!/usr/bin/env python3
"""Step-3b: Simple stability derivative placeholders (CSV)."""
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
    repo=Path(__file__).resolve().parents[1]
    cfg=load_yaml_minimal(repo/"0_requirements/requirements.yaml")
    out_dir=repo/cfg.get("outputs",{}).get("artifacts_dir","report/artifacts")
    ensure_dir(out_dir)
    derivs=[
        ("Cm_alpha",-0.6),
        ("Cm_q",-12.0),
        ("CL_alpha", float(cfg["aerodynamics"]["cl_alpha_per_rad"])),
        ("CD0", float(cfg["aerodynamics"]["cd0"])),
    ]
    with (out_dir/"stability_derivatives.csv").open("w", newline="", encoding="utf-8") as f:
        wri=csv.writer(f); wri.writerow(["Derivative","Value"]); wri.writerows(derivs)
    print("[stability] wrote stability_derivatives.csv")

if __name__=="__main__":
    main()
