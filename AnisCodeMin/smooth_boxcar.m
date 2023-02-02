function [sm] = smooth_boxcar(x, winlen)
%SMOOTH_BOXCAR Apply boxcar filter, but pad with end values (not zeros)
%   Standard boxcar filter, but change padding.
% SCK 14_0125
if nargin<2, winlen=3; end
winlen=floor(winlen/2)*2+1; %force odd
wl2=floor(winlen/2);
h=ones(1,winlen)/winlen;
x2=[x(1)*ones(1,wl2) x x(end)*ones(1,wl2)];
sm=conv(x2,h,'valid');
end

