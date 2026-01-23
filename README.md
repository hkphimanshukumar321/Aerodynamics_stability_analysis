# Experimental Demonstration of Flight Stability of a Flat-Plate Wing Using Center of Gravity Control

## Overview
This project aims to experimentally demonstrate that a flat plate planform, without a conventional airfoil shape, can generate sustained gliding flight when its center of gravity (CG) is appropriately positioned ahead of the aerodynamic center (AC). The project investigates the static stability and CG-AC relationship through experimentation.

## Objective
The objective is to reinforce classroom concepts related to static stability, neutral point, and CG-AC relationships with hands-on experimentation, specifically using a square flat plate in a diamond-wing configuration.

## Deliverables
- **Project Report**: Including theory, geometric and mass calculations, CG and AC estimation, experimental procedure, and conclusions.
- **Experimental Evidence**: Photos and videos demonstrating the glide tests.

## Evaluation Criteria
- **Theoretical Analysis**: 30%
- **Experimental Setup**: 30%
- **Observations & Interpretation**: 20%
- **Report Quality**: 20%

## How to Access & Run the Code

### Quick Start (Recommended)

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd Final_Aircraft_Flight_Stability_Project_v2
   ```

2. **Open MATLAB and run:**
   ```matlab
   cd code
   startup
   run_full_analysis()
   ```

   The code automatically detects paths and works from any location!

### Detailed Setup

1. **Clone or download the repository**
2. **Open MATLAB** and navigate to the project folder
3. **Run setup validation:**
   ```matlab
   cd code
   validate_setup()  % Checks project structure and dependencies
   ```
4. **Run the full analysis:**
   ```matlab
   run_full_analysis()  % Processes all data and generates outputs
   ```

### Individual Functions

- `aero_calculations()` - Calculate aerodynamic coefficients, CG adjustments, and stability analysis
- `stability_analysis()` - Perform stability analysis
- `process_data_folder()` - Process all `.dat` files in the data folder
- `create_visualizations()` - Generate publishable graphs

### Output

After running, check the `output` folder for:
- **figures/**: Publication-ready graphs (PNG and FIG formats)
- **reports/**: Text summary reports
- **data_summary/**: CSV files with processed data summaries

See `code/SETUP.md` for detailed setup instructions and troubleshooting.

## Data Processing Features

The codebase now includes comprehensive data processing capabilities:

- **Data Reading**: Automatically processes 1400+ `.dat` files from the data folder
- **Aerodynamic Calculations**: Computes Mean Aerodynamic Chord (MAC), Aerodynamic Center (AC), Center of Gravity (CG), and Static Margin
- **Visualizations**: Generates publishable graphs including:
  - Airfoil shape comparisons
  - Lift coefficient curves
  - Stability analysis plots
  - Statistical summaries
- **Reports**: Creates detailed text and CSV reports of all analyses
- **Online Data Support**: Can fetch and process data from online sources (JSON, CSV, or text files)

See `code/QUICK_START.md` for detailed usage instructions.

## Safety Instructions
Perform glide tests only in open areas, ensuring no personnel are in the glide path and under instructor supervision.

## How to Contribute
To contribute, fork this repository, create a feature branch, and submit a pull request. Make sure your code is well-documented and aligned with the project objectives.
