function tailsitter_6dof(repo_root)
% Simplified longitudinal simulation: hover -> transition -> cruise.
if nargin < 1, repo_root = pwd; end
cfg = read_config_yaml(fullfile(repo_root,'0_requirements','requirements.yaml'));
out_dir = fullfile(repo_root, cfg.outputs.artifacts_dir);
if ~exist(out_dir,'dir'), mkdir(out_dir); end
auw = read_auw_csv(fullfile(out_dir,'mass_breakdown.csv'));
m=auw; g=9.80665;

rho = cfg.aerodynamics.air_density_kgm3;
S   = cfg.geometry.wing_area_m2;
cd0 = cfg.aerodynamics.cd0;
e   = cfg.aerodynamics.oswald_efficiency_e;
b   = cfg.geometry.wing_span_m;
AR  = b*b/S;
k   = 1/(pi*e*AR);
cl0 = cfg.aerodynamics.cl0;
cla = cfg.aerodynamics.cl_alpha_per_rad;

t_hover=6; t_trans=cfg.controls.transition_time_s; t_cruise=20; dt=0.01;
T_total=t_hover+t_trans+t_cruise; N=floor(T_total/dt)+1; t=(0:N-1)*dt;

theta_cmd=zeros(1,N);
for i=1:N
    if t(i)<=t_hover
        theta_cmd(i)=deg2rad(90);
    elseif t(i)<=t_hover+t_trans
        tau=(t(i)-t_hover)/t_trans;
        theta_cmd(i)=deg2rad(90)*(1-tau);
    else
        theta_cmd(i)=0;
    end
end

wn=2*pi*cfg.controls.cruise_attitude_bandwidth_hz; zeta=0.8;
Kp=wn^2; Kd=2*zeta*wn;

x=0; z=0; u=0; wv=0; theta=deg2rad(90); q=0;
X=zeros(1,N); Z=zeros(1,N); V=zeros(1,N); TH=zeros(1,N); TT=zeros(1,N);

for i=1:N
    Va=max(0.1, sqrt(u^2 + wv^2));
    alpha=atan2(wv,u);
    CL=cl0+cla*alpha; CD=cd0+k*CL^2;
    Lf=0.5*rho*Va^2*S*CL; Df=0.5*rho*Va^2*S*CD;

    if t(i)<=t_hover
        Tcmd=m*g*1.05;
    elseif t(i)<=t_hover+t_trans
        tau=(t(i)-t_hover)/t_trans;
        T_hover=m*g*1.05;
        T_cruise=Df+0.05*m*g;
        Tcmd=(1-tau)*T_hover + tau*T_cruise;
    else
        Tcmd=Df+0.05*m*g;
    end

    eth=wrapToPi(theta_cmd(i)-theta);
    qdot=Kp*eth - Kd*q;

    Fx_b = Tcmd - Df;
    Fz_b = -Lf;

    c=cos(theta); s=sin(theta);
    Fx = c*Fx_b - s*Fz_b;
    Fz = s*Fx_b + c*Fz_b + m*g;

    udot=Fx/m; wdot=Fz/m;
    u=u+udot*dt; wv=wv+wdot*dt;
    x=x+u*dt; z=z+wv*dt;

    q=q+qdot*dt; theta=theta+q*dt;

    X(i)=x; Z(i)=z; V(i)=sqrt(u^2+wv^2); TH(i)=theta; TT(i)=Tcmd;
end

try
    fig=figure('Visible','off');
    subplot(3,1,1); plot(t, rad2deg(TH)); hold on; plot(t, rad2deg(theta_cmd),'--'); grid on;
    ylabel('Pitch (deg)'); legend('theta','theta_{cmd}');
    subplot(3,1,2); plot(t, V); grid on; ylabel('Speed (m/s)');
    subplot(3,1,3); plot(t, TT); grid on; ylabel('Thrust (N)'); xlabel('Time (s)');
    saveas(fig, fullfile(out_dir,'sim_time_series.png')); close(fig);
catch
end

fid=fopen(fullfile(out_dir,'sim_summary.csv'),'w');
fprintf(fid,'Quantity,Value\n');
fprintf(fid,'AUW_kg,%.6f\n',auw);
fprintf(fid,'Final_x_m,%.6f\n',X(end));
fprintf(fid,'Final_z_m,%.6f\n',Z(end));
fprintf(fid,'Final_speed_mps,%.6f\n',V(end));
fprintf(fid,'Final_pitch_deg,%.6f\n',rad2deg(TH(end)));
fclose(fid);

fprintf('[dynamics] wrote sim_time_series.png and sim_summary.csv\n');
end

function auw = read_auw_csv(path)
txt=fileread(path); lines=splitlines(strtrim(txt)); auw=NaN;
for i=numel(lines):-1:1
    if startsWith(lines{i},'AUW_total')
        parts=split(lines{i},','); auw=str2double(parts{2}); return;
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
