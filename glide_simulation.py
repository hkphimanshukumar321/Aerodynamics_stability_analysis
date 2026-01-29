import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp

# --- Physics Constants & Aircraft Parameters ---
# Based on Project PDF values approx.
g = 9.81              # Gravity (m/s^2)
rho = 1.225           # Air density (kg/m^3)
m = 1.8               # Mass (kg)
S = 2.4 * 0.23        # Wing Area (m^2) approx span * chord
c = 0.23              # Mean Aerodynamic Chord (m)
Iyy = 0.2             # Moment of Inertia about Y-axis (kg*m^2) - Estimated
x_ac_wing = 0.0       # AC of wing reference (at 0)
x_ac_tail = 1.76      # AC of tail (1.76m behind wing AC)
dist_ac = x_ac_tail - x_ac_wing # Distance between ACs

# Neutral Point Calculation (simplified for identical wing-tail)
# For identical surfaces with no downwash, NP is roughly midpoint
x_np = dist_ac / 2.0 

print(f"--- Aircraft Parameters ---")
print(f"Wing AC at x = {x_ac_wing:.2f} m")
print(f"Tail AC at x = {x_ac_tail:.2f} m")
print(f"Neutral Point (NP) at x = {x_np:.2f} m")
print(f"---------------------------\n")

def compute_forces_moments(state, x_cg):
    """
    Compute Lift, Drag, and Pitching Moment.
    State: [u, w, q, theta, x, z]
    u: x-body velocity
    w: z-body velocity
    q: pitch rate
    theta: pitch angle
    """
    u, w, q, theta, x, z = state
    
    # Airspeed
    V = np.sqrt(u**2 + w**2)
    if V < 0.1: V = 0.1 # Avoid div by zero
    
    # Angle of Attack (alpha) approx w/u for small angles
    alpha = np.arctan2(w, u)
    
    # Dynamic Pressure
    q_bar = 0.5 * rho * V**2
    
    # Aerodynamic Coefficients (Linearized approximations)
    # CL = CL0 + CL_alpha * alpha
    # CM = CM0 + CM_alpha * alpha + CM_q * q
    
    # Wing
    CL_alpha_w = 2 * np.pi # Thin airfoil theory
    CL_w = CL_alpha_w * alpha
    
    # Tail (Assume identical wing, strictly speaking downwash reduces this, but we simplify)
    CL_alpha_t = 2 * np.pi 
    # Tail effective angle of attack (simplified, neglecting downwash and incidence diff for now)
    # alpha_t = alpha + (q * arm / V)
    # tail arm from cg
    l_t = x_ac_tail - x_cg
    l_w = x_cg - x_ac_wing
    
    # Damping due to pitch rate at tail
    alpha_t = alpha + (q * l_t / V) 
    CL_t = CL_alpha_t * alpha_t
    
    # Total Lift
    L_w = q_bar * (S/2) * CL_w # Assuming S is total area, split 50/50 wing/tail for "identical"
    L_t = q_bar * (S/2) * CL_t 
    L = L_w + L_t
    
    # Total Drag (polar)
    CD0 = 0.02
    k = 0.05
    CD = CD0 + k * (CL_w**2 + CL_t**2) # Simplified
    D = q_bar * S * CD
    
    # Pitching Moment about CG
    # M = L_w * l_w - L_t * l_t (Sign convention: Nose up positive)
    # If CG is behind Wing AC, l_w is positive. Lift at wing creates Nose Up moment? 
    # Standard: AC is usually ahead of CG for stability.
    # Moment arm: distance from CG to AC.
    # if x_ac < x_cg: Lift creates Nose Up (+)
    # if x_ac > x_cg: Lift creates Nose Down (-)
    
    # Let's use strict x positions
    # Moment from Wing Lift
    M_w = L_w * (x_cg - x_ac_wing) 
    # Moment from Tail Lift
    M_t = -L_t * (x_ac_tail - x_cg) # Tail is behind, Lift up -> Nose down (-)
    
    M = M_w + M_t
    
    return L, D, M

def equations_of_motion(t, state, x_cg):
    u, w, q, theta, x, z = state
    
    L, D, M = compute_forces_moments(state, x_cg)
    
    # Equations of Motion (Body Frame)
    # m(du/dt + q*w) = -mg sin(theta) + X_aero
    # m(dw/dt - q*u) = mg cos(theta) + Z_aero
    # Iyy dq/dt = M_aero
    
    # Aero transformation to body frame
    # D acts anti-parallel to Velocity vector V
    # L acts perpendicular to V
    alpha = np.arctan2(w, u)
    
    # Forces in body frame X_b, Z_b
    # Fx = L sin(alpha) - D cos(alpha)
    # Fz = -L cos(alpha) - D sin(alpha)
    
    Fx = L * np.sin(alpha) - D * np.cos(alpha)
    Fz = -L * np.cos(alpha) - D * np.sin(alpha)
    
    du_dt = (Fx / m) - g * np.sin(theta) - q * w
    dw_dt = (Fz / m) + g * np.cos(theta) + q * u
    dq_dt = M / Iyy
    dtheta_dt = q
    
    # Earth frame position
    # dx/dt = u cos(theta) + w sin(theta)
    # dz/dt = -u sin(theta) + w cos(theta) (z is altitude positive up? No, usually z down)
    # Let's map z as altitude positive UP to match plotting ease
    dx_dt = u * np.cos(theta) + w * np.sin(theta)
    dz_dt = u * np.sin(theta) - w * np.cos(theta) # if theta=0, u aligns x, w aligns -z
    
    return [du_dt, dw_dt, dq_dt, dtheta_dt, dx_dt, dz_dt]

def run_simulation(case_name, x_cg_offset):
    # Initial Conditions (Glide)
    V0 = 10.0 # m/s launch speed
    alpha0 = 0.0 # rad
    theta0 = 0.0 # rad level launch
    
    u0 = V0 * np.cos(alpha0)
    w0 = V0 * np.sin(alpha0)
    q0 = 0.0
    x0 = 0.0
    z0 = 2.0 # Start 2m high (hand launch)
    
    state0 = [u0, w0, q0, theta0, x0, z0]
    
    # Simulation Time
    t_span = (0, 5) # 5 seconds
    t_eval = np.linspace(0, 5, 200)
    
    # Set CG
    current_x_cg = x_np + x_cg_offset
    print(f"Simulating Case: {case_name}")
    print(f"CG Position: {current_x_cg:.2f} m (Offset from NP: {x_cg_offset:.2f} m)")
    
    sol = solve_ivp(equations_of_motion, t_span, state0, args=(current_x_cg,), t_eval=t_eval, method='RK45')
    
    return sol, current_x_cg

def plot_results(sols):
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))
    
    for case, sol, cg in sols:
        ax1.plot(sol.y[4], sol.y[5], label=f'{case} (CG={cg:.2f}m)')
        ax2.plot(sol.t, np.degrees(sol.y[3]), label=f'{case}')
        
    ax1.set_title("Flight Path (Side View)")
    ax1.set_xlabel("Distance (m)")
    ax1.set_ylabel("Altitude (m)")
    ax1.grid(True)
    ax1.legend()
    # Draw ground
    ax1.axhline(0, color='black', linewidth=2)
    
    ax2.set_title("Pitch Angle vs Time")
    ax2.set_xlabel("Time (s)")
    ax2.set_ylabel("Pitch Angle (deg)")
    ax2.grid(True)
    ax2.legend()
    
    plt.tight_layout()
    plt.savefig("flight_simulation_results.png")
    print("Results saved to flight_simulation_results.png")

if __name__ == "__main__":
    # Case 1: Stable (CG Ahead of NP)
    # NP is at 0.88m (1.76 / 2)
    # Move CG forward by 0.1m
    sol_stable, cg_stable = run_simulation("Stable (CG < NP)", -0.15)
    
    # Case 2: Unstable (CG Behind NP)
    # Move CG aft by 0.1m
    sol_unstable, cg_unstable = run_simulation("Unstable (CG > NP)", 0.15)
    
    # Case 3: Neutral (CG = NP)
    sol_neutral, cg_neutral = run_simulation("Neutral (CG = NP)", 0.0)
    
    plot_results([
        ("Stable", sol_stable, cg_stable), 
        ("Neutral", sol_neutral, cg_neutral),
        ("Unstable", sol_unstable, cg_unstable)
    ])
