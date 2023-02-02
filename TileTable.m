function imgs=TileTable(imgs, setnum, DTopts)
%TILETABLE export for Excel requested data from DoTile suite (imgs
%    structure, see DoTile).  When called without arguments or empty imgs,
%    TileTable will prompt for the *.mat file that contains imgs from a
%    prior DoTile call.
% imgs=ShowTile(imgs, setnum, DTopts)
%
% 17_1114 SK
if nargin<3, DTopts=DoTileOpts; end
if nargin<2, setnum=1; end
if nargin<1 || isempty(imgs), imgs=[];
	[fname, pname] = uigetfile('*.mat;', 'Processed Data to Display');
	if isequal(fname,0) || isequal(pname,0), return; end %user cancelled
	load([pname fname]);
	if exist('imgs','var') ~= 1,
		disp('File does not contain ACTile information.  Exiting.');
		return;
	end
	disp(['Exporting analysis of image "' imgs.fname '".']); 
end

ns=size(imgs.acGrid,1); %check setnum (empty means all; 0 means Full only)
	if isempty(setnum), setnum=1:ns; end
	if any(setnum<1), setnum=[]; % any setnum=0 means FULL only
	elseif any(setnum>ns), setnum=setnum(setnum<=ns); end %strip any invalid setnums
tstr=sprintf('\t');
if DTopts.XLSshowdir,
	coltitles={'FileRoot','DirRoot','Chan','TSize','X','Y','Anis', ...
		'Ang','Major','Minor' };
else
	coltitles={'FileRoot','Chan','TSize','X','Y','Anis', ...
		'Ang','Major','Minor' };
end
if DTopts.XLSgridstats, %do stats across tiles rather than dumping each tile
	if DTopts.XLSshowdir,
		coltitles={'FileRoot','DirRoot','Chan','TSize','Anis(Ave)','Anis(SD)', ...
			'Ang(Ave)','Ang(SD)','Major(Ave)','Major(SD)','Minor(Ave)','Minor(SD)' };
	else
		coltitles={'FileRoot','Chan','TSize','Anis(Ave)','Anis(SD)', ...
			'Ang(Ave)','Ang(SD)','Major(Ave)','Major(SD)','Minor(Ave)','Minor(SD)' };
	end
end

txtFname=[imgs.froot '_' imgs.boxname{1} '.txt']; %name of output file
currDir=Headers(txtFname); %print header; start save (initiate diary) if requested
Export();
diary off; %not needed if not XLSsaveFile, but just in case
if DTopts.XLSsavefile, cd(currDir); end %see Headers
if nargout<1, clear imgs; end

%======Internal Functions========
	function Export()
	if 1, %dump data for FULL
		for it=1:numel(imgs.im), %channel
			chname=imgs.imname{it}; imsz=size(imgs.im{it});
			at=imgs.acGrid{1}.full;
			ostr=[imgs.froot tstr];
			if DTopts.XLSshowdir, ostr=[ostr imgs.pname tstr]; end
			ostr=[ostr chname tstr 'FULL' tstr];
			if DTopts.XLSgridstats,
				ostr=[ostr num2str(at.anis) tstr tstr num2str(-at.ang) tstr tstr];
				ostr=[ostr num2str(at.major) tstr tstr num2str(at.minor) tstr];
			else
				ostr=[ostr num2str(imsz(2)/2) tstr num2str(imsz(1)/2) tstr];
				ostr=[ostr num2str(at.anis) tstr num2str(at.ang) tstr];
				ostr=[ostr num2str(at.major) tstr num2str(at.minor)];
			end
			disp(ostr);
		end
	end
	for jt=1:numel(setnum), %setnum
		for it=1:numel(imgs.im), %channel
			at=imgs.acGrid{setnum(jt),it}; chname=imgs.imname{it};
			if DTopts.XLSgridstats,
				ostr=[imgs.froot tstr];
				if DTopts.XLSshowdir, ostr=[ostr imgs.pname tstr]; end
				ostr=[ostr chname tstr num2str(at.tsize)];
				at1=at.anis(:);ostr=[ostr tstr num2str(mean(at1)) tstr num2str(std(at1))];
				at1=-at.ang(:);ostr=[ostr tstr num2str(mean(at1)) tstr num2str(std(at1))];
				at1=at.major(:);ostr=[ostr tstr num2str(mean(at1)) tstr num2str(std(at1))];
				at1=at.minor(:);ostr=[ostr tstr num2str(mean(at1)) tstr num2str(std(at1))];
				disp(ostr);
			else
				gsz=size(at.x);
				for yt=1:gsz(1), for xt=1:gsz(2),
				ostr=[imgs.froot tstr];
				if DTopts.XLSshowdir, ostr=[ostr imgs.pname tstr]; end
				ostr=[ostr chname tstr num2str(at.tsize) tstr];
				ostr=[ostr num2str(at.x(yt,xt)) tstr num2str(at.y(yt,xt)) tstr];
				ostr=[ostr num2str(at.anis(yt,xt)) tstr num2str(-at.ang(yt,xt)) tstr];
				ostr=[ostr num2str(at.major(yt,xt)) tstr num2str(at.minor(yt,xt))];
				disp(ostr);
				end, end
			end
		end
	end
	end

	function currDir=Headers(tfile) %print header (save if requested)
		newfile=1; currDir='.'; %default, stay here
		if DTopts.XLSsavefile, currDir=cd(imgs.pname);
			if exist(tfile,'file')>0, newfile=0;
				if DTopts.XLSerasefile, delete(txtFname); newfile=1; end
			end
			if newfile, diary(tfile); end %skip saving header if not newfile
		end
		disp(['Directory:' tstr imgs.pname]);
		if isfield(imgs,'analytime'), disp(['Analysis Time:' tstr datestr(imgs.analytime)]); end
		disp(['Export Time:' tstr datestr(now)]);
		ostr=coltitles{1};
		for i=2:numel(coltitles), ostr=[ostr tstr coltitles{i}]; end
		disp(ostr);
		if ~newfile && DTopts.XLSsavefile, diary(txtFname); end %start saving if not newfile
	end

end
