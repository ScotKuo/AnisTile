function [anis]=ACAnisSingle(AC, listflag)
%ACANISSINGLE Do 50% thresholds of AutoCorr anisotropy (ImageJ and variations)
% Function [anis]=ACAnisSingle(AC) Extract ellipses from 2D contours of 2D
%	autocorrelation (AC) plot at 50% of max-min {like ImageJ rescaled}, or
%	50% of max (assumes 0 has true meaning, e.g. after subtracting average)
% Returns structure with regionprops (rprops) and weighted calculations
%	(wprops).
%
% 14_0228 SCK: includes wACAnis code; based on ACAnisScan()

if nargin<2, listflag=1; end
anis.err.code=0; anis.err.msg='';
anis.max =max(AC(:)); anis.min =min(AC(:)); dm=size(AC); dm2=round(dm/2);
%disp(['>size: ' int2str(size(AC)) '; amax=' num2str(anis.max,3)]);
AC2=AC; AC2(AC2==anis.max)=NaN; anis.max2=max(AC2(:)); %remove center
AC2(AC2==anis.max2)=NaN; anis.max3=max(AC2(:)); %remove next largest
anis.xy =[-dm2(1) dm(1)-dm2(1)-1 -dm2(2) dm(2)-dm2(2)-1];
% for axes: [px,py]=meshgrid(anis.xy(3):anis.xy(4),anis.xy(1):anis.xy(2));

%lev: 1=ImageJ (50% of range=max-min); 2=AbsMax50%; 3=AbsMax50% after
%	excluding center
lev(1)=0.5 * double(anis.max-anis.min) + double(anis.min);
lev(2)=0.5 * double(anis.max);
lev(3)=0.5 * double(anis.max2);
labels={'Range50(ImJ)','Max50','NonCentMax50'};

rprop.major =[];rprop.minor =[];rprop.orient =[];rprop.anis=[];
wprop=rprop; rprop.area=[]; wprop.majstd=[];wprop.minstd=[];

if all(lev(1:2)>anis.max2), %singularity in autocorrelation
	anis.rprop=rprop;
	anis.wprop=wprop;
	anis.err.code=1;
	anis.err.msg=['Singularity for autocorrelation (max2=' num2str(anis.max2) '); no ellipse possible '];
	return;
end

j=0;
for i=1:length(lev)
	wac=[]; if lev(i)>anis.min, %only calculate if real threshold
		wac =wACAnis(AC, lev(i), 1, 5, 1); %suppress warnings
	end
	if ~isempty(wac) && wac.n>0,
		j=j+1;
		anis.label{j}=labels{i}; anis.lev(j)=lev(i);
		rprop.major(j) =wac.regprops.MajorAxisLength/2;
		rprop.minor(j) =wac.regprops.MinorAxisLength/2;
		rprop.anis(j)=NaN;
		if rprop.minor(j)>0.08, rprop.anis(j) =rprop.major(j)/rprop.minor(j); end
		rprop.orient(j) =wac.regprops.Orientation;
		rprop.area(j) =wac.regprops.Area;

		wprop.major(j) =wac.rot.MajorAxisLength/2;
		wprop.minor(j) =wac.rot.MinorAxisLength/2;
		wprop.majstd(j) =wac.rot.majstd;
		wprop.minstd(j) =wac.rot.minstd;
		wprop.anis(j)=NaN;
		if wprop.minor(j)>0.08, wprop.anis(j) =wprop.major(j)/wprop.minor(j); end
		wprop.orient(j) =wac.rot.Orientation;
	end
end
anis.rprop=rprop;
anis.wprop=wprop;
% if j==0, keyboard; end

if listflag, alist(anis,0);
	for i=1:numel(labels), alist(anis,i); end
end
end

function alist(anis, ind)
tstr=sprintf('\t');
if ind>0 && isfield(anis,'label') && numel(anis.label)>=ind,
	out=[anis.label{ind} ':'];
	out=[out tstr num2str(anis.rprop.major(ind)) ' pix' tstr num2str(anis.rprop.minor(ind)) ' pix'];
	out=[out tstr num2str(anis.rprop.anis(ind)) tstr num2str(anis.rprop.orient(ind)) ' deg' ];
	out=[out tstr num2str(anis.wprop.anis(ind)) tstr num2str(anis.wprop.orient(ind)) ' deg'];
	disp(out);
elseif ind==0,
	disp(['Label' tstr 'MajAx_El' tstr 'MinAx_El' tstr 'Anis_El' tstr 'Orient_El' ...
		tstr 'Anis_Wt' tstr 'Orient_Wt']);
end
end
