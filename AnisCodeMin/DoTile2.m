function [imgs,crGrid]=DoTile2(imgs, setnum, saveFig, replaceFig)
%DOTILE2 analyze the acGrid data for correlations between stains.
%	Will plot every pair-wise comparison between stains of measured
%	attributes. Use DoTileCList and DoTileCListFig to show the pair-wise
%	stain correlations as a function of tilesize that was calculated here.
% Other arguments {Default}:
%	setnum: tilesizes, but in order of analysis (see DoTile); not useful
%		anymore (was useful in earlier versions)
%
% 15_0428 SCK

if nargin<4, replaceFig=0; end %only one Fig (like reusing figure)
if nargin<3, saveFig=-1; end %prompt user
if nargin<2, setnum=[]; end
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

close all; %must close figs (cbfreeze); letter size aspect ratio
if isempty(setnum), ns=size(imgs.acGrid,1); setnum=1:ns; end
loc.nr=numel(imgs.im)-1; loc.nc=loc.nr; %loc=getLoc(loc);
ns=numel(setnum); loc.ns=ns; loc.text=[0.05 0.85 0.1]; %[x0 y0 dy] for placing text
colrs='ycgmrbkycgmrbkycgmrbkycgmrbk'; %color order for tileSizes/sets

OrderSetNum();
dSizeRange=[50 205];
crGrid(1)=anaChan('anis');
crGrid(2)=anaChan('ang');
crGrid(3)=anaChan('anis2');
crGrid(4)=anaChan('');
crGrid(5)=anaChan('major');
nf=numel(crGrid);

	if saveFig<0, %prompt user
		reply=input('Save figure(s) as eps file [y]? ','s');
		if isempty(reply) || lower(reply(1))=='y', saveFig=1;
		else saveFig=0; end
	end
	if saveFig,
		ofn=strrep(imgs.froot,'%',''); %remove bad chars for filename: %
		dname=imgs.pname(1:(numel(imgs.pname)-1));
		currDir=cd(dname);
		for i=1:nf,
			fld=crGrid(i).fld;
			figure(i);
			print([ofn ',' fld '.pdf'],'-painters','-dpdf');
		end
		cd(currDir);
	end


	function crGrid=anaChan(fld) %calculate for all, but display only dSizeRange
		if replaceFig, close all; end; 
		bigfigure([],1);
		myColrs=''; dFlgs=[]; dCnt=0; %vs TileSize
		for j=1:loc.ns, %Tilesize
			tsize=imgs.acGrid{setnum(j),1}.tsize;
			dFlgs(j)= (tsize>=dSizeRange(1) && tsize<=dSizeRange(2));
			if dFlgs(j),
				dCnt=dCnt+1; myColrs(j)=colrs(dCnt);
			else
				myColrs(j)=' '; %not plotted
			end
		end
		for k=1:loc.nr, %channel, row
			for i=1:k, %col
				loc.base=loc.nc * (k-1) + 1 + (i-1); loc.row=k; loc.col=i;
				for j=1:loc.ns, %Tilesize
					linspec=[myColrs(j) 'o'];
					corr{i,k,j}=anaChan0(imgs.acGrid{setnum(j),i}, imgs.acGrid{setnum(j),k+1}, ...
						loc, imgs.imname{i}, imgs.imname{k+1}, fld, linspec, dFlgs(j));
				end
			end
		end
		crGrid.corr=corr; crGrid.fld=fld;
		anaLabel0(crGrid,loc,myColrs);
		suptitle([strrep([imgs.fname '_' imgs.boxname{1}],'_','\_') '; ' fld ]);
	end

	function OrderSetNum()
		tsizes=zeros(1,ns);
		for i=1:ns, tsizes(i)=imgs.acGrid{i,1}.tsize; end
		[~,idx]=sort(tsizes);
		setnum=setnum(idx);
	end

if nargout<2, clear crGrid; end
if nargout<1, clear imgs; end

end

function corr=anaChan0(acGrid1, acGrid2, loc, chName1, chName2, fld, linspec, dFlg)
u=getfield(acGrid1,fld); v=getfield(acGrid2,fld);
if strcmpi('ang',fld) | strcmpi('ang2',fld),
	u=angShift(u(:),getfield(acGrid1.full,fld));
	v=angShift(v(:),getfield(acGrid2.full,fld));
	[u,v]=flipCorners(u,v,30);
end
	corr=correl(u, v);
	corr.row=loc.row; corr.col=loc.col; corr.xname=chName1; corr.yname=chName2;
	corr.tsize=acGrid1.tsize; corr.fld=fld;

if dFlg,
	subplot(loc.nr, loc.nc, loc.base);
	doplot(u, v, linspec);
	if loc.row==loc.col, tstr=['x=' chName1 '; ']; else tstr=''; end
	%title([tstr 'r=' num2str(corr.r,3) ';p=' num2str(corr.prob,3)]);
	title([tstr 'r=' num2str(corr.r,3)]);
	if loc.col==1, ylabel(['y=' chName2]); end
end
end

function anaLabel0(crGrid,loc,colrs)
	for k=1:loc.nr, %channel, row
		for i=1:k, %col
			loc.base=loc.nc * (k-1) + 1 + (i-1); loc.row=k; loc.col=i;
			subplot(loc.nr, loc.nc, loc.base);
			if loc.row==loc.col, tstr=['x=' crGrid.corr{i,k,1}.xname '; r=']; else tstr='r='; end
			for j=1:loc.ns, %Tilesize
				if colrs(j) ~= ' ',
					tstr=[tstr num2str(crGrid.corr{i,k,j}.r,3)];
					if j<loc.ns, tstr=[tstr ',']; end
					tsizes(j)=crGrid.corr{i,k,j}.tsize;
				end
			end
			title(tstr);
			if loc.col==1, ylabel(['y=' crGrid.corr{i,k,1}.yname]); end
		end
	end
	subplot(loc.nr, loc.nc, 2);
	set(gca,'visible','off');
	x=loc.text(1); y=loc.text(2); dy=loc.text(3);
	for j=1:loc.ns,
		if colrs(j) ~= ' ',
		text(x, y, ['TileSize=' int2str(tsizes(j))], 'Color', colrs(j));
		y=y-dy;
		end
	end

end

function ang=angShift(ang, ref) %shift angles so centered on ref +-90d
	ni=ang<(ref-90); ang(ni)=ang(ni)+180;
	ni=ang>(ref+90); ang(ni)=ang(ni)-180;
end

function doplot(u, v, linspec)
	u=u(:); v=v(:); %reshape as single column
	plot(u,v, linspec); hold on;
end
