function mag=DrawArrows(x, y, magnitude, ang, autoscale, mag, linspec, linwidth)
%Analogous to Quiver, but center arrows at x,y (quiver arrows originate
%from x,y)
%
%SK 15_0414
if nargin<8, linwidth=1; end
if nargin<7, linspec='b-'; end %for plot: line specification
if nargin<6, mag=1; end %mag>0 means autoscale; multiply by mag
if nargin<5, autoscale=1; end %mag>0 means autoscale; multiply by mag

% Arrow head parameters
alpha = 0.33; % Size of arrow head relative to the length of the vector
beta = 0.33;  % Width of the base of the arrow head relative to the length

if min(size(x))==1, n=sqrt(numel(x)); m=n; else [m,n]=size(x); end
if autoscale, %perform autoscaling and multiply by mag
    delx = diff([min(x(:)) max(x(:))])/n;
    dely = diff([min(y(:)) max(y(:))])/m;
    del = sqrt(delx.^2 + dely.^2);
	maxlen=max(abs(magnitude(:))); if del>0, maxlen=maxlen/del; end
	if maxlen>0, mag=mag*0.95/maxlen; end
end
magnitude=magnitude*mag;
v=magnitude .* sin(ang*pi/180); u=magnitude .* cos(ang*pi/180);

% Make velocity vectors
x = x(:).'; y = y(:).';
u = u(:).'; v = v(:).';
uu = [x-u/2;x+u/2;repmat(NaN,size(u))]; %center the arrow shaft
vv = [y-v/2;y+v/2;repmat(NaN,size(v))];

% QUIVER calls the 'v6' version of PLOT, and temporarily modifies global
% state by turning the MATLAB:plot:DeprecatedV6Argument and
% MATLAB:plot:IgnoringV6Argument warnings off and on again.
oldWarn(1) = warning('off','MATLAB:plot:IgnoringV6Argument');
oldWarn(2) = warning('off','MATLAB:plot:DeprecatedV6Argument');
    h1 = plot(uu(:),vv(:),linspec);
    %h1 = plot('v6',uu(:),vv(:),linspec);
	set(h1,'linewidth',linwidth);
    
if 1, 	% Make arrow heads and plot them
	hu = [x+u/2-alpha*(u+beta*(v+eps));x+u/2; ...
		x+u/2-alpha*(u-beta*(v+eps));repmat(NaN,size(u))];
	hv = [y+v/2-alpha*(v-beta*(u+eps));y+v/2; ...
		y+v/2-alpha*(v+beta*(u+eps));repmat(NaN,size(v))];
	hold on
	h2 = plot(hu(:),hv(:),linspec);
	%h2 = plot('v6',hu(:),hv(:),linspec);
	set(h2,'linewidth',linwidth);
end

if 0, % Plot marker @center
	hu = x; hv = y;
	hold on
	h3 = plot(hu(:),hv(:),'*');
	%h3 = plot('v6',hu(:),hv(:),'*');
	if 1, set(h3,'markerfacecolor',get(h1,'color')); end
else

warning(oldWarn); %#ok<WNTAG>

% hold on;
% for i=1:m, for j=1:n,
% 	ep.Centroid=[x(i,j) y(i,j)]; ep.MajorAxisLength=major(i,j);
% 	ep.MinorAxisLength=minor(i,j); ep.Orientation=ang(i,j);
% 	DrawEllipse(ep,linspec,20);
% end; end; hold off;

end
