
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp

"""
Updated glide_simulation.py
Adds the report-grade refinements:
1) TRIM at t=0 by solving M(alpha)=0 (q=0) for each CG case.
2) STATIC stability check via dM/dalpha around trim:
      dM/dalpha < 0  -> statically stable
      dM/dalpha = 0  -> neutral
      dM/dalpha > 0  -> statically unstable
3) Static margin reported in NON-dimensional form: SM = (x_NP - x_CG)/c
4) Prints a compact summary table and optionally saves it to CSV.
"""

# =============================================================================
# 0) Constants and geometry (keep consistent with your earlier work)
# =============================================================================
g   = 9.81
rho = 1.225

# Aircraft parameters (same baseline as your current file)
m   = 1.8
S   = 2.4 * 0.23        # total "lifting" planform area used in your simplified model
c   = 0.23
Iyy = 0.2

x_ac_wing = 0.0
x_ac_tail = 1.76
dist_ac   = x_ac_tail - x_ac_wing

# Simplified NP rule (identical lifting surfaces + negligible downwash)
x_np = 0.5 * (x_ac_wing + x_ac_tail)  # 0.88 m

# -----------------------------------------------------------------------------
# Aerodynamic model (same structure as your original, but factored for trim/check)
# -----------------------------------------------------------------------------
CL_alpha_w = 2.0 * np.pi
CL_alpha_t = 2.0 * np.pi
CD0 = 0.02
k   = 0.05

# Split total area equally between wing and tail for the "identical surfaces" assumption
S_w = S / 2.0
S_t = S / 2.0

def _qbar(V: float) -> float:
    return 0.5 * rho * V * V

def compute_forces_moments_from_alpha(V: float, alpha: float, q: float, x_cg: float):
    """
    Compute L, D, M using alpha and q explicitly (used for trim and stability check).
    Sign convention matches your original code:
      M_w = +L_w*(x_cg - x_ac_wing)
      M_t = -L_t*(x_ac_tail - x_cg)
    """
    V = max(float(V), 0.1)
    qbar = _qbar(V)

    # Wing lift
    CL_w = CL_alpha_w * alpha
    L_w  = qbar * S_w * CL_w

    # Tail lift (pitch-rate effect included as in your original: alpha_t = alpha + q*l_t/V)
    l_t = x_ac_tail - x_cg
    alpha_t = alpha + (q * l_t / V)
    CL_t = CL_alpha_t * alpha_t
    L_t  = qbar * S_t * CL_t

    # Total lift
    L = L_w + L_t

    # Simple drag polar (same idea as original)
    CD = CD0 + k * (CL_w**2 + CL_t**2)
    D  = qbar * S * CD

    # Pitching moment about CG
    M_w = L_w * (x_cg - x_ac_wing)
    M_t = -L_t * (x_ac_tail - x_cg)
    M   = M_w + M_t

    return L, D, M, L_w, L_t

def compute_forces_moments(state, x_cg):
    """
    Backward compatible: computes alpha from state and calls the alpha-based function.
    state: [u, w, q, theta, x, z]
    """
    u, w, q, theta, x, z = state
    V = np.sqrt(u*u + w*w)
    V = max(V, 0.1)
    alpha = np.arctan2(w, u)
    return compute_forces_moments_from_alpha(V, alpha, q, x_cg)[:3]

# =============================================================================
# 1) Static stability check: dM/dalpha at trim
# =============================================================================
def dM_dalpha_numeric(V: float, alpha0: float, x_cg: float, delta_deg: float = 0.5):
    """
    Central-difference approximation of dM/dalpha around alpha0.
    """
    d = np.deg2rad(delta_deg)
    _, _, M_p, *_ = compute_forces_moments_from_alpha(V, alpha0 + d, 0.0, x_cg)
    _, _, M_m, *_ = compute_forces_moments_from_alpha(V, alpha0 - d, 0.0, x_cg)
    return (M_p - M_m) / (2.0 * d)

# =============================================================================
# 2) Trim: solve M(alpha)=0 at q=0
# =============================================================================
def trim_alpha_for_zero_moment(V: float, x_cg: float, alpha_min_deg: float = -10.0, alpha_max_deg: float = 10.0):
    """
    Find alpha such that M(V, alpha, q=0, x_cg) = 0 using bisection.
    If the bracket does not contain a sign change, fall back to the best (min |M|) point.
    """
    a_lo = np.deg2rad(alpha_min_deg)
    a_hi = np.deg2rad(alpha_max_deg)

    def f(a):
        return compute_forces_moments_from_alpha(V, a, 0.0, x_cg)[2]

    f_lo = f(a_lo)
    f_hi = f(a_hi)

    # If moment is (near) zero across the bracket (typical at CG = NP in this simplified model)
    if abs(f_lo) < 1e-10 and abs(f_hi) < 1e-10:
        return 0.0

    # If sign change exists, bisection
    if np.sign(f_lo) != np.sign(f_hi):
        for _ in range(60):
            a_mid = 0.5 * (a_lo + a_hi)
            f_mid = f(a_mid)
            if abs(f_mid) < 1e-7:
                return a_mid
            if np.sign(f_mid) == np.sign(f_lo):
                a_lo, f_lo = a_mid, f_mid
            else:
                a_hi, f_hi = a_mid, f_mid
        return 0.5 * (a_lo + a_hi)

    # Otherwise, scan for minimum |M| and return that as "near-trim"
    grid = np.linspace(a_lo, a_hi, 801)
    vals = np.array([abs(f(a)) for a in grid])
    return float(grid[np.argmin(vals)])

# =============================================================================
# 3) Equations of motion (same as your original)
# =============================================================================
def equations_of_motion(t, state, x_cg):
    u, w, q, theta, x, z = state

    L, D, M = compute_forces_moments(state, x_cg)

    alpha = np.arctan2(w, u)

    # Body-frame components
    Fx = L * np.sin(alpha) - D * np.cos(alpha)
    Fz = -L * np.cos(alpha) - D * np.sin(alpha)

    du_dt = (Fx / m) - g * np.sin(theta) - q * w
    dw_dt = (Fz / m) + g * np.cos(theta) + q * u
    dq_dt = M / Iyy
    dtheta_dt = q

    # Earth frame (z = altitude)
    dx_dt = u * np.cos(theta) + w * np.sin(theta)
    dz_dt = u * np.sin(theta) - w * np.cos(theta)

    return [du_dt, dw_dt, dq_dt, dtheta_dt, dx_dt, dz_dt]

# =============================================================================
# 4) Simulation runner (trimmed initial condition + report summary)
# =============================================================================
def run_simulation(case_name, x_cg, V0=10.0, z0=2.0, t_end=5.0, n_eval=250):
    """
    Uses trimmed alpha (M≈0 at t=0) so the response is meaningful for stability.
    Sets theta0 = alpha_trim and (u0,w0) consistent with alpha_trim -> initial flight path ~ horizontal.
    """
    alpha_trim = trim_alpha_for_zero_moment(V0, x_cg)
    theta0 = alpha_trim  # makes initial flight path approximately level (gamma ~ 0)
    u0 = V0 * np.cos(alpha_trim)
    w0 = V0 * np.sin(alpha_trim)

    q0 = 0.0
    x0 = 0.0

    state0 = [u0, w0, q0, theta0, x0, z0]

    t_span = (0.0, float(t_end))
    t_eval = np.linspace(0.0, float(t_end), int(n_eval))

    sol = solve_ivp(
        equations_of_motion,
        t_span,
        state0,
        args=(x_cg,),
        t_eval=t_eval,
        method='RK45',
        rtol=1e-7,
        atol=1e-9
    )

    # Static check around trim
    slope = dM_dalpha_numeric(V0, alpha_trim, x_cg, delta_deg=0.5)

    return sol, alpha_trim, slope

def classify_static_stability(dM_dalpha, eps=1e-6):
    if dM_dalpha < -eps:
        return "STABLE"
    if dM_dalpha > eps:
        return "UNSTABLE"
    return "NEUTRAL"

def make_summary_table(cases, csv_path="stability_summary.csv"):
    """
    cases: list of dicts with keys:
      name, x_cg, alpha_trim, dM_dalpha
    """
    rows = []
    for cse in cases:
        sm_m  = x_np - cse["x_cg"]
        sm_nd = sm_m / c  # nondimensional SM (as fraction of chord)
        status = classify_static_stability(cse["dM_dalpha"])
        rows.append([
            cse["name"],
            cse["x_cg"],
            x_np,
            sm_m,
            100.0 * sm_nd,
            np.degrees(cse["alpha_trim"]),
            cse["dM_dalpha"],
            status
        ])

    header = ["Case", "CG (m)", "NP (m)", "SM (m)", "SM (%c)", "alpha_trim (deg)", "dM/dalpha (N·m/rad)", "Static Status"]
    rows_arr = np.array(rows, dtype=object)

    # Print as aligned text
    colw = [max(len(h), 14) for h in header]
    for j in range(len(header)):
        for i in range(rows_arr.shape[0]):
            colw[j] = max(colw[j], len(f"{rows_arr[i,j]}"))

    def fmt_row(vals):
        return " | ".join([f"{str(vals[j]):<{colw[j]}}" for j in range(len(vals))])

    print("\n=== Stability Summary (Trim + Static Check) ===")
    print(fmt_row(header))
    print("-" * (sum(colw) + 3 * (len(header) - 1)))
    for i in range(rows_arr.shape[0]):
        print(fmt_row(rows_arr[i, :]))
    print("=============================================\n")

    # Save CSV
    try:
        import csv
        with open(csv_path, "w", newline="") as f:
            w = csv.writer(f)
            w.writerow(header)
            w.writerows(rows)
        print(f"Saved summary table to: {csv_path}")
    except Exception as e:
        print(f"[WARN] Could not save CSV ({csv_path}): {e}")

def plot_results(sols, out_path="flight_simulation_results_updated.png"):
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(11, 8.5))

    for item in sols:
        case = item["name"]
        sol  = item["sol"]
        cg   = item["x_cg"]
        sm   = x_np - cg

        ax1.plot(sol.y[4], sol.y[5], label=f'{case} (CG={cg:.2f}m, SM={sm/c*100:.1f}%c)')
        ax2.plot(sol.t, np.degrees(sol.y[3]), label=f'{case}')

    ax1.set_title("Flight Path (Side View) — Trimmed Initial Moment (M≈0 at t=0)")
    ax1.set_xlabel("Distance (m)")
    ax1.set_ylabel("Altitude (m)")
    ax1.grid(True)
    ax1.legend()
    ax1.axhline(0, color='black', linewidth=2)

    ax2.set_title("Pitch Angle vs Time")
    ax2.set_xlabel("Time (s)")
    ax2.set_ylabel("Pitch Angle (deg)")
    ax2.grid(True)
    ax2.legend()

    plt.tight_layout()
    plt.savefig(out_path, dpi=180)
    print(f"Saved plot to: {out_path}")

# =============================================================================
# 5) Main: define CG cases and run
# =============================================================================
if __name__ == "__main__":
    print(f"--- Aircraft Parameters ---")
    print(f"Wing AC at x = {x_ac_wing:.2f} m")
    print(f"Tail AC at x = {x_ac_tail:.2f} m")
    print(f"Neutral Point (NP) at x = {x_np:.2f} m")
    print(f"Chord c = {c:.3f} m")
    print(f"---------------------------\n")

    # Define three cases around NP
    # You can edit these offsets; keep them modest relative to the geometry.
    cg_cases = [
        {"name": "Stable (CG < NP)",   "x_cg": x_np - 0.15},
        {"name": "Neutral (CG = NP)",  "x_cg": x_np + 0.00},
        {"name": "Unstable (CG > NP)", "x_cg": x_np + 0.15},
    ]

    results = []
    for cse in cg_cases:
        sol, alpha_trim, slope = run_simulation(cse["name"], cse["x_cg"])
        results.append({
            "name": cse["name"],
            "x_cg": cse["x_cg"],
            "sol": sol,
            "alpha_trim": alpha_trim,
            "dM_dalpha": slope,
        })

        # Quick per-case log
        status = classify_static_stability(slope)
        sm_m = x_np - cse["x_cg"]
        sm_pct = 100.0 * (sm_m / c)
        print(f"{cse['name']}: CG={cse['x_cg']:.3f} m, SM={sm_pct:+.2f}%c, alpha_trim={np.degrees(alpha_trim):+.3f} deg, dM/dalpha={slope:+.4e} -> {status}")

    # Summary table + CSV
    make_summary_table(results, csv_path="stability_summary.csv")

    # Plots
    plot_results(results, out_path="flight_simulation_results_updated.png")
