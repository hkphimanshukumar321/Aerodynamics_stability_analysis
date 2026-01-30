from src.config import load_yaml
from src.propulsion import compute_propulsion_profile
from src.stability import compute_stability
from src.trajectory import simulate_trajectory


def test_smoke_default_config():
    cfg = load_yaml("configs/default.yaml")
    case = cfg["cases"][0]
    prof = compute_propulsion_profile(cfg, case)
    assert prof.t.size > 1
    assert prof.mass[0] > 0
    stab = compute_stability(cfg, case)
    assert stab.x_cp > 0
    traj = simulate_trajectory(cfg, case, prof)
    assert traj.apogee >= 0
