#!/usr/bin/env python3
"""One-command Python pipeline (Steps 1–3)."""
from pathlib import Path
import subprocess, sys

def run(script: Path) -> None:
    subprocess.check_call([sys.executable, str(script)])

def main() -> int:
    repo = Path(__file__).resolve().parents[1]
    run(repo/"0_requirements/generate_requirements_artifacts.py")
    run(repo/"1_sizing/mass_budget.py")
    run(repo/"1_sizing/propulsion_sizing.py")
    run(repo/"1_sizing/battery_endurance.py")
    run(repo/"2_aero/wing_polar_model.py")
    run(repo/"2_aero/stability_derivatives.py")
    print("[run_all.py] Python steps complete. Now run MATLAB: 6_simulation/run_all.m")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
