%make Fig summarizing cs vs squares using DoTileCList (pairwise correlation
%	between stains).
% must run DoTileMany first (applies DoTile2 to *.mat files from DoTile) 
function analy=DoTileCListFig(crList, bySetFlag)
if nargin<2, bySetFlag=1; end
pn='E:\DeskTop2\Collab\Romer\Janna 15_0513';
pn=[pn '\'];
load([pn 'crList.mat']);

close all;
if bySetFlag, %coverslip vs square
	a=DoTileCList(crList,(1:8),1);
	analy{1}=a;
	a=DoTileCList(crList,(9:13),1);
	analy{2}=a;
	a=DoTileCList(crList,(14:2:24),1);
	analy{3}=a;
	a=DoTileCList(crList,(15:2:25),1);
	analy{4}=a;
else %individual
	for i=1:numel(crList), a=DoTileCList(crList,i); analy{i}=a;
		currDir=cd(pn);
		prFig([fileroot(a(1).flist{1}) ',TSCorr'], 0);
		cd(currDir);
	end
end

if bySetFlag,
	froot='TSizeCorr'; figType=0;
	currDir=cd(pn);
	figure(1); prFig([froot ',cs,Anis'], figType);
	figure(2); prFig([froot ',cs,Ang'], figType);
	figure(3); prFig([froot ',sq,Anis'], figType);
	figure(4); prFig([froot ',sq,Ang'], figType);
	figure(5); prFig([froot ',rc2,Anis'], figType);
	figure(6); prFig([froot ',rc2,Ang'], figType);
	figure(7); prFig([froot ',rc3,Anis'], figType);
	figure(8); prFig([froot ',rc3,Ang'], figType);
	cd(currDir);
end

end

function prFig(froot, figType)
	if figType, %1=epsc
		print([froot '.eps'],'-painters','-depsc');
	else %0=pdf
		print([froot '.pdf'],'-painters','-dpdf');
	end
end

function fr=fileroot(str)
	[~,fr,ex]=fileparts(str);
end