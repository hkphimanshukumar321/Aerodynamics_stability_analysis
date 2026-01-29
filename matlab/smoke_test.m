function smoke_test()
% Quick smoke test for package resolution + end-to-end run.
% Run this after `cd matlab`.

clc;
startup; % adds matlab/ to path

req = {
    'config.load_params'
    'sizing.compute_sizing'
    'aero.build_aero'
    'propulsion.build_propulsion'
    'performance.trim_level_flight'
    'dynamics.build_linear_models'
    'dynamics.run_virtual_tests'
    'plots.make_all_plots'
    'io.write_struct'
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
