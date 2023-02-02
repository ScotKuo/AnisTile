function stat=boxplot2(x,logflag,DLabel,notch,sym,vert,whis,width,showcum)
%BOXPLOT2 Display box-whisker plots of cell array data (not matrix).
%   BOXPLOT2(X{},LogFlag,DLabel{},NOTCH,SYM,VERT,WHIS,WIDTH,SHOWCUM) produces a box and whisker
%   plot for each cell of X{}. The box has lines at the lower quartile, median, 
%   and upper quartile values. The whiskers are lines extending from 
%   each end of the box to show the extent of the rest of the data. 
%   Outliers are data with values beyond the ends of the whiskers.
%   --SCK: added average, stdev, SEM (95% conf interval); XLab; LogFlag
% 
%	DLabel{} = cell array of strings to label data columns; default=column numbers
%   NOTCH = 1 produces a notched-box plot. Notches represent a robust 
%   estimate of the uncertainty about the means for box to box comparison.
%   NOTCH = 0 (default) produces a rectangular box plot. 
%   SYM sets the symbol for the outlier values if any (default='r+'). 
%   VERT = 0 makes the boxes horizontal (default: VERT = 1, for vertical).
%   WHIS defines the length of the whiskers as a function of the IQR
%   (default = 1.5). If WHIS = 0 then BOXPLOT displays all data  
%   values outside the box using the plotting symbol, SYM.
%   WIDTH = 0.8; scaled width of boxes; >1 means overlapping
%   SHOWCUM = 0 (default); when nonzero (=1) will show additional whisker/box
%   of cumulative data of all columns.  Forced to =0 if only one column.
%
%   If there are no data outside the whisker, then, there is a dot at the 
%   bottom whisker, the dot color is the same as the whisker color. If
%   a whisker falls inside the box, we choose not to draw it. To force
%   it to be drawn at the right place, set whissw = 1.
%
%   BOXPLOT2 calls BOXUTIL to do the actual plotting.
%   boxes are quartiles, red=median; black star is mean; black lines are 95% conf
%      limit {SEM}; green lines are stdev; notches estimate uncertainty of
%      means
%	Compare BoxPlot with BoxPlot2

%   Copyright (c) 1993-98 by The MathWorks, Inc.
%   Modified by SCK, 2002_0614 for overall whisker box (SHOWCUM)
%	SCK 08_1121 added logFlag
%   SCK 15_0922: added stat output (needed unwrap function)
if nargin < 2, logflag=0; end
if nargin < 3, DLabel = {}; end
if nargin < 4, notch = 1; end
if nargin < 5, sym = 'r+'; end
if nargin < 6, vert = 1; end
if nargin < 7, whis = 1.5; end
if nargin < 8, width = 0.8; end
if nargin < 9, showcum=0; end

if ~iscell(x), error('BoxPlot2 only works with cell arrays.'); end

whissw = 0; % don't plot whisker inside the box.
n=length(x);
if n>1,
	ntot=0;
	for i=1:n,
		ntot=ntot + length(x{i}); end
	cum=zeros(1,ntot); j=1;
	for i=1:n,
		n0=length(x{i});
		cum(j:(j+n0-1))=x{i};
		j=j+n0;
	end
else
	showcum=0; cum=x{1};
end
yy=x{1};

k = find(~isnan(cum));
ymin = min(cum(k));
ymax = max(cum(k));
if ~logflag,
	dy = (ymax-ymin)/20;
	ylims = [(ymin-dy) (ymax+dy)];
else
	dy= log(ymax/ymin)/20;
	ylims=[ymin/dy ymax*dy];
end
if showcum,
	xlims=[0.5 n+2.5]; %add 2 boxes: gap & cum
	lb=1:(n+2);
	lf=(n+2)*min(0.15,0.5/(n+2));
else
	xlims=[0.5 n+0.5]; 
	lb=1:n;
	lf=n*min(0.15,0.5/n);
end

% Scale axis for vertical or horizontal boxes.
cla
set(gca,'NextPlot','add','Box','on');
if vert
	if ~logflag, axis([xlims ylims]); end
	set(gca,'XTick',lb);
	set(gca,'YLabel',text(0.1,0.1,'Values'));
	if logflag, set(gca,'YScale','Log'); end
	if ~isempty(DLabel), set(gca,'XTickLabel',DLabel);
	else set(gca,'XLabel',text(0.1,0.1,'Column Number')); end
else
	if ~logflag, axis([ylims xlims]); end
	set(gca,'YTick',lb);
	set(gca,'XLabel',text(0.1,0.1,'Values'));
	if logflag, set(gca,'XScale','Log'); end
	if ~isempty(Dlabel), set(gca,'YTickLabel',DLabel);
	else set(gca,'YLabel',text(0.1,0.1,'Column Number')); end
end

if n==1
	vec = find(~isnan(yy));
	if ~isempty(vec)
		stat=boxutil(yy(vec),notch,lb,lf,sym,vert,whis,whissw,width,logflag);
	end
else
	for i=1:n
		z = x{i};
		vec = find(~isnan(z));
		if ~isempty(vec)
			stat(i)=boxutil(z(vec),notch,lb(i),lf,sym,vert,whis,whissw,width,logflag);
		end
	end
	if showcum,
		vec=find(~isnan(cum));
		if ~isempty(vec)
			stat(i+1)=boxutil(cum(vec),notch,lb(n+2),lf,sym,vert,whis,whissw,width,logflag);
		end
    end
    stat=unwrap(stat);
end
set(gca,'NextPlot','replace');
end

function stat=unwrap(instat)
    ni=numel(instat);
    fdn=fieldnames(instat); nj=numel(fdn);
    stat=instat(1);
    for i=2:ni,
        for j=1:nj, a=getfield(instat(i), fdn{j});
            b=getfield(stat, fdn{j});
            stat=setfield(stat, fdn{j}, [b a]); end
    end     
end