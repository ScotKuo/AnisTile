function imgs=TileTable(imgs, setnum, DTopts)
%TILETABLE export for Excel requested data from DoTile and ACTile (imgs
%    structure, see DoTile).  When called without arguments or empty imgs,
%    TileTable will prompt for the *.mat file that contains imgs from a
%    prior DoTile call.
% imgs=ShowTile(imgs, setnum)
%
% 17_1114 SK
if nargin<3, DTopts=DoTileOpts; end
if nargin<2, setnum=1; end
if nargin<1 || isempty(imgs), imgs=[];
	[fname, pname] = uigetfile('*.mat;', 'Processed Data to Display');
	if isequal(fname,0) || isequal(pname,0), return; end %user cancelled
	load([pname fname]);
	if exist('imgs','var') ~= 1,
		disp('File does not contain ACTile information.  Exiting.');
		return;
	end
	disp(['Exporting analysis of image "' imgs.fname '".']); 
end

tstr=sprintf('\t'); ns=numel(setnum);
coltitles={'DirRoot','FileRoot','TSize','X','Y','Ang', ...
	'Anis','Major','Minor' };


currDir=alistHeaders(coltitles,imgs.pname); %print header; save (initiate diary) if requested

for js=1:ns,
	if js>1, 
		if replaceFig, close all; end; 
		bigfigure([],1); end
	disp(['Plotting set#' int2str(j) '/' int2str(ns)]);
	%max range of data
	loc.AnisLim=ValLim(imgs,'anis',setnum(j));
	loc.MajAxLim=ValLimFull(imgs,'major');
	loc.AngLim=AngHLim(imgs,setnum(j));
	for i=1:numel(imgs.im), %channel
		loc.base=loc.nc * (i-1) + 1; %start of row
		loc=plotChan(imgs.im{i}, imgs.acGrid{setnum(j),i}, loc, 1, imgs.imname{i}, plotTight);
	end
	gbstr=sprintf('%03d',imgs.acGrid{setnum(j),i}.tsize);
%Conditional is a Kludge...
if isfield(imgs.acGrid{setnum(j),i},'thresh'),
	ttype=imgs.acGrid{setnum(j),i}.thresh;
else ttype='R50?'; end
	suptitle([strrep(imgs.fname,'_','\_') '\_' imgs.boxname{1} '(' ttype '); gridbox=' gbstr 'pix']);
	if saveFig<0, %prompt user
		reply=input('Save figure(s) as eps/pdf file [y]? ','s');
		if isempty(reply) || lower(reply(1))=='y', saveFig=1;
		else saveFig=0; end
	end
	if saveFig,
		ofn=[strrep(imgs.froot,'%','') '_' imgs.boxname{1}]; %remove bad chars for filename: %
		dname=imgs.pname(1:(numel(imgs.pname)-1));
		currDir=cd(dname);
		if figType, %1=epsc
			print([ofn ',' gbstr '.eps'],'-painters','-depsc');
		else %0=pdf
			print([ofn ',' gbstr '.pdf'],'-painters','-dpdf');
		end
		cd(currDir);
	end
end

%======Internal Functions========
	function currDir=alistHeaders(coltitles,dname) %print header (save if requested)
		newfile=1; currDir='.'; %default, stay here
		if DTopts.saveXLSFile, currDir=cd(dname);
			if exist(DTopts.outfile,'file')>0, newfile=0;
				if DTopts.eraseXLSFile, delete(DTopts.outfile); newfile=1; end
			end
			if newfile, diary(DTopts.outfile); end %skip saving header if not newfile
		end
		disp(['Directory:' tstr dname]);
		disp(['Initial ScanTime:' tstr datestr(now)]);
		ostr=coltitles{1};
		for i=2:numel(coltitles), ostr=[ostr tstr coltitles{i}]; end
		disp(ostr);
		if ~newfile && DTopts.saveXLSFile, diary(DTopts.outfile); end %start saving if not newfile
	end

	function Export()
	dname=anisOut.pname; [dn.parent dn.root ~]=fileparts(dname(1:end-1));
	currDir=alistHeaders(coltitles,imgs.pname); %print header; save (initiate diary) if requested
	for i=1:numel(ind),
		k=ind(i); j=anisOut.anis(k).wellID;
		imname=anisOut.anis(k).imname; if numel(imname)>4, imname=imname(1:4); end
		ostr=[anisOut.froot tstr dn.root tstr int2str(j) tstr ...
			num2str(anisOut.anis(k).wellOrient) tstr ...
			anisOut.wells.s(j).Shape(1:3) tstr imname tstr ];

		ostr=[ostr num2str(getAnisOne(anisOut.anis(k).anisOne,'Max50','Weight')) tstr];
		ostr=[ostr num2str(getAnisOne(anisOut.anis(k).anisOne,'Range50(ImJ)','Weight')) tstr];
		ostr=[ostr num2str(getAnisOne(anisOut.anis(k).anisOne,'Range50(ImJ)','Ellipse')) tstr];
		[anisval, fitErr]=getAnisFit(anisOut.anis(k).anis,'Plane','Expon+Lin');
		errCode=anisOut.anis(k).err.code; if errCode==0,errCode=[]; end
		ostr=[ostr num2str(anisval) tstr int2str(errCode) tstr];
		ostr=[ostr alist2err(anisOut.anis(k).anisOne,'Range50(ImJ)','Weight','Max50','Weight') ];
		ostr=[ostr alist2err(anisOut.anis(k).anisOne,'Range50(ImJ)','Ellipse','Max50','Weight') ];

		ostr=[ostr alistACstat(anisOut.anis(k)) ]; %ACorr stats
	%disp(sColCnt(ostr,1)); %debugging
		ostr=[ostr alist2(anisOut.anis(k).anisOne,scale,'Max50','Weight',1) ];
	%disp(sColCnt(ostr,2)); %debugging
		ostr=[ostr alist2(anisOut.anis(k).anisOne,scale,'Range50(ImJ)','Weight',1) ];
		ostr=[ostr alist2(anisOut.anis(k).anisOne,scale,'Range50(ImJ)','Ellipse',1) ];
		ostr=[ostr datestr(now) tstr num2str(scale.x) tstr alistBox(anisOut.anis(k).boundingbox)];

		ostr=[ostr alistFit(anisOut.anis(k).anis,scale,'Plane','Expon+Lin',1) ];
		ostr=[ostr anisOut.anis(k).err.msg ];
		disp(ostr);
	end
	diary off; %not needed if not saveOutFile, just in case
	if DTopts.saveOutFile, cd(currDir); end %see alistHeaders
	end

end

function lim=ValLim(imgs,fld,setnum) %find min/max of all values in an acGrid field
if nargin<3, setnum=[]; end
if isempty(setnum), ns=size(imgs.acGrid,1); setnum=1:ns; end
n=numel(imgs.im); ns=numel(setnum);
mn=zeros(ns,n); mx=zeros(ns,n);
for j=1:ns, for i=1:n, %all chan
	a=getfield(imgs.acGrid{setnum(j),i},fld);
	if ~isempty(a),	mn(j,i)=min(a(:)); mx(j,i)=max(a(:)); end
end, end
lim=[min(mn(:)) max([mx(:); 1])]; %force max>=1
end

function lim=AngHLim(imgs,setnum) %find maxcnt of all angular histos 
if nargin<2, setnum=[]; end
if isempty(setnum), ns=size(imgs.acGrid,1); setnum=1:ns; end
n=numel(imgs.im); ns=numel(setnum); mx=zeros(ns,n);
for j=1:ns, for i=1:n, %all chan
	ang=-angShift(imgs.acGrid{setnum(j),i}.ang(:), imgs.acGrid{setnum(j),i}.full.ang);
	ang(isnan(imgs.acGrid{setnum(j),i}.anis))=NaN; %remove bad ang for bad anis
	ang=rem(rem(ang,360)+360,360); %mimic rose2, but in degrees
	cnt=histc(ang,(0:15:360)); %hist @15d
	mx(j,i)=max(cnt);
end, end
lim=max([mx(:); 1]); %force max>=1
end

function lim=ValLimFull(imgs,fld) %find min/max of Full metrics, all chan
n=numel(imgs.im);
for i=1:n, %all chan
	a(i)=getfield(imgs.acGrid{1,i}.full,fld);
end
lim=[min(a) max(a)];
end

function loc=plotChan(im2, acGrid, loc, mag, channame, plotTight, drawtitle, sameScale)
	if nargin<8, sameScale=0; end
	if nargin<7, drawtitle=0; end
	if nargin<6, plotTight=0; end
	if nargin<5, channame=''; end
	if nargin<4, mag=1; end

	%optional plotting versions
	DrawMajor=0; showHeatMap=0; showFullEllipse=0;
	
	rang=acGrid.ang; rang(isnan(acGrid.anis))=NaN; %hide bad ellipses/angs
	full=acGrid.full; rang=angShift(rang, full.ang);
	tightw=loc.tightw; tighth=loc.tighth; cbargap=loc.cbargap; cbarw=loc.cbarw; cbarw2=loc.cbarw2;
	xb=loc.p0(1); yb=loc.p0(2)-floor(loc.base/loc.nc)*loc.tighth;
	if yb==loc.p0(2), firstRow=1; else firstRow=0; end
	
	pn=0;
	if ~plotTight, subplot(loc.nr,loc.nc,loc.base+pn);
		else subplot('position',[xb yb tightw tighth]); end
		imagesc(im2);
		if plotTight,
			set(gca,'YTick',[]); set(gca,'YTickLabel',{});
			set(gca,'XTick',[]); set(gca,'YTickLabel',{});
			set(gca,'Position',[xb yb tightw tighth])
			xb=xb+tightw;
		end
		axis equal; axis tight;
		colormap(jet); freezeColors;
		if drawtitle || ~isempty(channame),
			if plotTight, ylabel(channame); else title(channame); end; end
		if plotTight && firstRow, title('Fluor'); end

	pn=pn+1; %subplot(loc.nr,loc.nc,loc.base+pn);
	if ~plotTight, subplot(loc.nr,loc.nc,loc.base+pn);
		else subplot('position',[xb yb tightw tighth]); end
		imagesc(im2); colormap(gray); axis equal; freezeColors;
		xlim(acGrid.xlim); ylim(acGrid.ylim); hold on;
		if DrawMajor, DrawArrows(acGrid.x,acGrid.y,acGrid.major,acGrid.ang,1,mag,'m-');
		else DrawArrows(acGrid.x,acGrid.y,acGrid.anis,acGrid.ang,1,mag,'m-'); end
		if plotTight, set(gca,'YTick',[]); set(gca,'YTickLabel',{});
			set(gca,'XTick',[]); set(gca,'XTickLabel',{});
			set(gca,'Position',[xb yb tightw tighth])
			xb=xb+tightw; end
		if ~plotTight && (drawtitle || ~isempty(channame)), %negate angle since axis ij
			title(['ang=' num2str(-full.ang,'%.0f') '; anis=' num2str(full.anis,'%0.1f')]);
		end
		if DrawMajor, tstr='MajAxLenAngle'; else tstr='AnisAngle'; end
		if plotTight && firstRow, title(tstr); end

if showHeatMap,
	pn=pn+1; %subplot(loc.nr,loc.nc,loc.base+pn);
	if ~plotTight, subplot(loc.nr,loc.nc,loc.base+pn);
		else subplot('position',[xb yb tightw*1.4 tighth]); end
		rectangle('Position',[acGrid.xlim(1) acGrid.ylim(1) acGrid.xlim(2) acGrid.ylim(2)], ...
			'EdgeColor','none','FaceColor',[0.4 0.4 0.6]); %#666699 bkg
		hold on;
		if DrawMajor, h=sanePColor(acGrid.x(1,:),acGrid.y(:,1)',acGrid.major);
		else h=sanePColor(acGrid.x(1,:),acGrid.y(:,1)',acGrid.anis); end
		set(h,'ZData', ones( size(get(h,'ZData')) )); %float above rectangle
		if sameScale, set(gca,'CLim', loc.AnisLim); end
		colormap(hot); c1=colorbar();
		axis ij; axis equal; xlim(acGrid.xlim); ylim(acGrid.ylim);
		%set(gca,'Color',[0.4 0.4 0.6]); %doesn't work for export/printing
% freezeColors; %don't freezeColors for 'surface'/pcolor: problems for eps export
		if plotTight, set(gca,'YTick',[]); set(gca,'YTickLabel',{});
			set(gca,'XTick',[]); set(gca,'YTickLabel',{});
			gp=[xb yb tightw tighth]; set(gca,'Position',gp);
			c1=cbfreeze(c1);
			th2=0.025*tighth; cp=[gp(1)+gp(3)+cbargap gp(2)+th2 cbarw gp(4)-2*th2];
			set(c1,'Position',cp); set(c1,'NextPlot','add');
			axis(c1,'tight');
			xb=xb+tightw+cbarw2;
		else cbfreeze(c1); end
		if drawtitle && ~plotTight, title('AnisIndex'); end
		if DrawMajor, tstr='MajorAxLen'; else tstr='AnisIndex'; end
		if plotTight && firstRow, title(tstr); end
end

	pn=pn+1; %subplot(loc.nr,loc.nc,loc.base+pn);
	if ~plotTight, subplot(loc.nr,loc.nc,loc.base+pn);
		else subplot('position',[xb yb tightw tighth]); end
		m2=DrawEllipses(acGrid.x,acGrid.y,acGrid.major,acGrid.minor,rang,1,mag); hold on;
		if showFullEllipse,
		DrawEllipses(mean(acGrid.xlim),mean(acGrid.ylim),full.major,full.minor,full.ang,0,m2,'m-');
		end
		axis ij; axis equal; xlim(acGrid.xlim); ylim(acGrid.ylim);
		if plotTight, set(gca,'YTick',[]); set(gca,'YTickLabel',{});
			set(gca,'XTick',[]); set(gca,'YTickLabel',{});
			set(gca,'Position',[xb yb tightw tighth]);
			set(gca,'box','on'); %set(gca,'color','none');
			xb=xb+tightw; end
		if ~plotTight && (drawtitle || ~isempty(channame)),
			title(['maj=' num2str(full.major,'%0.1f') '; min=' num2str(full.minor,'%0.1f')]);
		end
		if plotTight && firstRow, title('Ellipses'); end

	pn=pn+1; %subplot(loc.nr,loc.nc,loc.base+pn);
	if ~plotTight, subplot(loc.nr,loc.nc,loc.base+pn);
		else subplot('position',[xb yb tightw+loc.rosew tighth]); end
		hold on;
		rose2(-rang(:)*pi/180, 24, [1 0 0]);
		if plotTight,
			axis off; axis equal;
			alim=1.05*loc.AngLim*[-1 1]; ylim(alim); xlim(alim);
			set(gca,'Position',[xb+loc.rosew/2 yb tightw tighth])
			eprop.Centroid=[0 0]; eprop.MajorAxisLength=loc.AngLim*2;
				eprop.MinorAxisLength=eprop.MajorAxisLength; eprop.Orientation=0;
			DrawEllipse(eprop,'k:',50);
			xb=xb+tightw+loc.rosew; end
		if ~showFullEllipse,
			myscale=loc.AngLim*0.5/loc.MajAxLim(2);
			eprop.Centroid=[0 0]; eprop.MajorAxisLength=full.major*2*myscale;
				eprop.MinorAxisLength=full.minor*2*myscale; eprop.Orientation=-full.ang;
			h=DrawEllipse(eprop,'b-',50);
			set(h,'LineWidth',2);
		end
		if plotTight && firstRow, title('Angles'); end

	if plotTight,
		subplot('position',[xb yb tightw*1.2 tighth]); %negate angle since axis ij
		set(gca,'visible','off');
		x=loc.text(1); y=loc.text(2); dy=loc.text(3);
		text(x, y, ['ang=' num2str(-full.ang,'%.0f') '; anis=' num2str(full.anis,'%0.1f')]);
		y=y-dy;
		text(x, y, ['maj=' num2str(full.major,'%0.1f') '; min=' num2str(full.minor,'%0.1f')]);
		y=y-dy;
		text(x, y, ['Lims: ell=' num2str(loc.MajAxLim(2)*1.05/.9,'%0.1f') '; rose=' num2str(loc.AngLim*1.05,'%0.1f') ]);
		if plotTight && firstRow, text(x, 1.12,'Full Field'); end
	end

end

