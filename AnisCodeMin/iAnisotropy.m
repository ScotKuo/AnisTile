function [anis, ac, im] = iAnisotropy(fname, bb)
%IANISOTROPY Use ACAnisScan() and imAutoCorr() to compare bw threshold on anis estimates
% After calculating 2D autocorrelation, scan it and show ellipse
% interpretations (both weighted and RegionProps).
%
% SCK 13_1118: adapted code from Janna Serbo

if nargin<2, %BoundingBox (RegionProps format)
	bb =[46 294 971 504];
end
if nargin<1 || isempty(fname),
    [fname, pname] = uigetfile('*.tif;*.jpg;*.tiff;*.jpeg;*.lsm;', 'Image to Process');
	if isequal(fname,0) || isequal(pname,0) return; end %user cancelled
%     pname='C:\Users\Scot C. Kuo\Desktop\Collab\Romer\Janna Data\';
%     fname='D1 S1 10X rec 1 snap bottom.lsm';
    %fname='D1 S1 10X rec 1 snap bottom.tif';
end
[ps,fn,ex]=fileparts(fname);
if strcmpi(ex,'.lsm'),
	im0=tiffread32([pname fname]); %lsm ONLY
	im=im0.data{3}; %red channel only
else
	im=imread([pname fname]);
	if ndims(im)>2, %RGB image
		im=im(:, :, 1); %red values only; rgb2gray attenuates signal
	end
end
% To shuffle image (check uncorrelated stochastic predictions):
% im2=reshape(im(randperm(numel(im))), size(im));  im=im2;

if numel(bb)>=4, %crop by BoundingBox
	im=im(bb(2):(bb(2)+bb(4)),bb(1):(bb(1)+bb(3))); end

ac=imAutoCorr(im,3);
anis=ACAnisScan(ac,20);

showstuff(im, ac, anis);
ellipse=[];
end

function showstuff(im, ac, anis)
	bigfigure(1);
	clf;
	
	subplot(1,3,1); imagesc(im); axis equal; axis tight;
	full=1;
	subplot(1,3,2); colormap('default');
	[px,py]=meshgrid(anis.xy(3):anis.xy(4),anis.xy(1):anis.xy(2));
	px0=0; py0=0;
	if full,
		ind=(anis.levf>=0.1);
		%contour(flipud(ac), anis.nLev); axis square;
		contour(px,py, ac, anis.nLev); axis ij; axis equal; axis tight;
		r=anis.rprop.major(ind); th=anis.rprop.orient(ind)*pi/180;
		%px0=anis.rprop.xcen(ind); py0=anis.rprop.ycen(ind);
		x=r.*cos(th)+px0; y=r.*sin(th)+py0;
		hold on; plot(x,y,'k-','LineWidth',2);
		r=anis.rprop.minor(ind); th=anis.rprop.orient(ind)*pi/180 + pi/2;
		x=r.*cos(th)+px0; y=r.*sin(th)+py0;
		hold on; plot(x,y,'k:','LineWidth',2);
		%must flipud since imagesc and contour use different coordinate systems
	else %zoom to 50%
		ind=(anis.levf>=0.5);
		%contour(flipud(ac), anis.lev(ind)); axis square;
		contour(px, py, ac, anis.lev(ind)); axis ij; axis equal; axis tight;
		caxis([anis.min anis.max]);
		%px0=anis.rprop.xcen(ind); py0=anis.rprop.ycen(ind);
		r=anis.rprop.major(ind); th=anis.rprop.orient(ind)*pi/180;
		x=r.*cos(th)+px0; y=r.*sin(th)+py0;
		hold on; plot(x,y,'k-','LineWidth',2);
		r=anis.rprop.minor(ind); th=anis.rprop.orient(ind)*pi/180 + pi/2;
		x=r.*cos(th)+px0; y=r.*sin(th)+py0;
		hold on; plot(x,y,'k:','LineWidth',2);
	end
	
	pleft=0.68; pwidth=0.3; linspec='-';
	if full
		xrange=[min(anis.levf) max(anis.levf)]; %reversed direction
	else
		%xrange=[0.65 0.83]; %reversed direction
		xrange=[0.6 0.85]; %reversed direction
	end
	hflag=0; %don't hold prior
	PlotByThresh(anis.rprop, anis.levf, xrange, 'Flat Ellipse (RegionProps)', linspec, hflag, pleft, pwidth)

	%pleft=0.04; pwidth=0.3;
	linspec='--'; hflag=1; %hold prior
	%PlotByThresh(anis.wprop, anis.levf, xrange, 'Mountain (Weighted)', linspec, hflag, pleft, pwidth)
	PlotByThresh(anis.wprop, anis.levf, xrange, ...
		'Solid:Flat Ellipse; Dashed:Mountain (Weighted)', linspec, hflag, pleft, pwidth)
end

function PlotByThresh(anis, levf, xrange, gtitle, linspec, hflag, pleft, pwidth)
	i50=find((levf==0.5),1); %prior analysis values
	ind=find(levf>=xrange(1) & levf<=xrange(2));
	if xrange(1)>0.5, i50=[]; end

	subplot('position',[pleft 0.6 pwidth 0.2]); %LBWH
	if hflag, hold on; end
	plot(levf(ind), anis.major(ind), ['b' linspec], levf(i50), anis.major(i50), 'bo', ...
		levf(ind), anis.minor(ind), ['r' linspec], levf(i50), anis.minor(i50), 'ro');
	ylabel('Maj,Min (pix)'); set(gca,'XTickLabel',[]);
	set(gca,'xdir','reverse');xlim(xrange); axis tight;
	title(gtitle);
	hold off;
	
	subplot('position',[pleft 0.4 pwidth 0.2]);
	if hflag, hold on; end
	plot(levf(ind), anis.orient(ind), ['b' linspec], levf(i50), anis.orient(i50), 'bo');
	ylabel('angle'); set(gca,'XTickLabel',[]);
	set(gca,'xdir','reverse');xlim(xrange); axis tight;
	hold off;

	subplot('position',[pleft 0.2 pwidth 0.2]);
	if hflag, hold on; end
	aind=anis.anis;
	plot(levf(ind), aind(ind), ['b' linspec], levf(i50), aind(i50), 'bo');
	ylabel('Ind=Maj/Min');
	set(gca,'xdir','reverse');xlim(xrange); axis tight;
	xlabel('Thresh (%max)');
	hold off;
end

function PlotByDistance(anis, ind, xrange, pleft, pwidth)
% 	subplot('position',[pleft 0.6 pwidth 0.2]); %LBWH
% 	plot(anis.major, anis.yVal, 'b-', anis.major(i50), anis.yVal(i50), 'bo', ...
% 		anis.minor, anis.yVal, 'r-', anis.minor(i50), anis.yVal(i50), 'ro');
% 	ylabel('ACval'); axis tight; set(gca,'XTickLabel',[]); xlim([0 xmax]);
% 	
% 	subplot('position',[pleft 0.4 pwidth 0.2]);
% 	plot(anis.major, anis.orient, 'b-', anis.major(i50), anis.orient(i50), 'bo');
% 	ylabel('angle'); axis tight; set(gca,'XTickLabel',[]); xlim([0 xmax]);
% 	
% 	subplot('position',[pleft 0.2 pwidth 0.2]);
% 	aind=anis.minor ./ anis.major;
% 	plot(anis.major, aind, 'b-', anis.major(i50), aind(i50), 'bo');
% 	ylabel('AnisInd'); axis tight; xlim([0 xmax]);
% 	xlabel('distance (pix)');

end

