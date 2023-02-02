function [imgs, stats]=ShowTileDistr(imgs, saveFigs, replaceFigs)
%SHOWTILEDISTR do box-whisker distrib of select metrics as a function of tilesize.
% Other arguments {Default}:
%
% 15_0507 SCK

if nargin<3, replaceFigs=0; end %only a few Figs (like reusing figure)
if nargin<2, saveFigs=-1; end %prompt user
if nargin<1 || isempty(imgs), imgs=[];
	[fname, pname] = uigetfile('*.mat;', 'Processed Data to Display');
	if isequal(fname,0) || isequal(pname,0), return; end %user cancelled
	load([pname fname]);
	if exist('imgs','var') ~= 1,
		disp('File does not contain ACTile information.  Exiting.');
		return;
	end
	disp(['Displaying analysis of image "' imgs.fname '".']); 
end

ns=size(imgs.acGrid,1); setnum=1:ns; %tilesizes
loc.nchan=numel(imgs.im); loc.nr=2; loc.nc=round(numel(imgs.im)/loc.nr);
loc.ns=ns; %loc.text=[0.05 0.85 0.1]; %[x0 y0 dy] for placing text
%for stacked axes
loc.ax0=0.1; loc.ay0=.75; loc.ady=.2;
loc.aw=0.5; loc.ah=loc.ady;

OrderSetNum();
if replaceFigs, close all; end;
sc{1}=showChan('anis');
% sc{2}=showChan('ang');
% sc{3}=showChan('major');
% sc{4}=showChan('ang2');
nf=numel(sc);

	if saveFigs<0, %prompt user
		reply=input('Save figure(s) as pdf file [y]? ','s');
		if isempty(reply) || lower(reply(1))=='y', saveFigs=1;
		else saveFigs=0; end
	end
	if saveFigs,
		ofn=strrep(imgs.froot,'%',''); %remove bad chars for filename: %
		dname=imgs.pname(1:(numel(imgs.pname)-1));
		currDir=cd(dname);
		for i=1:nf,
			fld=sc{i}.fld;
			figure(i);
			print([ofn ',' fld 'BW.pdf'],'-painters','-dpdf');
		end
		cd(currDir);
	end


	function scc=showChan(fld)
		bigfigure([],1); scc=[];
		for k=1:loc.nchan,
			loc.base=k; loc.row=floor(k/loc.nc)+1; loc.col=loc.base-loc.nc*(loc.row-1);
			ydat={}; tsizlab={}; full=imgs.acGrid{setnum(1),k}.full;
			for i=1:ns, u=getfield(imgs.acGrid{setnum(i),k},fld); u=u(:);
				idy=(~isnan(u)); u=u(idy);
				if strcmpi('ang',fld) | strcmpi('ang2',fld),
					u=angShift(u(:),getfield(full,fld)); end
				ydat{i}=u; 
				tsiz2(i)=imgs.acGrid{setnum(i),k}.tsize;
				tsizlab{i}=int2str(imgs.acGrid{setnum(i),k}.tsize);
			end
			i=i+1; u=getfield(full,fld); idy=(~isnan(u)); ydat{i}=u(idy);
                tsizlab{i}='full'; tsiz2(i)=min(size(imgs.im{1}));
            myCh=imgs.imname{k}; if strcmpi(myCh,'DNA'), myCh='DAPI'; end
			scc=showChan0(ydat, tsizlab, myCh, loc, fld, scc, tsiz2);
            scc.froot=imgs.froot; scc.shape=imgs.boxname{k};
		end
		suptitle([strrep(imgs.fname,'_','\_') '; ' fld ]);
	end

	function OrderSetNum()
		tsizes=zeros(1,ns);
		for i=1:ns, tsizes(i)=imgs.acGrid{i,1}.tsize; end
		[~,idx]=sort(tsizes);
		setnum=setnum(idx);
	end

if nargout>1, stats=sc; end
if nargout<1, clear imgs; end

end

function sc=showChan0(ydat, dlabel, chName, loc, fld, sc, tsiz2, stkFlg)
if nargin<8, stkFlg=0; end
showOutliers=0;
if stkFlg,
	y0=loc.ay0-loc.ady*(loc.base-1);
	subplot('position',[loc.ax0 y0 loc.aw loc.ah]);
else
	subplot(loc.nr, loc.nc, loc.base);
end
if showOutliers, osym='r+'; else osym=''; end
stat=boxplot2(ydat,0,dlabel,0,osym);
%boxplot2(x,logflag,DLabel,notch,sym,vert,whis,width,showcum)
stat.n=zeros(1,numel(ydat)); for i=1:numel(ydat), stat.n(i)=numel(ydat{i}); end
stat.x=tsiz2(stat.n>0); stat.chName=chName;
if ~isempty(chName), title(chName); end
if ~isempty(fld), ylabel(fld); end
xlabel('TSize (pix)');
ax=gca; ax.XTickLabelRotation=60; %new feature MatLab2014b
if ~strcmpi('ang',fld) & ~strcmpi('ang2',fld),
    if showOutliers, ymx=12; %default
    else ymx=max(stat.whiskhi); ymx=ceil(ymx*2+1)/2; end
	ylim([0 ymx]); end
if stkFlg && y0>loc.ah, set(gca,'XTick',[]); set(gca,'XTickLabel',{}); end
sc0.fld=fld; sc0.stats=stat;
if isempty(sc), sc=sc0;
else sc.stats=[sc.stats stat]; end
end

function ang=angShift(ang, ref) %shift angles so centered on ref +-90d
	ni=ang<(ref-90); ang(ni)=ang(ni)+180;
	ni=ang>(ref+90); ang(ni)=ang(ni)-180;
end
