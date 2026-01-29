import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.animation import FuncAnimation

# --- Constants ---
x_ac_wing = 0.0
x_ac_tail = 1.76
x_np = (x_ac_wing + x_ac_tail) / 2.0  # 0.88 m

def naca4(number, chord, n_points=100):
    """
    Generate coordinates for a NACA 4-digit airfoil.
    number: string, e.g. '2412'
    chord: float, chord length
    """
    m = int(number[0]) / 100.0
    p = int(number[1]) / 10.0
    t = int(number[2:]) / 100.0
    
    x = np.linspace(0, 1, n_points)
    yt = 5 * t * (0.2969 * np.sqrt(x) - 0.1260 * x - 0.3516 * x**2 + 0.2843 * x**3 - 0.1015 * x**4)
    
    yc = np.zeros_like(x)
    dx = np.zeros_like(x)
    
    for i in range(len(x)):
        if x[i] < p:
            yc[i] = m / p**2 * (2 * p * x[i] - x[i]**2)
            dx[i] = 2 * m / p**2 * (p - x[i])
        else:
            yc[i] = m / (1 - p)**2 * ((1 - 2 * p) + 2 * p * x[i] - x[i]**2)
            dx[i] = 2 * m / (1 - p)**2 * (p - x[i])
            
    theta = np.arctan(dx)
    xu = x - yt * np.sin(theta)
    yu = yc + yt * np.cos(theta)
    xl = x + yt * np.sin(theta)
    yl = yc - yt * np.cos(theta)
    
    # Scale by chord
    xu *= chord
    yu *= chord
    xl *= chord
    yl *= chord
    
    # Combine upper and lower surface
    X = np.concatenate((xu[::-1], xl))
    Y = np.concatenate((yu[::-1], yl))
    
    return X, Y

def draw_aircraft_schematic(ax, x_cg):
    # --- Geometry ---
    # Fuselage line
    ax.plot([-0.5, 2.5], [0, 0], 'k-', linewidth=2, label='Fuselage', alpha=0.5)
    
    # Wing (NACA 2412)
    c_wing = 0.5 # Chord length
    # AC is usually at 0.25c. If AC_wing is at 0, leading edge should be at -0.25c
    x_le_wing = x_ac_wing - 0.25 * c_wing
    xw, yw = naca4('2412', c_wing)
    # Shift to position (wing on top of fuselage usually)
    yw += 0.1 # Mount wing slightly above
    wing_poly = patches.Polygon(np.column_stack((xw + x_le_wing, yw)), closed=True, facecolor='dodgerblue', edgecolor='black', alpha=0.9, label='Wing')
    ax.add_patch(wing_poly)
    
    # Tail (NACA 0012 - Symmetric)
    c_tail = 0.3 # Chord length
    x_le_tail = x_ac_tail - 0.25 * c_tail
    xt, yt = naca4('0012', c_tail)
    yt += 0.1
    tail_poly = patches.Polygon(np.column_stack((xt + x_le_tail, yt)), closed=True, facecolor='dodgerblue', edgecolor='black', alpha=0.9, label='Tail')
    ax.add_patch(tail_poly)
    
    # --- Key Points ---
    # AC Symbols
    ax.plot(x_ac_wing, 0.1, 'r+', markersize=10, markeredgewidth=2)
    ax.text(x_ac_wing, -0.15, r'$AC_{wing}$', ha='center', color='black', fontsize=9)
    
    ax.plot(x_ac_tail, 0.1, 'r+', markersize=10, markeredgewidth=2)
    ax.text(x_ac_tail, -0.15, r'$AC_{tail}$', ha='center', color='black', fontsize=9)
    
    # Neutral Point (Fixed)
    ax.axvline(x_np, color='purple', linestyle='--', alpha=0.5, ymin=0, ymax=1)
    ax.plot(x_np, 0, 'P', color='purple', markersize=12, label='Neutral Point')
    ax.text(x_np, -0.35, f'NP\n({x_np:.2f}m)', ha='center', color='purple', fontweight='bold')

    # Center of Gravity (Variable)
    ax.plot(x_cg, 0, 'o', markersize=12, markerfacecolor='black', markeredgecolor='white', label='CG')
    ax.text(x_cg, -0.5, f'CG\n({x_cg:.2f}m)', ha='center', color='black', fontweight='bold')

    # --- Forces (Conceptual) ---
    # Lift Vectors (Up) acting at AC
    ax.arrow(x_ac_wing, 0.15, 0, 0.6, head_width=0.08, head_length=0.1, fc='blue', ec='blue', width=0.02)
    ax.text(x_ac_wing - 0.2, 0.5, r'$L_{wing}$', color='blue', fontsize=12)
    
    # Tail Lift (simplified, usually varies)
    ax.arrow(x_ac_tail, 0.15, 0, 0.4, head_width=0.08, head_length=0.1, fc='blue', ec='blue', width=0.02)
    ax.text(x_ac_tail - 0.2, 0.4, r'$L_{tail}$', color='blue', fontsize=12)
    
    # Weight Vector (Down at CG)
    ax.arrow(x_cg, 0, 0, -0.6, head_width=0.08, head_length=0.1, fc='black', ec='black', width=0.02)
    ax.text(x_cg + 0.1, -0.4, r'$W$', color='black', fontsize=12)

    # --- Stability Annotation ---
    static_margin = x_np - x_cg
    
    if static_margin > 0.02:
        status = "STABLE"
        color = 'green'
        moment_text = "Restoring Moment\n(Nose returns)"
    elif static_margin < -0.02:
        status = "UNSTABLE"
        color = 'red'
        moment_text = "Diverging Moment\n(Aircraft flips)"
    else:
        status = "NEUTRAL"
        color = 'orange'
        moment_text = "Balanced"

    # Status Box
    props = dict(boxstyle='round', facecolor=color, alpha=0.2)
    ax.text(0.05, 0.95, f"Status: {status}\nMargin: {static_margin:.2f}m\n{moment_text}", 
            transform=ax.transAxes, fontsize=12, verticalalignment='top', bbox=props)

    # Dimensional Limits
    ax.set_xlim(-0.5, 2.5)
    ax.set_ylim(-1, 1.5)
    ax.set_aspect('equal')
    ax.set_xlabel("Distance along Fuselage (m)")
    ax.set_title(f"Longitudinal Static Stability\n(NACA 2412 Wing / NACA 0012 Tail)")
    ax.grid(True, linestyle=':', alpha=0.6)
    # ax.legend(loc='lower right') # Legend creates clutter with dynamic changes

def create_static_diagram():
    fig, ax = plt.subplots(figsize=(12, 7))
    draw_aircraft_schematic(ax, x_cg=0.6) # Stable Case
    plt.tight_layout()
    plt.savefig("stability_diagram.png", dpi=120)
    print("Generated stability_diagram.png")

def create_animation():
    fig, ax = plt.subplots(figsize=(12, 7))
    
    # CG moves from 0.4m (Stable) to 1.4m (Unstable)
    cg_positions = np.linspace(0.4, 1.4, 80)
    
    def update(frame):
        ax.clear()
        x_cg = cg_positions[frame]
        draw_aircraft_schematic(ax, x_cg)
        
    ani = FuncAnimation(fig, update, frames=len(cg_positions), interval=60)
    ani.save('stability_animation.gif', writer='pillow', fps=20)
    print("Generated stability_animation.gif")

if __name__ == "__main__":
    create_static_diagram()
    create_animation()
