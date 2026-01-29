function [Jx, Jy, Jz] = estimate_inertia(p)
if ~isempty(p.mass.inertia.Jx) && ~isempty(p.mass.inertia.Jy) && ~isempty(p.mass.inertia.Jz)
    Jx=p.mass.inertia.Jx; Jy=p.mass.inertia.Jy; Jz=p.mass.inertia.Jz; return;
end

m = p.mass.mtow;
L=0.72; w=0.08; h=0.10; % crude fuselage dims
Jx_f=(1/12)*m*(h^2+w^2);
Jy_f=(1/12)*m*(L^2+h^2);
Jz_f=(1/12)*m*(L^2+w^2);

b = p.geom.b;
m_w=0.25*m;
Jx_w=(1/12)*m_w*b^2;
Jz_w=(1/12)*m_w*b^2;

Jx=Jx_f+Jx_w; Jy=Jy_f; Jz=Jz_f+Jz_w;
end
