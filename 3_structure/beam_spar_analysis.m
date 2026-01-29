function beam_spar_analysis(repo_root)
% Wing spar analysis (Euler–Bernoulli beam). Writes CSV/PNG into report/artifacts.
if nargin < 1, repo_root = pwd; end
cfg = read_config_yaml(fullfile(repo_root,'0_requirements','requirements.yaml'));
out_dir = fullfile(repo_root, cfg.outputs.artifacts_dir);
if ~exist(out_dir,'dir'), mkdir(out_dir); end
auw = read_auw_csv(fullfile(out_dir,'mass_breakdown.csv'));
g=9.80665; W=auw*g;

b = cfg.geometry.wing_span_m; L=b/2;
n = cfg.structure.load_factor_n;
Lift_half = n*W/2; w = Lift_half/L;

D_o = cfg.structure.wing_spar.outer_diameter_m;
D_i = cfg.structure.wing_spar.inner_diameter_m;
E = cfg.structure.wing_spar.youngs_modulus_Pa;
Sy = cfg.structure.wing_spar.yield_strength_Pa;
sf_req = cfg.structure.safety_factor_required;

I = (pi/64)*(D_o^4 - D_i^4);
y = D_o/2;

Mmax = w*L^2/8;
sigma_max = Mmax*y/I;
delta_max = 5*w*L^4/(384*E*I);
FoS = Sy/sigma_max;

fid=fopen(fullfile(out_dir,'spar_analysis.csv'),'w');
fprintf(fid,'Quantity,Value\n');
fprintf(fid,'AUW_kg,%.6f\n',auw);
fprintf(fid,'Load_factor_n,%.3f\n',n);
fprintf(fid,'Half_span_m,%.6f\n',L);
fprintf(fid,'Uniform_load_w_N_per_m,%.6f\n',w);
fprintf(fid,'I_m4,%.6e\n',I);
fprintf(fid,'Mmax_Nm,%.6f\n',Mmax);
fprintf(fid,'Sigma_max_Pa,%.6e\n',sigma_max);
fprintf(fid,'Deflection_max_m,%.6e\n',delta_max);
fprintf(fid,'Yield_strength_Pa,%.6e\n',Sy);
fprintf(fid,'Factor_of_Safety,%.3f\n',FoS);
fprintf(fid,'FoS_requirement,%.3f\n',sf_req);
fclose(fid);

try
    x = linspace(0,L,200);
    ydef = (w.*x.*(L^3 - 2*L.*x.^2 + x^3))./(24*E*I);
    fig=figure('Visible','off'); plot(x,ydef,'LineWidth',2); grid on;
    xlabel('x along half-span (m)'); ylabel('Deflection (m)');
    title('Half-wing deflection under uniform load');
    saveas(fig, fullfile(out_dir,'spar_deflection.png')); close(fig);
catch
end
fprintf('[structure] spar FoS = %.2f (req %.2f)\n', FoS, sf_req);
end

function auw = read_auw_csv(path)
txt = fileread(path); lines = splitlines(strtrim(txt)); auw=NaN;
for i=numel(lines):-1:1
    if startsWith(lines{i},'AUW_total')
        parts = split(lines{i},','); auw=str2double(parts{2}); return;
    end
end
error('AUW_total not found');
end

function cfg = read_config_yaml(path)
txt=fileread(path); lines=splitlines(txt);
cfg=struct(); stack_keys={}; stack_structs={cfg}; stack_indent=0;
for i=1:numel(lines)
    raw=lines{i};
    cidx=strfind(raw,'#'); if ~isempty(cidx), raw=raw(1:cidx(1)-1); end
    if isempty(strtrim(raw)), continue; end
    indent=length(raw)-length(strtrim(raw));
    line=strtrim(raw); if ~contains(line,':'), continue; end
    parts=split(line,':'); key=strtrim(parts{1});
    val=strtrim(strjoin(parts(2:end),':'));
    while indent < stack_indent && ~isempty(stack_keys)
        stack_keys(end)=[]; stack_structs(end)=[]; stack_indent=stack_indent-2;
    end
    current=stack_structs{end};
    if isempty(val)
        current.(key)=struct(); stack_structs{end}=current;
        stack_keys{end+1}=key; stack_structs{end+1}=current.(key);
        stack_indent=indent+2;
    else
        v=parse_scalar(val); current.(key)=v; stack_structs{end}=current;
    end
    for s=numel(stack_keys):-1:1
        parent=stack_structs{s}; child_key=stack_keys{s};
        parent.(child_key)=stack_structs{s+1}; stack_structs{s}=parent;
    end
    cfg=stack_structs{1};
end
end

function v=parse_scalar(val)
val=strrep(val,'"',''); val=strrep(val,'''','');
num=str2double(val);
if ~isnan(num), v=num; return; end
if strcmpi(val,'true'), v=true; return; end
if strcmpi(val,'false'), v=false; return; end
v=val;
end
