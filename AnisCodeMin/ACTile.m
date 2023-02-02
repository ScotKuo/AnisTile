function [acGrid]=ACTile(im2, tsiz, overlap)
%ACTILE Do Tiled analysis (size/overlap): apply imAutocorr/ACAnisSinge/wACAnis
if nargin<3, overlap=.5; end
if nargin<2, tsiz=100; end
showplots=0; imdebug=0; threshtype='Max50'; %orig 'Range50 (ImJ)'

imsize=size(im2);
tcenter=round(tsiz/2); %scalar
tstep=round(tsiz*(1-overlap)); %scalar
if min(imsize)>=tsiz,
	nstep=floor((imsize-tsiz*[1 1])./tstep);
	nstep=max([nstep; 0 0]) + [1 1];
	tstart=round((imsize-nstep.*tstep-tcenter*[1 1])/2); %center the grid (tstart is top-left)
	for i=1:nstep(2),
		for j=1:nstep(1),
			y(j,i)=tstart(1) + j*tstep;
			x(j,i)=tstart(2) + i*tstep;
			i1=y(j,i)-tcenter; if i1<1, i1=1; end
			j1=x(j,i)-tcenter; if j1<1, j1=1; end
			i2=y(j,i)+tcenter; if i2>imsize(1), i2=imsize(1); end
			j2=x(j,i)+tcenter; if j2>imsize(2), j2=imsize(2); end
			im3=im2(i1:i2,j1:j2);
			if imdebug, im{j,i}=im3; end

	%disp(['[' int2str([j i]) ']: @[' int2str([x(j,i) y(j,i)]) ']; siz=' int2str(size(im3)) ]);
			%ac = imAutoCorr(im3, 0);
			ac = imAutoCorr(im3, 3); %Match DoAnis
			anisOne= ACAnisSingle(ac, 0);
			type=indAnisOne(anisOne,threshtype); %orig 'Range50(ImJ)'
			if anisOne.err.code || isempty(type),
				%u(j,i)=NaN; v(j,i)=NaN;
				major(j,i)=NaN; minor(j,i)=NaN; anis(j,i)=NaN; ang(j,i)=NaN;
				major2(j,i)=NaN; minor2(j,i)=NaN; anis2(j,i)=NaN; ang2(j,i)=NaN;
			else
				prop=anisOne.wprop;
				major(j,i)=prop.major(type); minor(j,i)=prop.minor(type);
				anis(j,i)=prop.anis(type); ang(j,i)=prop.orient(type); %must flip for ij plots
				prop=anisOne.rprop; %regular flat-top statistics
				major2(j,i)=prop.major(type); minor2(j,i)=prop.minor(type);
				anis2(j,i)=prop.anis(type); ang2(j,i)=prop.orient(type);
			%v(j,i)=sin(ang(j,i)*pi/180); u(j,i)=cos(ang(j,i)*pi/180);
			end
		end
	end
else, %tiles bigger than image
	x=[]; y=[];
	ang=[]; anis=[]; major=[]; minor=[];
	ang2=[]; anis2=[]; major2=[]; minor2=[];
	tstep=NaN;
end

%ac = imAutoCorr(im2, 0);
ac = imAutoCorr(im2, 3); %Match DoAnis
anisOne= ACAnisSingle(ac, 0);
type=indAnisOne(anisOne,threshtype); %orig 'Range50(ImJ)'
if anisOne.err.code,
	full.major=NaN; full.minor=NaN; full.anis=NaN; full.ang=NaN; 
	full.major2=NaN; full.minor2=NaN; full.anis2=NaN; full.ang2=NaN;
else
	prop=anisOne.wprop; %type=1;
	full.major=prop.major(type); full.minor=prop.minor(type);
	full.anis=prop.anis(type); full.ang=prop.orient(type); %must flip for ij plots
	prop=anisOne.rprop;
	full.major2=prop.major(type); full.minor2=prop.minor(type);
	full.anis2=prop.anis(type); full.ang2=prop.orient(type);
end

if nargout>0,
	acGrid.x=x; acGrid.y=y; acGrid.thresh=threshtype; acGrid.ang=ang;
	acGrid.anis=anis; acGrid.major=major; acGrid.minor=minor; acGrid.full=full;
	acGrid.ang2=ang2; acGrid.anis2=anis2; acGrid.major2=major2; acGrid.minor2=minor2; 
	acGrid.tstep=tstep; acGrid.tsize=2*tcenter+1;
	acGrid.xlim=[1 imsize(2)]; acGrid.ylim=[1 imsize(1)];
	if imdebug, acGrid.im=im; end
end

if showplots,
	mag=1;
	figure(1); clf;
	subplot(1,3,1); imagesc(im2); colormap(gray); axis equal;
		xlim([1,imsize(2)]); ylim([1 imsize(1)]); hold on;
		DrawArrows(x,y,anis,ang,1,mag,'m-',2);
		title(['ang=' num2str(full.ang,'%.0f') '; anis=' num2str(full.anis,'%0.1f')]);

	subplot(1,3,2); m2=DrawArrows(x,y,anis,ang,1,mag); hold on;
		DrawArrows(imsize(2)/2,imsize(1)/2,full.anis,full.ang,0,m2,'m-',2);
		axis ij; axis equal; xlim([1,imsize(2)]); ylim([1 imsize(1)]);
		title('AnisIndex');

	subplot(1,3,3); m2=DrawEllipses(x,y,major,minor,ang,1,mag); hold on;
		DrawEllipses(imsize(2)/2,imsize(1)/2,full.major,full.minor,full.ang,0,m2,'m-');
		axis ij; axis equal; xlim([1,imsize(2)]); ylim([1 imsize(1)]);
		title('Ellipses');

	if imdebug, %debug: show corners
		figure(2); clf; nc=2; %nc=4 for sharing with original subplot(1,2,1) image
		subplot(2,nc,nc-1); ShowIm(1, 1);
		subplot(2,nc,nc); ShowIm(1, nstep(2));
		subplot(2,nc,2*nc-1); ShowIm(nstep(1), 1);
		subplot(2,nc,2*nc); ShowIm(nstep(1), nstep(2));
	end
end

	function ShowIm(a,b)
		imagesc(im{a,b}); axis equal; axis tight;
		title(['[' int2str([x(a,b) y(a,b)]) ']; ang=' num2str(ang(a,b),'%.0f') ';ani=' num2str(anis(a,b),'%0.1f')]);
	end
end

function pInd=indAnisOne(anisOne, threshtype) %get index from ACAnisSingle()
pInd=[];
if isfield(anisOne,'label'), %any AnisOne results?
	for i=1:numel(anisOne.label), %find threshtype
		if strcmpi(threshtype,anisOne.label{i})==1, pInd=i; end
	end
end
end

