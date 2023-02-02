% DoTileOpts has options for DoTileMany, which does all ACTile/Corr
% analyses and plots
%
% SCK 17_1114 modified for 1-channel TIFs, suppress well-shapes (Qianru)
% SCK 15_0604

function DTopts=DoTileOpts()
%===Specify Dirs/Files===
	DTopts.flist = DirFiles(); %see below; currently 19 files
	%DTopts.outDir=DTopts.flist(end).pname; %where to save crList (DoTile2); originally save in last Dir of list

%===DoAnis===(for testing & comparing)
	DTopts.exeDoAnis=0; %execute DoAnis on fileset; 0=off

%===DoTile===
	DTopts.exeDoTile=1; %execute DoTile; 0=off
		DTopts.opts=DoAnisOpts(); %1-channel RGB, 17_1114
		DTopts.opts.fullimage=1;
		DTopts.tsize=[50 75 100 125 150 200];
        DTopts.opts.LSMmedfilt=[1]; %LSM ch to apply median filter, in order of analysis
		DTopts.exeShowTile=0; %prevent duplication of ShowTile (see below)
%DTopts.tsize=150; %testing

%===DoTile2===
	DTopts.exeDoTile2=0; %execute DoTile2 (correlations between stains)
		DTopts.DT2savecrList=1;

%===ShowTile===
	DTopts.exeShowTile2=1; %execute ShowTile
		DTopts.showsetnum=[3 4]; %show sets (tsize=100,125)
		DTopts.saveFig=1;
		DTopts.figType=0; %PDF/AI=0; EPS/AI=1

%===TileTable===
	DTopts.exeTileTable=0; %export Tile data as text for Excel
		DTopts.XLSsetnum=3; %export sets 3&4 (tsize=75,100)
		DTopts.saveXLSfile=1;
		DTopts.eraseXLSfile=0; %clobber if exists; appends otherwise

%===ShowTileDistr===
	DTopts.exeShowTileDistr=0; %execute ShowTileDistr (Box-Whiskers)

%===ShowTileCorr===
		%exe ???, part of DoTile2 (show Tile Anis betw stains)
		%which TSizes

%===DoTileClist===
	DTopts.exeDoTileCList=0; %execute DoTileCList (show AVE correlation between stains vs TSize)
		%DTopts.TSCorrGrp={'Ful','Sq1','Rec2','Rec3','ALL'};
		DTopts.TS_FBList={'Ful','Sq1','Rec2','Rec3'};
		DTopts.TSCbySet=1;

end

function [flist]=DirFiles() %specify source of images: directories & files
%specify dirs/files
i=0;

%FULL Coverslips
pn='E:\Gracias Lab\Romer\Matlab\0905_Ctrl_S1';
pn=[pn '\'];
i=i+1; flist(i).fname='actin_1.tif';
	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
i=i+1; flist(i).fname='actin_2.tif';
	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};


end
