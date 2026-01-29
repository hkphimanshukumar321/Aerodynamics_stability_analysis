# Project Execution Plan & Answers

Here are the answers to your specific questions regarding the "Aircraft Design Project 2" and how to execute it without physical experiments.

## 1. How to Plan

Since you cannot perform the physical glide test, your plan shifts from "Construction & Testing" to "Modeling & Simulation".

**Step-by-Step Plan:**
1.  **Theoretical Analysis (Phase 1):**
    *   Calculate the Aerodynamic Center (AC) of the Wing and Tail. (Already done in script: Wing at 0, Tail at 1.76m).
    *   Calculate the Neutral Point (NP). For identical surfaces, it is the midpoint: $x_{NP} = 0.88$ m.
2.  **Simulation Setup (Phase 2):**
    *   Use the provided Python script (`glide_simulation.py`) to model the aircraft dynamics.
    *   The script uses the exact mass (1.8kg) and geometry from the PDF.
3.  **Virtual Experiments (Phase 3 & 4):**
    *   **Stable Case:** Run simulation with Center of Gravity (CG) *ahead* of the NP (e.g., at 0.73m).
    *   **Unstable Case:** Run simulation with CG *behind* the NP (e.g., at 1.03m).
    *   **Neutral Case:** Run simulation with CG *at* the NP (0.88m).
4.  **Analysis:**
    *   Observe the "Pitch Angle vs Time" plot.
    *   Stable = Oscillations decay or stay bounded.
    *   Unstable = Angle diverges (aircraft flips).

## 2. Which Software to Demonstrate Flight

**Recommended Software: Python (Custom Script)**
I have provided a script `glide_simulation.py` that uses:
*   **NumPy & SciPy**: For solving the equations of motion (Physics).
*   **Matplotlib**: For visualizing the flight path and stability.

**How to Demonstrate:**
1.  Run the script: `python glide_simulation.py`
2.  It will generate an image `flight_simulation_results.png`.
3.  This image shows the side-view trajectory (Height vs Distance) and the pitch stability (Angle vs Time).
4.  You can include this image in your report and show it during any presentation.

## 3. How to Mention Experimental Results

In your report, you will have a section "3. Simulation Results" instead of "Experimental Results".

**Phrasing:**
> "Due to logistical constraints, the physical glide experiments were substituted with a high-fidelity numerical simulation based on linearized longitudinal equations of motion. The inputs to the simulation matched the physical parameters of the specified wing-tail configuration (Mass=1.8kg, Span=2.4m)."

**Presenting the Data:**
*   Show the **Stable Plot**: Point out how the pitch angle returns to 0 (or oscillates stably) after a disturbance (launch).
*   Show the **Unstable Plot**: Point out how the pitch angle grows exponentially, indicating loss of control.
*   **Comparison**: Clearly state "The simulation confirms that shifting the CG aft of the Neutral Point (0.88m) results in instability, matching the theoretical prediction."

## 4. How to Give Deliverables

The PDF requires a "Project Report". Since you are doing a simulation, your deliverables should be:

1.  **The Report (PDF/Word)**: Use the `Report_Template.md` I provided.
2.  **The Code**: Submit `glide_simulation.py` as an appendix or a separate file labeled "Simulation Source Code".
3.  **The Plots**: High-resolution images of the flight paths.

## Implementation Steps (Summary)
1.  **Run the script**: Ensure you have `numpy`, `scipy`, `matplotlib` installed.
2.  **Check the output**: Look at `flight_simulation_results.png`.
3.  **Write the Report**: Fill in the `Report_Template.md` with the specific values from the simulation output.
