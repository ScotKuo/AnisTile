% Ski down AutoCorr to get distance constants lambda for models (exp2 or explin)
%	will call ACAnisScan to determine highest ridge and plane (default rplane=10pix)
% acq=ACRidge(ac, skipflag, [model, rplane], [im, imtitle, plotflag, listflag])
%	model='explin' or 'exp2'; default='explin'
%	rplane=#pix to find major-axis plane; default=10pix
%	im,imtitle=image and title over image to slow in figure; default: fill
%		with autocorr contours
%	plotflag=can suppress output when 0; default=1 (graphs)
%	listflag=can suppress output when 0; default=1 (fitval table)
%
% SCK 13_1218
function [acq]=ACRidge(ac, model, rplane, im, imtitle, bb, plotflag, listflag, suppressWarn_wACAnis)
if nargin<9, suppressWarn_wACAnis=1; end
if nargin<8, listflag=1; end
if nargin<7, plotflag=1; end
if nargin<6, bb=[]; end
if nargin<4, im=[]; imtitle=''; end
if nargin<3, rplane=10; end %find angle of plane at r=rplane
if nargin<2, model='explin'; end %else exp2
% ac2=ac;
% if max(max(ac)) < 2^16, ac2=uint16(ac); end
% anis=ACAnisScan(ac2,20);

acq.err.code=0; acq.err.msg='';
anis=ACAnisScan(ac,30,[.99 .05],suppressWarn_wACAnis);
if ~isfield(anis,'levf'), %get error state and bail (no point in plotting)
	acq.err.code=-1; errstate=SkiPath([],[],[],[],'');
	acq.plane.slow=errstate; acq.plane.fast=errstate;
	return
end
ind=(anis.levf>=0.1) & (anis.rprop.area>4);
r=anis.rprop.major(ind); th=anis.wprop.orient(ind)*pi/180;
px0=0; py0=0;
	%px0=anis.rprop.xcen(1); py0=anis.rprop.ycen(1); %without meshgrid
	x=r.*cos(th)+px0; y=r.*sin(th)+py0; %ridge
cent=[anis.rprop.xcen(1) anis.rprop.ycen(1)]; %without shifting axes; position in matrix

if suppressWarn_wACAnis, ws = warning('off','all'); end
ridge.slow=SkiPath(ac, anis.rprop.major(ind), th, cent, model);
	acq.err=ErrCopy(acq.err, ridge.slow.err, 'RidgeFit:');
ridge.fast=SkiPath(ac, anis.rprop.minor(ind), th+pi/2, cent, model);
	acq.err=ErrCopy(acq.err, ridge.fast.err, 'RidgeFit:');
acq.ridge=ridge;

mr=max(anis.rprop.major(ind)); th0=[];
if ~ridge.slow.err.code,
	if mr>rplane,
		th0=interp1(ridge.slow.r, ridge.slow.th, rplane);
		if numel(th0)<1,
			disp(['Unable to find angle for ellipse with majorAx=' num2str(rplane) '.']);
			acq.err=ErrCodeMsg(acq.err, 8, 'Plane orient; ');
		end
	else
		%th0=interp1(ridge.slow.r, ridge.slow.th, mr/2);
		th0=interp1(ridge.slow.r, ridge.slow.th, (mr-1));
	end
end
plane.slow=SkiPath(ac,[1 mr], [th0 th0], cent, model);
	acq.err=ErrCopy(acq.err, plane.slow.err, 'PlaneFit:');
mr=max(anis.rprop.minor(ind));
plane.fast=SkiPath(ac,[1 mr], [th0 th0]+(pi/2), cent, model);
	acq.err=ErrCopy(acq.err, plane.fast.err, 'PlaneFit:');
acq.plane=plane;

if plotflag, clf;
	if ~isempty(im),
		subplot(2,2,1); imagesc(im); axis ij; axis equal;
		if ~isempty(bb), hold on;
			vx=[bb(1) bb(1) bb(1)+bb(3) bb(1)+bb(3) bb(1)];
			vy=[bb(2) bb(2)+bb(4) bb(2)+bb(4) bb(2) bb(2)];
			plot(vx, vy, 'y-');
		end
		title(strrep(imtitle,'_','\_')); axis tight;
		subplot(2,2,3);
	else
		subplot(1,2,1);
	end
	
	colormap('default'); hold on;
	[px,py]=meshgrid(anis.xy(3):anis.xy(4),anis.xy(1):anis.xy(2));
	contour(px, py, ac, anis.lev(ind)); axis tight; axis ij; axis equal;
	caxis([anis.min anis.max]);
	plot(x,y,'k-','LineWidth',2); %ridge
	plot(ridge.fast.x+px0, ridge.fast.y+py0, 'b:', ...
		ridge.slow.x+px0, ridge.slow.y+py0, 'b-');
	plot(plane.fast.x+px0, plane.fast.y+py0, 'r:', ...
		plane.slow.x+px0, plane.slow.y+py0, 'r-');
	xlabel('XDistance (pix)'); ylabel('YDistance (pix)');

	subplot(2,2,2); hold on; xlabel('Distance (pix)'); ylabel('AutoCorr Value');
	ac50=mean([max(max(ac)) min(min(ac))]);
	plot(ridge.fast.r, ridge.fast.ac, 'b--', ...
		ridge.slow.r, ridge.slow.ac, 'b-');
	try fr50=interp1(ridge.fast.ac, ridge.fast.r, ac50);
		plot(fr50,ac50,'bo');
	catch ME
		acq.err=ErrCodeMsg(acq.err, 16, 'Ridge intrp; '); end
	try sr50=interp1(ridge.slow.ac, ridge.slow.r, ac50);
		plot(sr50,ac50,'bo');
	catch ME
		acq.err=ErrCodeMsg(acq.err, 16, 'Ridge intrp; '); end
	plot(ridge.fast.r, ridge.fast.efac, 'c:', ...
		ridge.slow.r, ridge.slow.efac, 'c-');

	plot(plane.fast.r, plane.fast.ac, 'r--', ...
		plane.slow.r, plane.slow.ac, 'r-');
	try fr50=interp1(plane.fast.ac, plane.fast.r, ac50);
		plot(fr50,ac50,'ro');
	catch ME
		acq.err=ErrCodeMsg(acq.err, 32, 'Plane intrp; '); end
	try sr50=interp1(plane.slow.ac, plane.slow.r, ac50);
		plot(sr50,ac50,'ro');
	catch ME
		acq.err=ErrCodeMsg(acq.err, 32, 'Plane intrp; '); end
	plot(plane.fast.r, plane.fast.efac, 'm:', ...
		plane.slow.r, plane.slow.efac, 'm-');
	axis tight; xl=xlim; xlim([-5 xl(2)]);

	subplot(2,2,4); hold on; xlabel('Distance (pix)'); ylabel('%Residuals of fit');
	amp=double(anis.max-anis.min)/100.0; %so 100%=full amplitude of AC
	plot(ridge.fast.r, (ridge.fast.efac-ridge.fast.ac)/amp, 'c:', ...
		ridge.slow.r, (ridge.slow.efac-ridge.slow.ac)/amp, 'c-');
	plot(plane.fast.r, (plane.fast.efac-plane.fast.ac)/amp, 'm:', ...
		plane.slow.r, (plane.slow.efac-plane.slow.ac)/amp, 'm-');
	title(['Model: ' ridge.fast.ef.type]);
	axis tight; xl=xlim; xlim([-5 xl(2)]);
end

if suppressWarn_wACAnis, warning(ws); end %restore warnings

if listflag,
	disp(['Fitted values for ' ridge.fast.ef.type ': {' ridge.fast.fitlab{:} '}:']);
	fitval(ridge.fast,'ridge-fast');
	fitval(ridge.slow,'ridge-slow');
	fitval(plane.fast,'plane-fast');
	fitval(plane.slow,'plane-slow');
end

end

function [val]=SkiPath(ac, r, th, cent, model) %radius, angle from cent
val.err.code=0; val.err.msg='';
if isempty(th), val.err.code=1; val.err.msg='No Args; '; ErrState(); return; end
try	r2=-floor(max(r)):floor(max(r));
	smr=smooth_boxcar(r,3); smr(end)=r(end); %remove bumps in small r
	[smr2,ia]=unique(smr); th2=th(ia); %force unique values, just in case
	th2=interp1([-fliplr(smr2) smr2],[fliplr(th2) th2],r2); %interpolate through origin
	th2=MedFilt(th2,10); %filter out spikes
	x2=r2.*cos(th2)+cent(1); y2=r2.*sin(th2)+cent(2);
	ind=(r2>0); r2=r2(ind); x2=x2(ind); y2=y2(ind); %only analyze positive r; excl origin
	val.r=r2; val.th=th2(ind);
	val.x=x2-cent(1); val.y=y2-cent(2); %for ease of plotting; non-shifted axes
	val.ac=interp2(double(ac),x2,y2);
catch ME
	val.err=ErrCodeMsg(val.err, 2, 'Ski intrp; ');
	ErrState();
	return;
end

opt=optimset('Display','off');
%opt = optimoptions('lsqcurvefit','Display','iter');
base=min(min(ac)); amp=max(max(ac))-base; rel=0.25;

% Separated amplitudes exp2decay2=p3*exp(-x/p1)+p4*exp(-x/p2))+p5
lb=[1 10 amp/10 amp/10 0]; ub=[50 1000 amp amp amp/2];
ef=lsqfit(val.r, val.ac, @fit_exp2decay2, [4 50 amp*rel amp*(1-rel) base], ...
	lb, ub, opt);
ef.type='Two-Expon';
exp2.ef=ef; 
exp2.fitlab={'Tau1,', 'Tau2,', 'Ampl1,', 'Ampl2,', 'baseline'};
if ~ef.error,
	exp2.efac=fit_exp2decay2(ef.p, val.r);
else exp2.efac=NaN(1,numel(val.r));
	val.err=ErrCodeMsg(val.err, 4, 'Exp2 fit; ');
end
val.exp2=exp2;

% expdecayslope=p2*exp(-x/p1)-x*p3+p4;
lb=[1 amp/50 0 amp/5]; ub=[7 amp amp amp*2];
lp=polyfit(val.r, val.ac, 1);
ef=lsqfit(val.r, val.ac, @fit_expdecayslope, ...
	[7 amp*rel -lp(1)/3 lp(2)-amp*rel], ...
	lb, ub, opt);
ef.type='Expon+Lin';
explin.ef=ef; 
explin.fitlab={'Tau1,', 'Ampl1,', 'Slope,', 'Base2'};
if ~ef.error,
	explin.efac=fit_expdecayslope(ef.p, val.r);
else explin.efac=NaN(1,numel(val.r));
	val.err=ErrCodeMsg(val.err, 8, 'Exp+Lin fit; ');
end
val.explin=explin;

if strcmpi(model,'exp2'),
	val.fitlab=exp2.fitlab; val.ef=exp2.ef; val.efac=exp2.efac;
else
	val.fitlab=explin.fitlab; val.ef=explin.ef; val.efac=explin.efac;
end

	function ErrState
	val.r=[0 max(r)]; val.th=[0 0]; val.x=[0 max(r)]; val.y=[0 0];
	val.ac=NaN(1,numel(val.r));
	val.exp2.ef.type='Two-Expon'; val.exp2.ef.error=1;
	val.exp2.fitlab={'Tau1,', 'Tau2,', 'Ampl1,', 'Ampl2,', 'baseline'};
	val.exp2.efac=NaN(1,numel(val.r));
	val.explin.ef.type='Expon+Lin'; val.explin.ef.error=1;
	val.explin.fitlab={'Tau1,', 'Ampl1,', 'Slope,', 'Base2'};
	val.explin.efac=NaN(1,numel(val.r));
	val.fitlab=val.explin.fitlab; val.ef=val.explin.ef; val.efac=val.explin.efac;
	end

end

function [errS]=ErrCodeMsg(errS, errval, errmsg) %update error structure, if needed
	if ~bitand(errS.code, errval),
		errS.code=bitor(errS.code, errval);
		errS.msg=[errS.msg errmsg];
	end
end

function [errStrg]=ErrCopy(errStrg, errSsrc, preMsg) %copy error structure if unique error
	if nargin<3, preMsg=''; end
	if errSsrc.code && ~bitand(errSsrc.code, errStrg.code),
		errStrg.code=bitor(errStrg.code, errSsrc.code);
		errStrg.msg=[errStrg.msg preMsg errSsrc.msg];
	end
end

function fitval(val, lab, nformat)
if nargin<3, nformat=1; end
if nformat, %nice format for publication tables
	out=[lab ':']; tstr=sprintf('\t');
	for i=1:numel(val.ef.p),
		out=[out tstr format_datum(val.ef.p(i), val.ef.p_err(i))];
	end
	disp(out);
else %utilitarian format
	disp([lab ': [' num2str(val.ef.p, 3) ']']);
	disp(['  %uncert: [' num2str(100*val.ef.p_err ./ val.ef.p, 3) ']']);
end
end
