% DoTileOpts has options for DoTileMany, which does all ACTile/Corr
% analyses and plots
%
% SCK 17_1114 modified for 1-channel TIFs, suppress well-shapes (Qianru)
% SCK 15_0604

function DTopts=DoTileOpts()
%===Specify Dirs/Files===
	DTopts.flist = DirFiles([3 11]); %see below; currently 19 files
	%DTopts.outDir=DTopts.flist(end).pname; %where to save crList (DoTile2); originally save in last Dir of list

%===DoTile===
	DTopts.exeDoTile=1; %execute DoTile; 0=off
		DTopts.opts=DoAnisOpts(); %1-channel RGB, 17_1114
		DTopts.opts.fullimage=1;
		%DTopts.tsize=[25 75 100 125 150 200];
        %DTopts.tsize=[50 75 100 125 150 200];
        DTopts.tsize=[75]
        DTopts.opts.LSMmedfilt=[1]; %LSM ch to apply median filter, in order of analysis
		DTopts.DT_ShowTile=0; %prevent duplication of ShowTile (see below)

%===ShowTile===
	DTopts.exeShowTile=1; %execute ShowTile
		DTopts.showsetnum=[1]; %show sets ([3 4] means tsize=100,125); empty means all sets
		DTopts.saveFig=1;
		DTopts.figType=0; %PDF/AI=0; EPS/AI=1
		DTopts.replaceFig=0; %re-use fig window

%===TileTable===
	DTopts.exeTileTable=1; %export Tile data as text for Excel
		DTopts.XLSsetnum=[1]; %export sets ([3 4] means tsize=100,125); empty means all sets; [0] means Full only
		DTopts.XLSsavefile=1; %save screen disp as file (using diary())
		DTopts.XLSgridstats=0; %summarize tiles statistically (else list each tile)
		DTopts.XLSshowdir=0; %dump dir information (good if multiple dirs)
		DTopts.XLSerasefile=0; %clobber if exists; appends otherwise
 
%%%-----------------QJ added: quantile dist-------
%===TileTableDist===
% 	DTopts.exeTileTableDist=0; %export Tile data as text for Excel
% 		DTopts.XLSsetnum=[6]; %export sets ([3 4] means tsize=100,125); empty means all sets; [0] means Full only
% 		DTopts.XLSsavefile=1; %save screen disp as file (using diary())
% 		DTopts.XLSgridstats=1; %summarize tiles statistically (else list each tile)
% 		DTopts.XLSshowdir=0; %dump dir information (good if multiple dirs)
% 		DTopts.XLSerasefile=0; %clobber if exists; appends otherwise
%%%-----------------QJ added: quantile dist-------

end

function [flist]=DirFiles(fn) %specify source of images: directories & files
if nargin<1,fn=[];end %default=all specified
%specify dirs/files
i=0;

%Emkd
pn='C:\Research\Gracias Lab\2_Romer\Matlab\Fig3 actin orientation analysis\Exp1_09052017_dense\0_2022 SI verify';
pn=[pn '\'];
i=i+1; flist(i).fname='T00001C02Z001.tif';
	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='20 control 10x 3b CY5.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='20 control 10x 7b CY5.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='20 control 10x 11b CY5.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='20 control 10x 13b CY5.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='20 stretch 10x #1 1b CY5.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='20 stretch 10x #1 3b CY5.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='20 stretch 10x #1 7b CY5.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='20 stretch 10x #1 11b CY5.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='20 stretch 10x #1 13b CY5.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='20 stretch 10x #2 3 CY5.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='20 stretch 10x #2 7b CY5.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='20 stretch 10x #2 11b CY5.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='20 stretch 10x #2 13b CY5.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='15 stretch 10x #2 13 CY5.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};

% %Ctrl
% pn='E:\Gracias Lab\Romer\Matlab\09052017_Exp\0905_Ctrl_S1';
% pn=[pn '\'];
% i=i+1; flist(i).fname='actin_1.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='actin_2.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='actin_3.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='actin_4.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='actin_5.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='actin_6.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='actin_7.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='actin_8.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='actin_9.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='actin_10.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='actin_11.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='actin_12.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='actin_13.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='actin_14.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% i=i+1; flist(i).fname='actin_15.tif';
% 	flist(i).pname=pn; flist(i).boxlist=[]; flist(i).boxnames={'Ful'};
% % if ~isempty(fn), flist=flist(fn); end %subset specified
end
