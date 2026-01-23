# Quick Start Guide

## Running the Full Analysis

To process all data files and generate publishable outputs, simply run:

```matlab
run_full_analysis()
```

This will:
1. Process all `.dat` files in the `data` folder
2. Perform aerodynamic calculations (MAC, AC, CG)
3. Generate publishable graphs and visualizations
4. Create summary reports
5. Export data summaries

## Output Structure

After running the analysis, you'll find:

```
output/
├── figures/
│   ├── airfoil_shapes.png          # Airfoil coordinate plots
│   ├── coefficient_curves.png      # Lift coefficient vs angle of attack
│   ├── statistics.png               # Data processing statistics
│   ├── stability_analysis.png      # Stability analysis plots
│   └── comprehensive_analysis.png  # Combined analysis plot
├── reports/
│   └── analysis_report.txt         # Text summary report
└── data_summary/
    └── data_summary.csv            # CSV summary of all processed files
```

## Individual Functions

### Process Data Folder
```matlab
[all_data, file_list] = process_data_folder('data');
```

### Read Single Data File
```matlab
data = read_aero_data('data/s1221.dat');
```

### Aerodynamic Calculations
```matlab
aero_calculations()  % Use default parameters
aero_calculations('https://example.com/data.json')  % Use online data
```

### Stability Analysis
```matlab
stability_analysis()  % Use default parameters
stability_analysis('data/s1221.dat')  % Use specific file
```

### Generate Visualizations
```matlab
[all_data, ~] = process_data_folder('data');
create_visualizations(all_data, 'output/figures');
```

## File Formats

The system supports:
- **.dat files**: Airfoil coordinates or coefficient data
- **JSON files**: Structured aerodynamic parameters
- **CSV files**: Parameter-value pairs
- **Online URLs**: Fetch data from web sources

## Example Workflow

```matlab
% 1. Process all data files
[all_data, file_list] = process_data_folder('data');

% 2. Perform calculations
results = perform_calculations(all_data);

% 3. Generate visualizations
create_visualizations(all_data, 'output/figures');

% 4. Run stability analysis
stability_analysis(all_data{1});  % Analyze first file
```

## Notes

- All figures are saved in both PNG (for publication) and FIG (for editing) formats
- The analysis automatically handles both coordinate and coefficient data
- Error handling is built-in for malformed files
- Processing 1400+ files may take a few minutes
