function motor_mount_stress(repo_root)
% Motor mount thrust stress check. Writes motor_mount_stress.csv
if nargin < 1, repo_root = pwd; end
cfg = read_config_yaml(fullfile(repo_root,'0_requirements','requirements.yaml'));
out_dir = fullfile(repo_root, cfg.outputs.artifacts_dir);
if ~exist(out_dir,'dir'), mkdir(out_dir); end
Treq = read_required_thrust(fullfile(out_dir,'propulsion_sizing.csv'));

b=0.040; t=0.004; L=0.030; Sy=45e6;
I=(b*t^3)/12; y=t/2; M=Treq*L; sigma=M*y/I; FoS=Sy/sigma;

fid=fopen(fullfile(out_dir,'motor_mount_stress.csv'),'w');
fprintf(fid,'Quantity,Value\n');
fprintf(fid,'Required_thrust_N,%.6f\n',Treq);
fprintf(fid,'Moment_Nm,%.6f\n',M);
fprintf(fid,'Stress_Pa,%.6e\n',sigma);
fprintf(fid,'Yield_Pa,%.6e\n',Sy);
fprintf(fid,'Factor_of_Safety,%.3f\n',FoS);
fclose(fid);
fprintf('[structure] motor mount FoS = %.2f\n',FoS);
end

function Treq = read_required_thrust(path)
txt=fileread(path); lines=splitlines(txt); Treq=NaN;
for i=1:numel(lines)
    if startsWith(strtrim(lines{i}),'Required_thrust_N')
        parts=split(lines{i},','); Treq=str2double(parts{2}); return;
    end
end
error('Required_thrust_N not found');
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
