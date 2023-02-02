% DoTileMany automates processing the multiple files as specified by DTopts
% Note: crList is saved in the last directory of the hard-coded list.
%	Other files are saved in the same directory as the lsm image in this
%	list.
%
% crList=DoTileMany(DTopts)
%	flist(1)<0 (default) skips DoTile (slow) to do DoTile2; can specify list
%		for DoTile2 (will make abs; only first neg to suppress DoTile);
%		=[] do all files
%
% SCK 15_0504

function crList=DoTileMany(flistInd, DTopts)
if nargin<2 || isempty(DTopts), DTopts=DoTileOpts(); end
if nargin<1, flistInd=[]; end %Do all files

tstart=tic;
if isempty(flistInd),  %do all files
	nf=numel(DTopts.flist); flistInd=(1:nf); end

if DTopts.exeDoAnis,
	DoAnisList(flistInd); %see below
	tstep1=toc(tstart);	disp(['+++ Elapsed subtime: ' sec2str(tstep1)]);
end

if DTopts.exeDoTile,
	DoTileList(flistInd); %see below
	tstep1=toc(tstart);	disp(['+++ Elapsed subtime: ' sec2str(tstep1)]);
end

if DTopts.exeShowTile2,
	DoShowList(flistInd);
	tstep1=toc(tstart);	disp(['+++ Elapsed subtime: ' sec2str(tstep1)]);
end

if DTopts.exeTileTable,
	DoTileTableList(flistInd);
	tstep1=toc(tstart);	disp(['+++ Elapsed subtime: ' sec2str(tstep1)]);
end

crList=[];
if DTopts.exeDoTile2,
	crList=DoTile2List(flistInd);
	if DTopts.DT2savecrList,
		currDir=cd(DTopts.flist(end).pname);
		save('crList.mat','crList');
		cd(currDir);
	end
	tstep2=toc(tstart);	disp(['+++ Elapsed subtime: ' sec2str(tstep2)]);
end

if DTopts.exeDoTileCList,
	if isempty(crList),
		currDir=cd(DTopts.flist(end).pname);
		load('crList.mat');
		cd(currDir);
	end
	DoTileCAList(crList, DTopts.TS_FBList, DTopts.TSCbySet);
	tstep2=toc(tstart);	disp(['+++ Elapsed subtime: ' sec2str(tstep2)]);
end

if nargout<1, clear crList; end
tstep3=toc(tstart); disp(['+++ TOTAL elapsed time: ' sec2str(tstep3)]);

%======Internal Functions========
	function DoAnisList(fnInd)
	nf=numel(fnInd);
		for i=1:nf,
			opts=DTopts.opts;
			if isempty(DTopts.flist(fnInd(i)).boxlist), opts.fullimage=1; end
			DoAnis(DTopts.flist(fnInd(i)).fname, opts, DTopts.flist(fnInd(i)).pname, ...
				DTopts.flist(fnInd(i)).boxlist);
		end
	end

	function DoTileList(fnInd)
	nf=numel(fnInd);
		for i=1:nf,
			disp(['=====' int2str(i) '/' int2str(nf) ':' DTopts.flist(fnInd(i)).fname '; t=' sec2str(toc(tstart)) ]);
			DoTile(DTopts.flist(fnInd(i)), DTopts, DTopts.tsize);
			close all;
		end
	end

	function DoShowList(fnInd)
	nf=numel(fnInd);
		for i=1:nf,
			disp(['=====' int2str(i) '/' int2str(nf) ':' DTopts.flist(fnInd(i)).fname '; t=' sec2str(toc(tstart)) ]);
			[~,tf,~]=fileparts(DTopts.flist(fnInd(i)).fname);
			bnames=DTopts.flist(fnInd(i)).boxnames; nBx=numel(bnames);
			for k=1:nBx,
				DoShow0([DTopts.flist(fnInd(i)).pname tf '_' bnames{k} '.mat'], DTopts);
			end
		end
	end

	function DoTileTableList(fnInd)
	nf=numel(fnInd);
		for i=1:nf,
			disp(['=====' int2str(i) '/' int2str(nf) ':' DTopts.flist(fnInd(i)).fname '; t=' sec2str(toc(tstart)) ]);
			[~,tf,~]=fileparts(DTopts.flist(fnInd(i)).fname);
			bnames=DTopts.flist(fnInd(i)).boxnames; nBx=numel(bnames);
			for k=1:nBx,
				TileTable([DTopts.flist(fnInd(i)).pname tf '_' bnames{k} '.mat'], DTopts);
			end
		end
	end

	function crList=DoTile2List(fnInd)
	nf=numel(fnInd); cnt=0; subD='ThreshM50,noMedFilt\';
		for i=1:nf,
			disp(['=====' int2str(i) '/' int2str(nf) ':' DTopts.flist(fnInd(i)).fname '; t=' sec2str(toc(tstart)) ]);
			[~,tf,~]=fileparts(DTopts.flist(fnInd(i)).fname);
			bnames=DTopts.flist(fnInd(i)).boxnames; nBx=numel(bnames);
			for k=1:nBx,
				load([DTopts.flist(fnInd(i)).pname tf '_' bnames{k} '.mat']);
				MFimgs=imgs; %results after medfilt images
				load([DTopts.flist(fnInd(i)).pname subD tf '_' bnames{k} '.mat']);
				imgs=swapMFdat(imgs,MFimgs,[4]);

				[imgs,crGrid]=DoTile2(imgs, [], 0);
				cr.fname=imgs.fname;
				cr.dname=imgs.pname(1:(numel(imgs.pname)-1));
				for j=1:4, full=imgs.acGrid{1,j}.full;
% %quick & dirty fix; already fixed in ACTile...
% if isnan(full.major), full2.major=NaN; full2.minor=NaN; full2.anis=NaN; full2.ang=NaN;
% 	full2.major2=NaN; full2.minor2=NaN; full2.anis2=NaN; full2.ang2=NaN; full=full2; end
					full.imname=imgs.imname{j}; cr.full(j)=full; end
				scale=imgs.scale; scale.imsize=size(imgs.im{1});
				cr.scale=scale;
				cr.boxname=bnames{k};
				cr.crGrid=crGrid;
				cnt=cnt+1; crList(cnt)=cr;
			end
		end
	end

end

function [imgs]=swapMFdat(imgs, MFimgs, chans)
	if nargin<3, chans=[4]; end
	acsz=size(imgs.acGrid); acG0=imgs.acGrid; acGmf=MFimgs.acGrid;
	for i3=1:numel(chans),
		for j3=1:acsz(1),
			acG0{j3,chans(i3)}=acGmf{j3,chans(i3)};
		end
		imgs.imname{chans(i3)}=[imgs.imname{chans(i3)} 'mf'];
	end
	imgs.acGrid=acG0;
end

function DoShow0(fn, DTopts)
	load(fn); %problem with static space; can't do as nested function like DoTile2List...
	ShowTile(imgs, DTopts.showsetnum, 1, DTopts.saveFig); %tight layout
end
