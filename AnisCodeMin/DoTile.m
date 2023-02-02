%DOTILE Analyze an image in ACTile/'tiles' for anisotropy (pre-set list of tile sizes)
%   imgs=DoTile(fname, DTopts, pname, tsize)
%
% SK 15_0420-15_0504

function imgs=DoTile(finfo, DTopts, tsize)
if nargin<3, tsize=150; end
if nargin<2 || isempty(DTopts), DTopts=DoTileOpts(); end
if nargin<1 || isempty(finfo),
    [fname, pname] = uigetfile('*.tif;*.jpg;*.tiff;*.jpeg;*.lsm;', 'Image to Process');
	if isequal(fname,0) || isequal(pname,0), imgs=[]; return; end %user cancelled
	finfo.fname=fname; finfo.pname=pname;
	finfo.boxlist=[]; finfo.boxnames={'Ful'};
	%finfo.boxlist=[1]; finfo.boxnames={'Def'};
end
fcn='DoTile';
opts=DTopts.opts; %setnum=DTopts.showsetnum; figType=DTopts.figType;

anisOut2=ImReadS(finfo.fname, opts, finfo.pname);
if isempty(anisOut2), return; end %user cancelled
%froot=anisOut2.froot; dname=anisOut2.pname(1:(numel(anisOut2.pname)-1));
imgs.fname=anisOut2.fname; imgs.froot=anisOut2.froot; imgs.pname=anisOut2.pname;
imgs.scale=anisOut2.scale;

if isempty(finfo.boxlist),
	boxlist=[1]; boxnames={'Ful'}; imsz=size(anisOut2.im{1});
	s(1).BoundingBox=[1 1 imsz(2) imsz(1)];
else
	boxlist=finfo.boxlist; boxnames=finfo.boxnames;
	anisOut2.wells=FindWells(anisOut2.wellsim,opts.wellslimit);
	s=anisOut2.wells.s;
end

nCh=numel(anisOut2.im); nBx=numel(boxlist); nTs=numel(tsize);
close all;
for i=1:nBx, %boxnum
	bb=s(boxlist(i)).BoundingBox;
	bb=round(bb); %edges sometimes 0.5! round up to use as index and reduce widths by 1
	for m=1:nCh, %channel
		im=anisOut2.im{m};
		imgs.im{m}=im(bb(2):(bb(2)+bb(4)-1),bb(1):(bb(1)+bb(3)-1));
		imgs.imname{m}=anisOut2.imname{m};
		imgs.boxname{m}=boxnames{i};
    end
    if isfield(anisOut2,'medfilt'), imgs.medfilt=anisOut2.medfilt; end

	for m=1:nCh, %calc ACTile for each channel of image
		disp(['==Analyzing Bx' int2str(i) '/' int2str(nBx) ', Ch' int2str(m) '/' int2str(nCh) ':' imgs.imname{m} ]);
		for j=1:nTs,
			disp(['...tilesize(' int2str(j) '/' int2str(nTs) '): ' int2str(tsize(j))]);
			imgs.acGrid{j,m}=ACTile(imgs.im{m}, tsize(j));
		end
	end
	
	ofn=strrep(imgs.froot,'%',''); %remove bad chars for filename: %
	dname=imgs.pname(1:(numel(imgs.pname)-1));
	currDir=cd(dname);
	save([ofn '_' boxnames{i} '.mat'],'imgs');
	cd(currDir);

	if DTopts.exeShowTile,
		ShowTile(imgs, DTopts.showsetnum, 1, DTopts.saveFig); %tight layout
	end

end


if nargout<1, clear imgs; end
end
