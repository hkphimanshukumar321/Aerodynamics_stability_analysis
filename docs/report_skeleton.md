# Project Report Skeleton (fill-in)

## 1. Problem Description
Goal: compute trimmed elevator deflection, flight velocity, thrust required, and power required for a cropped delta wing UAV in steady level flight across α = 0°…12°.

## 2. Geometry and Aerodynamic Modeling
### Geometry preprocessing
- Taper ratio: λ = Ct/Cr
- Area: S = (b/2) Cr (1+λ)
- Aspect ratio: AR = b^2/S
- Induced drag factor: k = 1/(π e AR)

### Aerodynamics and trim
- Pitching moment: Cm = Cm0 + Cmα α + Cmδe δe
- Trim: Cm = 0 ⇒ δe,trim = -(Cm0 + Cmα α)/Cmδe
- Lift: CL = CL0 + CLα α + CLδe δe,trim
- Drag polar: CD = CD0 + k CL^2

## 3. Steady Level Flight Equilibrium
- Lift: W = 0.5 ρ V^2 S CL  ⇒ V = sqrt(2W/(ρ S CL))
- Drag: D = 0.5 ρ V^2 S CD
- Thrust required: Tr = D
- Power required: Pr = Tr·V

## 4. MATLAB Algorithm
Describe the loop over α and stored outputs (refer to `src/main_project4.m`).

## 5. Results and Discussion
Include the 8 plots (from `outputs/figures`) and comment trends:
- How V changes with α
- How δe,trim varies with α
- Where thrust/power minima occur
- Efficiency peaks (CL/CD and CL^(3/2)/CD)

## 6. Key Performance Trends (bullet points)
- …
