function stat=boxutil(x,notch,lb,lf,sym,vert,whis,whissw,width,logflag)
%BOXUTIL Produces a single box plot.
%   BOXUTIL(X) is a utility function for BOXPLOT, which calls
%   BOXUTIL once for each column of its first argument. Use
%   BOXPLOT rather than BOXUTIL.
%Extras: average(star), stdev(black), 95ConfInterval(green); outliers(red)
%

%   Copyright (c) 1993-98 by The MathWorks, Inc.
%   Modified by SCK, 2002_0614:
%      added average (star) & stdev (black); empty sym suppresses outliers; width control
%	SCK 2008_1121: added logflag and related code
%   SCK 15_0922: added export of statistics

if min(size(x)) ~= 1, error('First argument has to be a vector.'); end
if nargin<8, error('Requires eight input arguments.'); end
if nargin<9, width=0.7; end %MatLab originally hardcoded 0.5; >1 means overlapping
if nargin<10, logflag=0; end %Do logarithmic weighting (e.g. ave=geometric ave)

showSEM=0; showSD=0; %sym='';
whisk_width_ratio=0.7;

if logflag, x=log(x); end
% define the median and the quantiles
ave = mean(x);
sd = std(x);
ci95 = sem(x); % 95% confidence interval
med=prctile(x,50);
q1=prctile(x,25);
q3=prctile(x,75);
stat.ave=ave; stat.sd=sd; stat.ci95=ci95; stat.med=med; stat.q1=q1; stat.q3=q3;
stat.n=numel(x);

% find the extreme values (to determine where whiskers appear)
vhi = q3+whis*(q3-q1);
[l,ind] = min(abs((x - vhi) + (x > vhi) * max(abs(x - vhi))));
upadj = x(ind);
vlo = q1-whis*(q3-q1);
[l,ind] = min(abs((vlo - x) + (vlo > x) * max(abs(vlo - x))));
loadj = x(ind);

x1 = lb*ones(1,2);
x2 = x1 + [-lf,lf] * width * whisk_width_ratio;
yy = x(x<loadj | x > upadj); %outliers
stat.whisklo=loadj; stat.whiskhi=upadj;

if isempty(yy) && ~isempty(sym);
   yy = loadj;
   [a1 a2 a3 a4] = colstyle(sym);
   sym = [a2 '.'];
end

xx = lb*ones(1,length(yy));
    lbp = lb + width*lf;
    lbm = lb - width*lf;

if whissw == 0
   upadj = max(upadj,q3);
   loadj = min(loadj,q1);
end

% Set up (X,Y) data for notches if desired.
if ~notch
    xx2 = [lbm lbp lbp lbm lbm];
    yy2 = [q3 q3 q1 q1 q3];
    xx3 = [lbm lbp];
else
    n1 = med + 1.57*(q3-q1)/sqrt(length(x));
    n2 = med - 1.57*(q3-q1)/sqrt(length(x));
    if n1>q3, n1 = q3; end
    if n2<q1, n2 = q1; end
    lnm = lb-width*lf/2;
    lnp = lb+width*lf/2;
    xx2 = [lnm lbm lbm lbp lbp lnp lbp lbp lbm lbm lnm];
    yy2 = [med n1 q3 q3 n1 med n2 q1 q1 n2 med];
    xx3 = [lnm lnp];
end
yy3 = med * [1 1];
xx4 = [lbm lbp];
yy4 = (ave + sd) * [1 1];
yy5 = (ave - sd) * [1 1];
yy6 = (ave + ci95) * [1 1];
yy7 = (ave - ci95) * [1 1];

if logflag,
	q3=exp(q3); upadj=exp(upadj); loadj=exp(loadj); q1=exp(q1);
	yy=exp(yy); yy2=exp(yy2); yy3=exp(yy3); yy4=exp(yy4); yy5=exp(yy5); yy6=exp(yy6); yy7=exp(yy7);
	ave=exp(ave);
end

% Determine if the boxes are vertical or horizontal.
% The difference is the choice of x and y in the plot command.
sym_ave='k*'; sym_whisk='b:'; %sym_whisk='b--';
if vert
    plot(x1,[q3 upadj],sym_whisk,x1,[loadj q1],sym_whisk,...
        x2,[loadj loadj],'b-',...
        x2,[upadj upadj],'b-',xx2,yy2,'b-',xx3,yy3,'r-');
    if showSD, plot(xx4,yy4,'g-', xx4,yy5,'g-'); end
    if showSEM, plot(xx4,yy6,'k-', xx4,yy7,'k-'); end
	plot(lb,ave,sym_ave);
	if ~isempty(sym),plot(xx,yy,sym); end
else
    plot([q3 upadj],x1,sym_whisk,[loadj q1],x1,sym_whisk,...
        [loadj loadj],x2,'b-',...
        [upadj upadj],x2,'b-',yy2,xx2,'b-',yy3,xx3,'r-');
    if showSD, plot(yy4,xx4,'g-', yy5,xx4,'g-'); end
    if showSEM, plot(yy6,xx4,'k-', yy7,xx4,'k-'); end
	plot(ave,lb,sym_ave);
	if ~isempty(sym), plot(xx,yy,sym); end
end

