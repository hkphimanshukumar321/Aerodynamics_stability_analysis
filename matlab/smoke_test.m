function smoke_test()
% Quick smoke test for package resolution + end-to-end run.
% Run this after `cd matlab`.

clc;
startup; % adds matlab/ to path

req = {
    'load_params'
    'check_params'
    'compute_sizing'
    'build_aero'
    'build_propulsion'
    'trim_level_flight'
    'build_linear_models'
    'run_virtual_tests'
    'make_all_plots'
    'write_struct'
};

missing = {};
for i=1:numel(req)
    w = which(req{i});
    if isempty(w)
        missing{end+1} = req{i}; %#ok<AGROW>
    end
end

if ~isempty(missing)
    fprintf('\nSMOKE TEST FAILED: Missing functions:\n');
    fprintf(' - %s\n', missing{:});
    error('Package/path issue: missing functions.');
end

fprintf('\nPackage resolution OK. Running main_run_all...\n');
main_run_all();
fprintf('\nSMOKE TEST PASSED.\n');
end
