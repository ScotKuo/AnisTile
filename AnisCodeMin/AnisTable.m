function AnisTable(anisOut, opts, showhelp)
%AnisTable Generate a table of anis values from DoAnis to save as table (Excel)
%Assumes called from DoAnis, hence all entries should have same froot, but
%   diff wellIDs/colors.  Can also call this function manually with the
%   output of DoAnis.
%
% SCK 14_0326, 14_0327 tweaks for auto lsm table

if nargin<3, showhelp=0; end
if nargin<2 || isempty(opts), opts=DoAnisOpts; end

if showhelp, ShowHelp(); return; end
tstr=sprintf('\t');
dname=anisOut.pname; [dn.parent dn.root ~]=fileparts(dname(1:end-1));
if isfield(anisOut,'asort'), ind=anisOut.asort;
else ind=1:numel(anisOut.anis); end
if numel(ind)<1, return; end %no records
scale=anisOut.scale;

coltitles={'FileRoot','DirRoot','WellID','WellOrient','Shape','Channel', ...
	'Anis_WtM50','Anis_WtR50','Anis_El','Anis_Plane','ErrCode', ...
	'%Err(R-M)/M','%Err(E-M)/M', ...
	...
	'ACorr_Max','ACorr_NonCentMax','ACorr_Min', ...
	'Orient_WtM50 (deg)','MajSD_WtM50 (um)','MinSD_WtM50 (um)', ...
	'Orient_WtR50 (deg)','MajSD_WtR50 (um)','MinSD_WtR50 (um)', ...
	'Orient_El (deg)','MajAx_El (um)','MinAx_El (um)', ...
	'AnalysisTime', 'XScale', 'BBox_width','BBox_height','BBox_ULx','BBox_ULy', ...
	...
	'TauSlow_Plane (um)', 'TauFast_Plane (um)', 'TauSlowUnc_Plane (um)', 'TauFastUnc_Plane (um)', ...
	'ErrMsg' };

currDir=alistHeaders(opts,coltitles,dname); %print header; save (initiate diary) if requested
for i=1:numel(ind),
	k=ind(i); j=anisOut.anis(k).wellID;
	imname=anisOut.anis(k).imname; if numel(imname)>4, imname=imname(1:4); end
	ostr=[anisOut.froot tstr dn.root tstr int2str(j) tstr ...
		num2str(anisOut.anis(k).wellOrient) tstr ...
		anisOut.wells.s(j).Shape(1:3) tstr imname tstr ];

	ostr=[ostr num2str(getAnisOne(anisOut.anis(k).anisOne,'Max50','Weight')) tstr];
	ostr=[ostr num2str(getAnisOne(anisOut.anis(k).anisOne,'Range50(ImJ)','Weight')) tstr];
	ostr=[ostr num2str(getAnisOne(anisOut.anis(k).anisOne,'Range50(ImJ)','Ellipse')) tstr];
	[anisval, fitErr]=getAnisFit(anisOut.anis(k).anis,'Plane','Expon+Lin');
	errCode=anisOut.anis(k).err.code; if errCode==0,errCode=[]; end
	ostr=[ostr num2str(anisval) tstr int2str(errCode) tstr];
	ostr=[ostr alist2err(anisOut.anis(k).anisOne,'Range50(ImJ)','Weight','Max50','Weight') ];
	ostr=[ostr alist2err(anisOut.anis(k).anisOne,'Range50(ImJ)','Ellipse','Max50','Weight') ];

	ostr=[ostr alistACstat(anisOut.anis(k)) ]; %ACorr stats
%disp(sColCnt(ostr,1)); %debugging
	ostr=[ostr alist2(anisOut.anis(k).anisOne,scale,'Max50','Weight',1) ];
%disp(sColCnt(ostr,2)); %debugging
	ostr=[ostr alist2(anisOut.anis(k).anisOne,scale,'Range50(ImJ)','Weight',1) ];
	ostr=[ostr alist2(anisOut.anis(k).anisOne,scale,'Range50(ImJ)','Ellipse',1) ];
	ostr=[ostr datestr(now) tstr num2str(scale.x) tstr alistBox(anisOut.anis(k).boundingbox)];
	
	ostr=[ostr alistFit(anisOut.anis(k).anis,scale,'Plane','Expon+Lin',1) ];
	ostr=[ostr anisOut.anis(k).err.msg ];
	disp(ostr);
end
diary off; %not needed if not saveOutFile, just in case
if opts.saveOutFile, cd(currDir); end %see alistHeaders
end

function ShowHelp()
help1={'WellOrient','Angular orientation of well', ...
	'Shape','Guess at shape of well', ...
	'XScale','Distance (um) per pixel', ...
	'AnalysisTime','Date/Time when analysis initiated', ...
	'BBox_*','Bounding box size/coordinates:', ...
	'BBox_width','  Width of BoundingBox', ...
	'BBox_height','  Height of BoundingBox', ...
	'BBox_ULx','  X-coord of upper-left of BoundingBox', ...
	'BBox_ULy','  Y-coord of upper-left of of BoundingBox' };
help2={'Anis_*','Anisotropy index from different methods:', ...
	'Anis_WtM50','  Weighted, thresh=M50=50% of Max', ...
	'Anis_WtR50','  Weighted, thresh=R50=midpt of range (Max-Min)', ...
	'Anis_El',   '  Flat-top (not weighted), thresh=R50=midpt of range (Max-Min)', ...
	'Anis_Plane','  Ski & curve-fit', ...
	'ErrCode','  Numeric code for errors (previously FitErr)', ...
	'ErrMsg','  Error msg if problems for interpretation', ...
	'%Err(R-M)/M','  %Err of WeightedRange50 vs WeightedMax50', ...
	'%Err(E-M)/M','  %Err of FlatEllipseRange50 vs WeightedMax50', ...
	'Orient_*','Orientation (deg) of method (see Anis_*)', ...
	'MajSD_*','Major StD (um) of method (see Anis_*)', ...
	'MinSD_*','Minor StD (um) of method (see Anis_*)' };
help3={'ACorr_*','Values of AutoCorrelation:', ...
	'ACorr_Max','  Max value of AC (center; unity if scaled)', ...
	'ACorr_NonCentMax','  Next largest AC value (central is max)', ...
	'ACorr_Min','  Min value of AC' }; 
help4={'*_Plane','Fitted values from Ski & curve-fit', ...
	'FitErr','  Boolean to indicate failure in fitting (retired)', ...
	'TauSlow_Plane','  Length-constant (um) for long/slow axis', ...
	'TauFast_Plane','  Length-constant (um) for short/fast axis', ...
	'TauSlowUnc_Plane','  Uncertainty/SD (um) for tau in long/slow axis', ...
	'TauFastUnc_Plane','  Uncertainty/SD (um) for tau in short/fast axis' };
maxlen=22; pad=repmat(' ',1,maxlen);
heShow(help1);
heShow(help2);
heShow(help3);
heShow(help4);

	function heShow(he)
		ne=round(numel(he)/2);
		for i=1:ne, la=[he{2*i-1} pad];
			disp([la(1:maxlen) ': ' he{2*i}]); end
	end
end

function currDir=alistHeaders(opts,coltitles,dname) %print header (save if requested)
tstr=sprintf('\t'); newfile=1; currDir='.'; %default, stay here
if opts.saveOutFile, currDir=cd(dname);
	if exist(opts.outfile,'file')>0, newfile=0;
		if opts.eraseOutFile, delete(opts.outfile); newfile=1; end
	end
	if newfile, diary(opts.outfile); end %skip saving header if not newfile
end
disp(['Directory:' tstr dname]);
disp(['Initial ScanTime:' tstr datestr(now)]);
ostr=coltitles{1};
for i=2:numel(coltitles), ostr=[ostr tstr coltitles{i}]; end
disp(ostr);
if ~newfile && opts.saveOutFile, diary(opts.outfile); end %start saving if not newfile
end

function out=alist2(anisOne, scale, threshtype, stattype, noAnisFlag) %from ACAnisSingle()
if nargin<5, noAnisFlag=0, end %suppress Anis (if using getAnisOne() earlier)
tstr=sprintf('\t');
out=[tstr tstr tstr];
if isfield(anisOne,'label'), %any AnisOne results?
	j=0;
	for i=1:numel(anisOne.label), %find threshtype
		if strcmpi(threshtype,anisOne.label{i})==1, j=i; end
	end
	if j==0; return; end %no match on threshtype
	out='';
	if strcmpi(stattype,'Weight')==1, prop=anisOne.wprop;
	else prop=anisOne.rprop; end
	if ~noAnisFlag, out=[out num2str(prop.anis(j)) tstr]; end %suppress Anis?
	out=[out num2str(prop.orient(j)) tstr];
	if strcmpi(stattype,'Weight')==1,
		out=[out num2str(scale.x*prop.majstd(j)) tstr num2str(scale.x*prop.minstd(j)) tstr ];
	else
		out=[out num2str(scale.x*prop.major(j)) tstr num2str(scale.x*prop.minor(j)) tstr ];
	end
end
end

function out=alist2err(anisOne, thresh1, stat1, threshref, statref) %from ACAnisSingle()
tstr=sprintf('\t');
out=[tstr];
anis1=getAnisOne(anisOne, thresh1, stat1);
anisref=getAnisOne(anisOne, threshref, statref);
if isempty(anis1) || isempty(anisref), return; end
out=[num2str(100*(anis1-anisref)/anisref) tstr ];
end

function anisval=getAnisOne(anisOne, threshtype, stattype) %get anisval from ACAnisSingle()
anisval=[];
if isfield(anisOne,'label'), %any AnisOne results?
	j=0;
	for i=1:numel(anisOne.label), %find threshtype
		if strcmpi(threshtype,anisOne.label{i})==1, j=i; end
	end
	if j==0; return; end %no match on threshtype
	if strcmpi(stattype,'Weight')==1, anisval=anisOne.wprop.anis(j);
	else anisval=anisOne.rprop.anis(j); end
end
end

function out=alistFit(anis, scale, skipath, fittype, noAnisFlag) %from ACRidge()
if nargin<5, noAnisFlag=0; end %suppress Anis (if using getAnisFit() earlier)
tstr=sprintf('\t');
if strcmpi(skipath,'Plane')==1, spath=anis.plane;
else spath=anis.ridge; end
if strcmpi(fittype,'Exp+Lin')==1,
	fast=spath.fast.explin.ef; slow=spath.slow.explin.ef;
else
	fast=spath.fast.exp2.ef; slow=spath.slow.exp2.ef;
end
out='';
if ~slow.error, out=[out num2str(scale.x*slow.p(1))]; end; out=[out tstr];
if ~fast.error, out=[out num2str(scale.x*fast.p(1))]; end; out=[out tstr];
if ~noAnisFlag, 
	if ~slow.error && ~fast.error,
	out=[out num2str(slow.p(1)/fast.p(1))]; end; out=[out tstr];
end
if ~slow.error, out=[out num2str(scale.x*slow.p_err(1))]; end; out=[out tstr];
if ~fast.error, out=[out num2str(scale.x*fast.p_err(1))]; end; out=[out tstr];
end

function [anisval fitErr]=getAnisFit(anis, skipath, fittype) %get anisval from ACRidge()
anisval=[]; fitErr=[];
if strcmpi(skipath,'Plane')==1, spath=anis.plane;
else spath=anis.ridge; end
if strcmpi(fittype,'Exp+Lin')==1,
	fast=spath.fast.explin.ef; slow=spath.slow.explin.ef;
else
	fast=spath.fast.exp2.ef; slow=spath.slow.exp2.ef;
end
if ~slow.error && ~fast.error,
	anisval=slow.p(1)/fast.p(1);
	if slow.p_err(1)>slow.p(1) || fast.p_err(1)>fast.p(1),
		fitErr=1; end
else
	fitErr=1;
end
end

function out=alistBox(bb) %from regionprops()
tstr=sprintf('\t');
out=[tstr tstr tstr tstr];
if numel(bb)<4, return; end
out=[int2str(bb(3)) tstr int2str(bb(4)) tstr int2str(bb(1)) tstr ...
	int2str(bb(2)) tstr];
end

function out=alistACstat(anis) %from anis.acstat/imAutoCorr() (includes
%	pre-scale max/min) *OR* from anisOne/ACAnisSingle in root of anis
tstr=sprintf('\t');
%out=[num2str(anis.acstat.max) tstr num2str(anis.acstat.min) tstr]; %Pre-scaled, useful?
%out=[num2str(anis.acstat.scaledmax) tstr num2str(anis.acstat.scaledmin) tstr]; %EQUIVALENT
out=[num2str(anis.anisOne.max) tstr num2str(anis.anisOne.max2) tstr ...
	num2str(anis.anisOne.min) tstr]; %EQUIVALENT; max2 is NonCentMax
end

function out=sColCnt(str,rcnt) %string version of tabbed col counting
	tstr=sprintf('\t');
	cnt=length(find(str==tstr));
	if nargin>1, out=[int2str(rcnt) ': ']; end
	out=[out 'String has ' int2str(cnt) ' tabbed columns.'];
end

