function analy=DoTileCList(crList, flist, showAng, dumpData)
% show averaged stain-correlation of multiple files calculated by DoTileMany
%   (which applies DoTile2 to *.mat files from DoTile)
%	which saves the data in crList.
% analy=DoTileCList(crList, flist, showAng) will aggreg/average according
%   flist
%
% 15_0506 SCK
if nargin<4, dumpData=0; end
if nargin<3, showAng=0; end
if nargin<2 || isempty(flist), flist=[]; end
if nargin<1 || isempty(crList),
    [crList, pname] = uigetfile('*.mat;', 'Analysis to Load');
	if isequal(crList,0) || isequal(pname,0), return; end %user cancelled
end
fcn='DoTileList';

if ischar(crList), 
	load([pname crList]);
	if exist('crList','var') ~= 1,
		disp('File does not contain corrTile (DoTileMany) information.  Exiting.');
		return;
	end
end

if isempty(flist),
	nfile=numel(crList); flist=1:nfile;
else nfile=numel(crList); idx=(flist<=nfile); flist=flist(idx);
	nfile=numel(flist); end
tc=sprintf('\t');
dname=crList(end).dname;

if dumpData,
	% diary([dname '\crList.txt');

	disp(['F#' tc 'FileName' tc 'DirName' tc 'ImSize' tc 'Scale' tc 'Shape' tc 'Chan' tc 'Anis' tc 'Ang' tc 'Major' tc 'Anis2' tc 'Ang2' tc 'Major2']);
	for i=1:nfile, %file#
		cr=crList(flist(i));
		for j=1:4, full=cr.full(j);
		disp([int2str(i) tc cr.fname tc cr.dname tc int2str(cr.scale.imsize) tc num2str([cr.scale.x cr.scale.y]) ...
			tc cr.boxname tc full.imname tc num2str(full.anis) tc num2str(full.ang) tc num2str(full.major) tc num2str(full.anis2) tc num2str(full.ang2) ...
			tc num2str(full.major2)]);
		end
	end
end

cr0=crList(1);
nfld=numel(cr0.crGrid); tscnt=size(cr0.crGrid(1).corr,3);
for m=1:nfld, %fields
	ar.fld=cr0.crGrid(m).corr{1,1,1}.fld;
	for k=1:3, %yname
		for j=1:k, %xname
	cr=cr0.crGrid(m).corr{j,k,1};
% 	disp(['====field=' cr.fld '; x=' cr.xname '; y=' cr.yname]);
	ar.xname=cr.xname; ar.yname=cr.yname;
	arr=zeros(nfile,tscnt); arts=zeros(1,tscnt); arn=zeros(nfile,tscnt);
% 	disp(['TileSize' tc 'F#' tc 'r']);
			for ts=1:tscnt, %tile sizes
				for i=1:nfile, %file#
	crd=crList(flist(i)).crGrid(m).corr{j,k,ts};
% 	disp([int2str(crd.tsize) tc int2str(i) tc num2str(crd.r)]);
	arts(ts)=crd.tsize;	arr(i,ts)=crd.r; arn(i,ts)=crd.n;
				end
			end
	ar.r=arr; ar.meanr=mean(arr,1); ar.stdr=std(arr,0,1);
	arr2=arr .* arr; ar.meanr2=mean(arr2,1); ar.stdr2=std(arr2,0,1);
	ar.n=arn; ar.meann=mean(arn,1);
	ar.tsize=arts;
	arGrid(j,k)=ar;
		end
	end
	fl={}; for i=1:nfile, fl{i}=crList(flist(i)).fname; end
	analy(m).fld=ar.fld; analy(m).flist=fl;	analy(m).ar=arGrid;
end
if dumpData, diary off; end

np=1; if showAng, np=2; end
for m=1:np,
	bigfigure([],1);
	for k=1:3, for j=1:k,
		subplot(3,3,(k-1)*3+j);
		an=analy(m).ar(j,k);
		an2=analy(m+2).ar(j,k);
		%sem=an.stdr ./ sqrt(size(an.r,2)); 
				if 0,
				errorbar(an.tsize, an.meanr2, an.stdr2, 'bo'); hold on;
		%		errorbar(an2.tsize, an2.meanr2, an2.stdr2, 'r^');
		%		title([an.fld ',' an2.fld ':' an.xname ',' an.yname]);
				title([an.fld ':' an.xname ',' an.yname]);
				ylim([0 1.1]); xlabel('TileSize (pix)'); ylabel('Pearson r^2');
				else
				errorbar(an.tsize, an.meanr, an.stdr, 'bo'); hold on;
				title([an.fld ':' an.xname ',' an.yname]);
				ylim([0 1.1]); xlabel('TileSize (pix)'); ylabel('Pearson r');
				end
		end
	end
	subplot(3,3,2);
	set(gca,'visible','off');
	x=0.05; y=0.9; dy=0.1;
	for j=1:nfile,
		cr=crList(flist(j));
		text(x, y, [cr.fname '; ' cr.boxname]);
		y=y-dy;
	end
	if nfile==1,
		cr=crList(flist(1)); y=y-dy;
		for j=1:4, full=cr.full(j);
		a=[full.imname ': anis=' num2str(full.anis,2) ', ' num2str(full.ang,2) ...
			'd, maj,min:' num2str(full.major,2) ', ' num2str(full.minor,2) 'pix; ang2=' ...
			num2str(full.ang2,2) 'd; maj2=' num2str(full.major2,2) 'pix' ];
			text(x, y, a);
			y=y-dy;
		end
	end
end
end
