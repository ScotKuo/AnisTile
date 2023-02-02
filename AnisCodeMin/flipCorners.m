% [x,y]=flipCorners(x,y,dist) for correlation plots of angles, will flip
%	directions of angles (180deg) so that linear correlations are
%	calculable.  Proximity to corners (UL and LR) determined by 'dist'
%	(deg along x or y axis; perpendicular distance is 'dist*sqrt(2)').
% Returns new x,y pairs.  Assumes both x & y on range of [-90 90]
%
% SK 15_0430
%	Line sidedness determined from sign of determinant of vectors AB (AB is
%	along  the line) and AP (P is point in questions).  Negative and
%	positive values are opposite sides of the line, and 0 is exactly on the
%	line.  Order of points will change sidedness...

function [x,y]=flipCorners(x,y,dist) %..Assumes [-90 90] range of data
	if nargin<3, dist=45; end
	a=[-90 (90-dist)]; b=[(dist-90) 90]; %UL corner
	side=sign((b(1)-a(1)).*(y-a(2)) - (b(2)-a(2)).*(x-a(1))); %determ of AB,AP
	idx=(side>0); %above UL line
	a=[(90-dist) -90]; b=[90 (dist-90)]; %LR corner
	side=sign((b(1)-a(1)).*(y-a(2)) - (b(2)-a(2)).*(x-a(1)));
	idy=(side<0); %below LR line
	x(idx)=x(idx)+180; %move right to UR
	y(idy)=y(idy)+180; %move up to UR
end
