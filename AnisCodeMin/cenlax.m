% [lax stats] = cenlax(x, y)  Calculate long-axis and stats (incl centroid) of (x,y)
%    Code ported from Scot's C code; stats.lax is in radians, but lax is degrees
% stats includes: lax, sdrot[], rmsrot[], n, sdx, sdy, vxy, slope
%
% Scot C. Kuo, March 28, 2000
function [lax, s]=cenlax(x,y)
n=length(x);
if n ~= length(y)
    error('Vectors must be same length.');
end

s.n=n;
sx=sum(x);
sx2=sum(x .* x);
sxy=sum(x .* y);
sy=sum(y);
sy2=sum(y .* y);

if n>0,
    s.cen = [sx sy] ./ n;
end

if n>1,
    t1 = sx2 - sx*sx/s.n;  %sum((x-xc)^2)
    t2 = sxy - sx*sy/s.n;  %sum((x-xc)*(y-yc))
    t3 = sy2 - sy*sy/s.n;  %sum((y-yc)^2)
    s.sdx = sqrt(t1/(s.n-1.0));
    s.sdy = sqrt(t3/(s.n-1.0));
    s.vxy = t2/(s.n-1.0);
    s.slope = t2/t1;
    %L-Ax functions
    tn = 2.0*t2;
    td = (t1 - t3);
    if td ~= 0.0 | tn ~= 0.0,
        s.lax = atan2(tn, td)/2.0; %ambiguity of 180deg
		lax_endpt = atan2(y(end)-y(1), x(end)-x(1));
		dlax=s.lax - lax_endpt;
		if dlax > pi/2, s.lax = s.lax - pi; end
		if dlax < -pi/2, s.lax = s.lax + pi; end
        clax = cos(s.lax);
        slax = -sin(s.lax);    %rotate opposite to L-Ax
        sdpar = t1*clax*clax - 2.0*t2*clax*slax + t3*slax*slax;
        sdperp = t3*clax*clax + 2.0*t2*clax*slax + t1*slax*slax;
        s.sdrot=sqrt([sdpar sdperp] ./ (s.n-1.0));
        s.rmsrot=sqrt([sdpar sdperp] ./ s.n);
		m=tan(s.lax);
		s.p(1)=m; s.p(2)=s.cen(2)-s.cen(1)*m; %for polyfit
    else
        s.lax = NaN;
    end
else
    s.lax = NaN;
end
lax = s.lax * 180/pi;
return
