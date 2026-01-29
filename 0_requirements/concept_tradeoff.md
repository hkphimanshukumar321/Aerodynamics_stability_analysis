# Concept Trade-off (Tail-sitter VTOL)

**Selected:** Single-motor, non-vectored tail-sitter (digital prototype only).

## Why this choice
- Lowest mechanical complexity (no tilt mechanisms).
- Easy to justify analytically: thrust-to-weight, wing bending, energy/endurance.
- Enables MATLAB simulation (hover → transition → cruise) with report-ready plots.

## Assumptions for the report
- Aero: parabolic drag polar, finite-wing lift slope.
- Structure: Euler–Bernoulli wing beam + motor-mount thrust stress check.
- Control: scheduled pitch transition with PD-like attitude stabilization.
