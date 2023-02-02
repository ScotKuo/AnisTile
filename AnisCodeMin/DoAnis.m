function anisOut=DoAnis(fname, opts, pname, boxlist)
%DOANIS Perform semi-automated anisotropy analysis of fluorescence image
%	opt=input options for analysis; see DoAnisOpts for definitions
%	pname=path to getting to file (parent directory)
%	boxlist=array of idnums of boxes to analyze; empty list means all boxes
%	anisOut=results of all analysis info
%		anisOut.anis(j) state flags: fullimage, wellID, boundingbox,
%		scramble
% SCK 14_0125-14_0301
% SCK 14_0326: made verbose more consistent; extracted scale from lsm
%	NOTE: made scale=-1 as default...

aa=get(0,'Diary'); if strcmpi(aa,'on'), diary off; end %just in case
if nargin<4, boxlist=[]; end
if nargin<3, pname=''; end
if nargin<2 || isempty(opts), opts=DoAnisOpts; end
if nargin<1, fname=''; end
anisOut = ImReadS(fname, opts, pname);
if isempty(anisOut), return; end %user cancelled

if opts.fullimage, nbb=1; boxlist=1;
	anisOut.wells=FindWells(anisOut.wellsim,-1);
else
	anisOut.wells=FindWells(anisOut.wellsim,opts.wellslimit);
	anisOut=rmfield(anisOut,'wellsim'); %big, no longer needed
	nbb=numel(anisOut.wells.s);
end

if isempty(boxlist), boxlist=[1:nbb]; end
boxlist=boxlist(boxlist<=nbb); %eliminate any indices>nbb
froot=anisOut.froot; dname=anisOut.pname(1:(numel(anisOut.pname)-1));
anisOut.anis=[];

for i=1:numel(anisOut.im),
	anis=DoBoxes(anisOut.im{i}, anisOut.wells.s, boxlist, opts, ...
		anisOut.imname{i}, froot, dname);
	if isempty(anisOut.anis), anisOut.anis=anis;
	else anisOut.anis=[anisOut.anis anis]; end
end

anisOut=rmfield(anisOut,'im'); %big, no longer needed
anisOut=rmfield(anisOut,'imname');

drawnow; commandwindow;
%here to save info in opts.outfile
% if numel(immag)==0, anisOut.asort=asort2(anisOut, opts); end
AnisTable(anisOut, opts);
if nargout<1, clear anisOut; end
end

function anis=DoBoxes(im, s, boxlist, opts, imname, froot, dname)
	ws.max=max(im(:)); ws.min=min(im(:)); anis=[]; atmp=[];
	if ws.max==ws.min,
		disp(['===SKIPPING===DoAnis:DoBoxes: No image for ' imname ' of ' froot]);
		return
	end
	nbl=numel(boxlist);
	for i=1:nbl,
		clear atmp;
		atmp.imname=imname; ftitle=[froot ', ' imname ':Full'];
		atmp.err.code=0; atmp.err.msg='';
		if opts.fullimage, im2=im; bb=[]; sz=size(im);
			atmp.fullimage=1; atmp.wellID=1; atmp.wellOrient=[];
			atmp.boundingbox=[1 1 sz(1) sz(2)]; atmp.Shape='Full';
		else
			bb=s(boxlist(i)).BoundingBox;
			bb=round(bb); %edges sometimes 0.5! round up to use as index and reduce widths by 1
			atmp.fullimage=0; atmp.wellID=boxlist(i); atmp.boundingbox=bb;
			atmp.wellOrient=s(boxlist(i)).Orientation;
			ftitle=[froot ', ' imname ':WellID#' int2str(boxlist(i))];
			im2=im(bb(2):(bb(2)+bb(4)-1),bb(1):(bb(1)+bb(3)-1));
			disp(['===' froot '===']);
			disp([imname ': WellID#' int2str(boxlist(i)) ' (' int2str(i) '/' int2str(nbl) '): [' int2str(bb) ']']);
		end
		% Scramble/shuffle image (check prediction for uncorrelated stochastic):
		atmp.scramble=0;
		if opts.scramble,
			t=reshape(im2(randperm(numel(im2))), size(im2));
			im2=t; atmp.scramble=1;
		end

		if opts.acnorm, [atmp.ac, atmp.acstat]= imAutoCorr(im2,3);
		else [atmp.ac, atmp.acstat]= imAutoCorr(im2,0); end
		listflag=opts.verbose;
		if opts.valTableOnly, listflag=0; end

		atmp.anisOne= ACAnisSingle(atmp.ac, listflag);
		if atmp.anisOne.err.code,
			disp([atmp.anisOne.err.msg 'for "' froot '", Well#' int2str(boxlist(i))]);
			atmp.err.code=bitor(atmp.err.code, 2);
			atmp.err.msg=[atmp.err.msg 'AutoCorr Singularity; '];
		end

		if opts.verbose,
		if opts.separatePlots, bigfigure; %force new window for each figure
		else bigfigure(1); end %reuse #1
		end
		atmp.anis=ACRidge(atmp.ac, opts.model, opts.rplane, ...
			im, ftitle, bb, opts.verbose, listflag, opts.suppressWarn);
		if atmp.anis.err.code,
			atmp.err.code=bitor(atmp.err.code, 1);
			atmp.err.msg=[atmp.err.msg 'Fitting failed(err' ...
				int2str(atmp.anis.err.code) '); '];
		end
		if isempty(anis), anis=atmp; else anis(i)=atmp; end

		if opts.verbose && opts.savePlots,
			currDir=cd(dname);
			ofn=[froot '_ID' int2str(boxlist(i)) '_' imname '.pdf'];
			ofn=strrep(ofn,'%',''); %remove bad chars for filename: %
			saveas(gcf, ofn, 'pdf');
			cd(currDir);
		end
	end
end

function list=asort2(anisOut, opts) %resort the entries by WellID, rather than by color channel
list=[]; totcnt=anisOut.redcnt+anisOut.grncnt;
if totcnt<1, return; end
red=1:anisOut.redcnt; grn=(1:anisOut.grncnt) + anisOut.redcnt;
if anisOut.grncnt==0, list=red; return; end
if anisOut.redcnt==0, list=grn; return; end
if opts.fullimage, list=[1 2]; return; end
list=zeros(1,totcnt);
i=1; j=1; k=1;
while j<=numel(red) && k<=numel(grn),
	if anisOut.anis(red(j)).wellID < anisOut.anis(grn(k)).wellID,
		list(i)=red(j); i=i+1; j=j+1;
	elseif anisOut.anis(red(j)).wellID > anisOut.anis(grn(k)).wellID,
		list(i)=grn(k); i=i+1; k=k+1;
	else %here if same wellID
		list(i)=red(j); i=i+1; j=j+1;
		list(i)=grn(k); i=i+1; k=k+1;
	end
end
if j<=numel(red), %ran out of grns first
	while j<=numel(red),
		list(i)=red(j); i=i+1; j=j+1;  end
end
if j<=numel(grn),
	while j<=numel(grn),
		list(i)=grn(k); i=i+1; k=k+1;  end
end
end

function list=asort(anisOut, opts) %resort the entries by WellID, multicolors
list=[]; totcnt=numel(anisOut.anis);
if totcnt<1, return; end
if opts.fullimage, list=[1 2]; return; end

end

function quicklist(anisOut) %quick listing of asort (for debugging)
tstr=sprintf('\t');
ind=anisOut.asort;
if numel(ind)<1, disp('Empty asort list.'); end
for i=1:numel(ind),
	k=ind(i); j=anisOut.anis(k).wellID;
	ostr=[int2str(i) ': well#' int2str(j) tstr anisOut.anis(k).imname ];
	disp(ostr);
end
end
