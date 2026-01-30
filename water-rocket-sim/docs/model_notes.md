# Model Notes (for report write-up)

## Coordinate convention
- `x` : horizontal downrange (m)
- `z` : vertical altitude (m)
- Body axis initially aligned with the launch rail at `launch.angle_deg`.

## Propulsion model
### Phase 1: water expulsion
Assumptions:
- Water jet is incompressible.
- Trapped air expands adiabatically:  \(P V_{air}^\gamma = \text{const}\).
- Nozzle discharge coefficient \(C_d\) captures losses.

Equations:
- \(v_e = \sqrt{2(P-P_a)/\rho_w}\)
- \(\dot m_w = C_d \rho_w A_n v_e\)
- \(T \approx \dot m_w v_e\)

Water ends when \(V_w \to 0\) or \(P \le P_a\).

### Phase 2: air blowdown
Assumptions:
- Tank (bottle) is **isothermal** at ambient temperature \(T_a\).
- Flow through nozzle uses standard isentropic choked/un-choked relations.

This phase is weaker than the water phase but improves fidelity vs. stopping thrust abruptly.

## Aerodynamics
- Quadratic drag: \(D=\tfrac12 \rho C_D A v^2\).
- Constant \(C_D\) is used by default; sweep studies are recommended.

## Trajectory
- Rail-constrained 1D integration until `rail_length`.
- Free-flight 2D integration afterward.
- Thrust is aligned with the velocity vector after leaving the rail (no attitude dynamics).

## Stability proof
- CP is estimated using a Barrowman-style fin contribution plus a small body contribution.
- CG is computed for two states:
  1) **Full**: dry + water + initial air
  2) **Empty**: dry + air at ambient

Static margin (calibers): \(SM=(x_{CP}-x_{CG})/D\).

