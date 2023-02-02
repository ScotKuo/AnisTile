function h=DrawEllipse(eprops, linspec, npts)
% Draw an ellipse in the current axes
%   >eprops has same fields as regionprops
%	>linspec is line specification (see plot)

if nargin<3, npts=50; end
if nargin<2, linspec='w-'; end
if ~isfield(eprops,'Centroid'), eprops.Centroid=[512.5 512.5]; end

phi = linspace(0,2*pi,npts-1); phi=[phi 0]; %force closure
ellipxy = [(eprops.MajorAxisLength/2)*cos(phi);
		(eprops.MinorAxisLength/2)*sin(phi)];
Orient = pi*eprops.Orientation/180; %radians, CCW
R = [cos(Orient) -sin(Orient); sin(Orient) cos(Orient)]; %CCW rotation
a=size(ellipxy); a(1)=1;
Cen=[eprops.Centroid(1)*ones(a); eprops.Centroid(2)*ones(a)];
ellipxy = R * ellipxy + Cen; %rotate & translate

hold on
h=plot(ellipxy(1,:),ellipxy(2,:),linspec);
hold off

if nargout<1, clear h; end
end