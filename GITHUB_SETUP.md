# GitHub Setup and Portability

This project is designed to work immediately after cloning from GitHub, with automatic path detection and no manual configuration required.

## ✅ Features for GitHub Deployment

### Automatic Path Detection
- **No hardcoded paths** - All paths are resolved automatically
- **Works from any directory** - Run from project root, code folder, or anywhere
- **Cross-platform** - Works on Windows, Mac, and Linux
- **Portable** - Clone to any location and it works

### Error Handling & Validation
- **Setup validation** - `validate_setup()` checks project structure
- **Dependency checking** - `check_dependencies()` verifies all functions
- **Integrity testing** - `test_integrity()` comprehensive function tests
- **Graceful error handling** - All functions handle errors gracefully

### File Integrity
- **Cross-file validation** - Functions check for required dependencies
- **Path resolution** - Consistent path handling across all functions
- **Error reporting** - Clear error messages with suggestions

## 🚀 Quick Start After Cloning

```matlab
% 1. Navigate to project (or add to path)
cd Final_Aircraft_Flight_Stability_Project_v2

% 2. Run startup (optional but recommended)
cd code
startup

% 3. Run full analysis
run_full_analysis()
```

That's it! No configuration needed.

## 📁 Project Structure

```
project_root/
├── code/                    # All MATLAB functions
│   ├── get_project_paths.m  # Automatic path detection
│   ├── validate_setup.m     # Setup validation
│   ├── check_dependencies.m # Dependency checker
│   ├── test_integrity.m     # Integrity tests
│   ├── startup.m           # Initialization script
│   ├── run_full_analysis.m # Main analysis script
│   └── ...                  # Other functions
├── data/                    # Data files (1400+ .dat files)
├── output/                  # Generated outputs (auto-created)
├── .gitignore              # Git ignore rules
└── README.md               # Main documentation
```

## 🔍 Validation Commands

After cloning, verify everything works:

```matlab
% Check setup
validate_setup()

% Check dependencies
check_dependencies()

% Run integrity tests
test_integrity()

% If all pass, run analysis
run_full_analysis()
```

## 🛠️ How It Works

### Path Detection
The `get_project_paths()` function:
1. Finds the `code` folder (where functions are located)
2. Determines project root (parent of `code` folder)
3. Locates `data` folder (in project root)
4. Creates `output` folder if needed
5. Returns absolute paths for all locations

### Function Integration
All functions use `get_project_paths()` to:
- Find data files automatically
- Create output folders in the right place
- Work regardless of current working directory
- Handle relative and absolute paths

## ✅ Pre-Push Checklist

Before pushing to GitHub, ensure:

- [ ] All functions use `get_project_paths()` for paths
- [ ] No hardcoded paths in code
- [ ] `.gitignore` excludes output files
- [ ] `validate_setup()` passes
- [ ] `test_integrity()` passes
- [ ] README.md is updated
- [ ] All functions are documented

## 🐛 Troubleshooting

### "Data folder not found"
- Ensure `data` folder exists in project root
- Run `validate_setup()` to check structure

### "Function not found"
- Add code folder to path: `addpath('code')`
- Or navigate to code folder: `cd code`

### "Permission denied"
- Check file permissions
- Ensure output folder is writable

## 📝 Notes

- The `output` folder is in `.gitignore` (generated files)
- Sample data files are kept for examples
- All paths are resolved to absolute paths internally
- Functions work independently or together

## 🔗 Related Files

- `code/SETUP.md` - Detailed setup instructions
- `code/QUICK_START.md` - Quick start guide
- `README.md` - Main project documentation
