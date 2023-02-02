function mag=DrawEllipses(x, y, major, minor, ang, autoscale, mag, linspec)
%Analogous to Quiver, but draw ellipses (maj,min,ang) at x,y centers
%
%SK 15_0414
if nargin<8, linspec='b-'; end %for plot: line specification
if nargin<7, mag=1; end 
if nargin<6, autoscale=1; end

[m,n]=size(x);
% if min(size(x))==1, n=sqrt(numel(x)); m=n; else [m,n]=size(x); end
if autoscale, %perform autoscaling and multiply by mag
    delx = diff([min(x(:)) max(x(:))])/n;
    dely = diff([min(y(:)) max(y(:))])/m;
    del = sqrt(delx.^2 + dely.^2);
	maxlen=max(abs(major(:))); if del>0, maxlen=maxlen/del; end
	if maxlen>0, mag=mag*0.95/maxlen; end
end
major=major*mag; minor=minor*mag;

hold on;
for i=1:m, for j=1:n,
	ep.Centroid=[x(i,j) y(i,j)]; ep.MajorAxisLength=major(i,j);
	ep.MinorAxisLength=minor(i,j); ep.Orientation=ang(i,j);
	DrawEllipse(ep,linspec,20);
end; end; hold off;

end
