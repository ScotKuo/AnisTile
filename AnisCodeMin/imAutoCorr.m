function [ac, acstat, X, Y]=imAutoCorr(im, stdScale)
% Calculate an image's autocorrelation function (various normalizations)
% Function [ac, acstat, X, Y]=imAutoCorr(im, stdScale)
%	returns:
%	ac=size-NORMALIZED 2D autocorrelation
%	acstat=statistics: max,min,scalemode,scaledmax,scaledmin
%	X,Y coordinates of autocorrelation
% >stdScale=1 forces result to conform with MatLab [0,1] scaling of double
%	images.  stdScale=2 forces uint16, if appropriate.
%  stdScale=3 means subtract mean and normalize max=1 [can interpret
%		statistical significance]
%	Default: stdScale=0 means don't rescale {might mess up im2bw() later}
% Most popular stdScale=0,3; 1&2 were bad attempts at conforming to MatLab;
% it's best just to avoid all the im... functions and their rescaling
% conventions.
%
% 13_1203 SCK; reannotated 14_0125
% 15_0702 SCK, added code for X,Y coordinates (xgv, ygv); SK confirmed OK

if nargin<2, stdScale=0; end
%Note: Can avoid rescaling headaches of im2double (result always [0,1]) by
%	using double alone.  To make explicit:
% im_max=intmax(class(im)); %must use homemade ImageFormatMax() to include
%		% non-integer images (e.g. double) 
% fg=fft2(im2double(im)*im_max); %undo im2double rescaling of max range

if stdScale==3, im=im-mean(im(:)); end
fg=fft2(double(im)); %avoid rescaling by im2double
ac=abs(fftshift(ifft2(fg .* conj(fg)))); %IDENTICAL with ImageJ 32-bit

ac=ac ./ numel(fg); %normalize autocorr for image size; now max(ac)=<i^2>

%for im2bw, must follow MatLab conventions on re-scaling:
ac_max=max(ac(:));
acstat.max=ac_max; acstat.min=min(ac(:)); acstat.scalemode=stdScale;
if stdScale==1 || stdScale==3, ac=ac ./ ac_max; 
elseif stdScale==2 && ac_max<2^16, ac=uint16(ac); end
acstat.scaledmax=max(ac(:)); acstat.scaledmin=min(ac(:));
acstat.ACcen = fliplr(floor((size(ac)/2))) + [1 1]; %center of area; SK confirmed
acstat.size=size(ac);
sz=-fliplr(floor(acstat.size/2)); sz2=fliplr(acstat.size)+sz-[1 1];
acstat.xgv=sz(1):sz2(1); acstat.ygv=sz(2):sz2(2);
if nargout>2,
	[X,Y]=meshgrid(acstat.xgv,acstat.ygv);
end
end