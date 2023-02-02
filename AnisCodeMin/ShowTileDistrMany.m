function crList=DoTileMany
%Using ShowTileDistr, show the results of DoTile/ACTile (same driver list
%as DoTileMany) as box-whisker plots of metrics as function of tile size.
%
% 15_0508 SCK (should have written this before the inter-stain
% correlations)

%saveFig=0; %don't save any figs
	saveFig=1; replaceFig=1;
figType=0; %PDF=0; EPS/AI=1

i=0;
%FULL CS
pn='E:\DeskTop2\Collab\Romer\Janna 15_0421';
pn=[pn '\'];
i=i+1; fname{i}='D1 WI38 10X 1.lsm';
	pname{i}=pn;
i=i+1; fname{i}='D1 WI38 10X 3.lsm';
	pname{i}=pn;
i=i+1; fname{i}='Rep 2 D1 WI38 10X 1.lsm';
	pname{i}=pn;
i=i+1; fname{i}='Rep 3 D1 WI38 10X 2.lsm';
	pname{i}=pn;

pn='E:\DeskTop2\Collab\Romer\Janna 15_0430';
pn=[pn '\'];
i=i+1; fname{i}='D1 WI38 10X 5.lsm';
    pname{i}=pn;
i=i+1; fname{i}='Rep 2 D1 WI38 10X 3.lsm';
    pname{i}=pn;

pn='E:\DeskTop2\Collab\Romer\Janna 15_0506';
pn=[pn '\'];
i=i+1; fname{i}='D1 WI38 10X 2.lsm';
    pname{i}=pn;
i=i+1; fname{i}='Rep 3 D1 WI38 10X 5.lsm';
    pname{i}=pn;

% SQUARES
% pn='E:\DeskTop2\Collab\Romer\Janna 15_0213';
% pn=[pn '\'];
% i=i+1; fname{i}='Exp 1 D1 control sq1 10X 2.lsm';
% 	pname{i}=pn; %DUPLICATE!

pn='E:\DeskTop2\Collab\Romer\Janna 15_0501';
pn=[pn '\'];
i=i+1; fname{i}='Exp 1 D1 control sq1 10X 2.lsm';
    pname{i}=pn;
i=i+1; fname{i}='Exp 2 D1 C sq1 10X 3.lsm';
    pname{i}=pn;
i=i+1; fname{i}='Exp 3 D1 C sq1 10X 3.lsm';
    pname{i}=pn;
i=i+1; fname{i}='Exp 3 D1 control sq1 10X 5.lsm';
    pname{i}=pn;
i=i+1; fname{i}='Exp R3 D1 C sq1 10X 3.lsm';
    pname{i}=pn;

nf=numel(fname);
for i=1:nf,
	disp(['=====' int2str(i) '/' int2str(nf) ':' fname{i}]);
	[~,tf,~]=fileparts(fname{i});
	load([pname{i} tf '.mat']);
	[imgs]=ShowTileDistr(imgs, saveFig, replaceFig);
end

end

