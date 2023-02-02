% DoTileMany automates processing the multiple files as specified by DTopts
%
% SCK 17_1115 modified for Qianru (deleted modules, added TileTable()
% SCK 15_0504

function DoTileMany(flistInd, DTopts)
if nargin<2 || isempty(DTopts), DTopts=DoTileOpts(); end
if nargin<1, flistInd=[]; end %Do all files

tstart=tic;
if isempty(flistInd),  %do all files
	nf=numel(DTopts.flist); flistInd=(1:nf); end

if DTopts.exeDoTile,
	DoTileList(flistInd); %see internal function below
	tstep1=toc(tstart);	disp(['+++ Elapsed subtime: ' sec2str(tstep1)]);
end

if DTopts.exeShowTile,
	DoShowList(flistInd); %see internal function below
	tstep1=toc(tstart);	disp(['+++ Elapsed subtime: ' sec2str(tstep1)]);
end

if DTopts.exeTileTable,
	DoTileTableList(flistInd); %see internal function below
	tstep1=toc(tstart);	disp(['+++ Elapsed subtime: ' sec2str(tstep1)]);
end

%-----------------QJ added: quantile dist-------
% if DTopts.exeTileTableDist,
% 	DoTileTableListDist(flistInd); %see internal function below
% 	tstep1=toc(tstart);	disp(['+++ Elapsed subtime: ' sec2str(tstep1)]);
% end
%-----------------QJ added: quantile dist-------

tstep3=toc(tstart); disp(['+++ TOTAL elapsed time: ' sec2str(tstep3)]);

%======Internal Functions========
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
			for k=1:nBx, %see function below
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
			for k=1:nBx, %see function below
				DoTileTable0([DTopts.flist(fnInd(i)).pname tf '_' bnames{k} '.mat'], DTopts);
			end
		end
    end
    %%%-----------------QJ added: quantile dist-------
% 	function DoTileTableListDist(fnInd)
% 	nf=numel(fnInd);
% 		for i=1:nf,
% 			disp(['=====' int2str(i) '/' int2str(nf) ':' DTopts.flist(fnInd(i)).fname '; t=' sec2str(toc(tstart)) ]);
% 			[~,tf,~]=fileparts(DTopts.flist(fnInd(i)).fname);
% 			bnames=DTopts.flist(fnInd(i)).boxnames; nBx=numel(bnames);
% 			for k=1:nBx, %see function below
% 				DoTileTableDist0([DTopts.flist(fnInd(i)).pname tf '_' bnames{k} '.mat'], DTopts);
% 			end
% 		end
%     end
   %%%-----------------QJ added: quantile dist-------
end

function DoShow0(fn, DTopts)
	load(fn); %problem with static space; can't do as nested function like DoTile2List...
	ShowTile(imgs, DTopts.showsetnum, 1, DTopts.saveFig, DTopts.figType, DTopts.replaceFig); %tight layout
end

function DoTileTable0(fn, DTopts)
	load(fn); %problem with static space; can't do as nested function like DoTile2List...
	TileTable(imgs, DTopts.XLSsetnum, DTopts);
end

%%%-----------------QJ added: quantile dist-------
% function DoTileTableDist0(fn, DTopts)
% 	load(fn); %problem with static space; can't do as nested function like DoTile2List...
% 	TileTableDist(imgs, DTopts.XLSsetnumDist, DTopts);
% end
%%%-----------------QJ added: quantile dist-------