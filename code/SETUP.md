# Setup and Validation Guide

## Quick Start

After cloning the repository, run these commands in MATLAB:

```matlab
% 1. Validate the setup
validate_setup()

% 2. Check dependencies
check_dependencies()

% 3. Run the full analysis
run_full_analysis()
```

## Automatic Path Detection

The code automatically detects project paths regardless of where it's cloned. The system:

- ✅ Works from any directory
- ✅ Works on Windows, Mac, and Linux
- ✅ Automatically finds `data` and `code` folders
- ✅ Creates `output` folder if needed
- ✅ Handles relative and absolute paths

## Project Structure

The expected structure is:

```
project_root/
├── code/              # All MATLAB functions
│   ├── run_full_analysis.m
│   ├── get_project_paths.m
│   ├── validate_setup.m
│   └── ...
├── data/              # .dat files (1400+ files)
│   ├── *.dat
│   └── ...
├── output/            # Generated outputs (created automatically)
│   ├── figures/
│   ├── reports/
│   └── data_summary/
└── README.md
```

## Validation Functions

### validate_setup()

Checks:
- Project folder structure
- Required functions exist
- Data files are accessible
- File permissions
- MATLAB compatibility

### check_dependencies()

Verifies all required functions are available and can be called.

## Troubleshooting

### "Data folder not found"

1. Ensure the `data` folder exists in the project root
2. Run `validate_setup()` to check the structure
3. Check that you're in the correct directory

### "Function not found"

1. Add the `code` folder to MATLAB path:
   ```matlab
   addpath('code')
   ```
2. Or change to the code directory:
   ```matlab
   cd code
   ```

### "Permission denied"

1. Check that the output folder is writable
2. On Windows, run MATLAB as administrator if needed
3. Check file permissions on the data folder

## Cross-Platform Compatibility

The code uses `fullfile()` and `filesep` for path handling, making it compatible with:
- Windows (C:\Users\...)
- Mac/Linux (/home/...)

## GitHub Integration

The code is designed to work immediately after cloning:

1. Clone the repository
2. Open MATLAB
3. Navigate to the project folder (or add to path)
4. Run `run_full_analysis()`

No manual path configuration needed!
