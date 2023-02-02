%make Fig summarizing cs vs squares using DoTileCList (pairwise correlation
%	between stains).
% must run DoTileMany first (applies DoTile2 to *.mat files from DoTile) 
function analy=DoTileCListFig(crList, FBList, bySetFlag)
if nargin<3, bySetFlag=0; end
if nargin<2, FBList={'Ful','Sq1','Rec2','Rec3'}; end
if nargin<1 || isempty(crList),
	pn='E:\DeskTop2\Collab\Romer\Janna 15_0513';
	pn=[pn '\'];
	load([pn 'crList.mat']);
end

close all;
showAng=1; acnt=0; froot='TSizeCorr'; figType=0; pn=[crList(end).dname '\'];
for i=1:numel(FBList),
	fbl=[]; fblab='';
	if ischar(FBList{i}), fblab=FBList{i}; fbl=getBoxSet(fblab);
	elseif isnumeric(FBList{i}), fbl=FBList{i}; fblab=['Set' int2str(i)]; end
	if ~isempty(fbl),
		if bySetFlag, %Ave the set
			a=DoTileCAve(crList,fbl,showAng);
			acnt=acnt+1; analy{acnt}=a;
			currDir=cd(pn); h=1; %h=gcf; if showAng, h=h-1; end
			figure(h); prFig([froot ',' fblab ',Anis'], figType);
			if showAng, figure(h+1); prFig([froot ',' fblab ',Ang'], figType); end
			cd(currDir);
		else %individually
			for j=1:numel(fbl),
			a=DoTileCAve(crList,fbl(j),showAng);
			acnt=acnt+1; analy{acnt}=a;
			currDir=cd(pn); h=1; %h=gcf; if showAng, h=h-1; end
			figure(h); prFig([fileroot(a(1).flist{1}) ',TSCorr,Anis'], figType);
			if showAng, figure(h+1); prFig([fileroot(a(1).flist{1}) ',TSCorr,Ang'], figType); end
			cd(currDir);
			end
		end
	end
end

if nargout<1, clear analy; end

	function fbi=getBoxSet(bxn)
		ncr=numel(crList);
		if nargin<1 || isempty(bxn) || strcmpi(bxn,'all'),
			fbi=1:ncr; return; end
		fbi=[];
		for i=1:ncr,
			if strcmpi(crList(i).boxname,bxn),
				fbi=[fbi i]; end
		end
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