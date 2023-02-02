function [outst]=ImReadS(inst, opts, pname)
%IMREADS Read image from file or from structure (stdardize DoAnis modules)
%	opt=input options for analysis; see DoAnisOpts for definitions
%	pname=path to getting to file (parent directory)
%	anisOut=results of all analysis info

% SCK 15_0422: disabled auto-skipping of DAPI when only 3 channels (very
%	old convention and now useless automation)
% SCK 14_0606: split away from DoAnis so can be pre-processed
%	NOTE: made scale=-1 as default...

if nargin<3, pname=''; end
if nargin<2 || isempty(opts), opts=DoAnisOpts; end %to parse LSM images
if nargin<1 || isempty(inst),
    [inst, pname] = uigetfile('*.tif;*.jpg;*.tiff;*.jpeg;*.lsm;', 'Image to Process');
	if isequal(inst,0) || isequal(pname,0), outst=[]; return; end %user cancelled
end
fcn='ImReadS';

if ischar(inst), 
	[tp,tf,ex]=fileparts(inst);
	outst.fname=[tf ex]; outst.ext=ex;
	outst.froot=tf; outst.pname=[pname tp];
	if ~isempty(tp), outst.pname=[outst.pname '\']; end

	scale.x=-1; scale.y=-1; scale.timestamp=[]; %default -1um/pix
	outst.scale=scale;
	if strcmpi(ex,'.lsm'),
		disp([fcn ': Detected LSM file.']);
		if numel(opts.LSMchanIndex)~=numel(opts.LSMchanName),
			error(['ImReadS: number of channels to analyze in "opts.LSMchanIndex" ' ...
				'does not match the number of names in "opts.LSMchanName". ' ...
				'Check definitions in DoAnisOpts.m']);
			outst=[];
			return;
		end
		lsm=tiffread32([pname inst]); %lsm ONLY
		scale.x=lsm.lsm.VoxelSizeX*1e6; scale.y=lsm.lsm.VoxelSizeY*1e6; %um/pix
		scale.timestamp=lsm.lsm.TimeStamp;
		outst.scale=scale; outst.imnum=LSMImageNum();
% 		if outst.imnum==3,
% 			opts.LSMchanIndex=[3 2]; opts.LSMchanName={'RedCh','GrnCh'}; opts.LSMchanWells=[];
% 			AssignLSMChan();
% 		else
			if outst.imnum<max(opts.LSMchanIndex),
				disp(['ImReadS: too few channel images (only ' int2str(outst.imnum) ') for expected maximum of ' ...
					int2str(max(opts.LSMchanIndex)) ' channel assignments.']);
				disp(['***Please edit DoAnisOpts.m to reflect the fewer number of channels.']);
				outst=[]; return;
			end
			AssignLSMChan();
% 		end
	else
		imf=imfinfo([pname inst]);
		if strcmpi(imf(1).Format,'jpg') | (strcmpi(imf(1).Format,'tif') & imf(1).SamplesPerPixel==3), %RGB
			disp([fcn ': Detected RGB file (either JPG or TIF).']);
			im=imread([pname inst]); %tif/RGB, jpg
			outst.wellsim=im; outst.imnum=1;
			cI=(opts.RGBchanIndex < 4) & (opts.RGBchanIndex > 0); %force indices 1-3
			opts.RGBchanIndex=opts.RGBchanIndex(cI);
			%if ndims(im)>2, %#ok<ISMAT> %RGB image; don't use rgb2gray (attenuates signal)
				sz=size(im);
				if sz(3)<3, error(['ImReadS: expecting RGB image, but wrong size.']);
					outst=[]; return; end
				imname={'RedCh','GrnCh','BluCh'};
				ind=(opts.RGBchanIndex>0) & (opts.RGBchanIndex<4); %strip bad channels
				chanIndex=opts.RGBchanIndex(ind);
				if isempty(chanIndex), chanIndex=1:3; end
				outst.imnum=numel(chanIndex);
				for i=1:outst.imnum, %split colors into different images for analysis
					outst.im{i}=im(:, :, chanIndex(i));
					outst.imname{i}=imname{chanIndex(i)};
				end
				chanWells=opts.RGBchanWells;
				if isempty(chanWells), chanWells=1:3; end
				outst.wellsim=im(:, :, chanWells(1));
				for i=2:numel(chanWells), %add req channels for wells
					outst.wellsim=outst.wellsim +im(:, :, chanWells(i));
					%uint16 overflow should truncate; OK as long as sum(means)<uint16max
				end
			%end
		elseif (strcmpi(imf(1).Format,'tif') & numel(imf)>1), %multichannel tif; assume OME format
			disp([fcn ': Detected multiChannel TIF file.']);
			if numel(opts.OMEchanIndex)~=numel(opts.OMEchanName),
				error(['ImReadS: number of channels to analyze in "opts.OMEchanIndex" ' ...
					'does not match the number of names in "opts.OMEchanName". ' ...
					'Check definitions in DoAnisOpts.m']);
				outst=[];
				return;
			end
			scale.x=-1; scale.y=-1; scale.timestamp=[];
			ome=xml_sread(imf(1).ImageDescription); %parse XML
			if isempty(ome), disp('ImReadS: Could not parse OME-XML in file.  Using default channel names.');
			else scale.timestamp=ome.Image.AcquisitionDate; end
			outst.scale=scale; outst.imnum=numel(imf);
			if outst.imnum<max(opts.OMEchanIndex),
				error(['ImReadS: too few images (' int2str(outst.imnum) ') for ' ...
					int2str(max(opts.OMEchanIndex)) ' channel assignments; Re-edit DoAnisOpts.m.']);
				outst=[]; return;
			end
			AssignOMEChan();
		else %not RGB; single channel
			%error(['ImReadS: code for non-RGB TIF not written yet (need test images)']);
			%return;
			outst.im{1}=imread([pname inst]);
			outst.wellsim=outst.im{1};
			outst.imname{1}='One';
		end
	end
elseif isstruct(inst) && isfield(inst,'fname') && isfield(inst,'wellsim'),
	outst=inst;
else
	error('ImReadS: unrecognized object as first argument. Cannot continue.');
end

	function nim=LSMImageNum()
		dsiz=size(lsm.data); nim=dsiz(2); %should be 1D cell array
		if dsiz(1)>1, nim=1; end %if 2D, then single image
	end

	function AssignLSMChan()
		nim=LSMImageNum();
        myMedFilt=[]; omedfilt=[];
        if isfield(opts,'LSMmedfilt'), myMedFilt=opts.LSMmedfilt; end
		if nim==1, %single image; NOT a cell array
			outst.im{1}=lsm.data;
            if any(myMedFilt==1),
                outst.im{1}=medfilt2(lsm.data,'symmetric');
                omedfilt=1;
            else outst.im{1}=lsm.data; end
			outst.wellsim=lsm.data;
			for i=1:numel(opts.LSMchanIndex)
				if opts.LSMchanIndex(i)==1,
					outst.imname{1}=opts.LSMchanName{i};
				end
            end
            outst.medfilt=omedfilt;
		else %multi-image
			k=0;
			for i=1:numel(opts.LSMchanIndex)
				if opts.LSMchanIndex(i) <= nim,
					k=k+1;
                    if any(myMedFilt==i),
                        outst.im{k}=medfilt2(lsm.data{opts.LSMchanIndex(i)},'symmetric');
                        omedfilt=[omedfilt k];
                    else outst.im{k}=lsm.data{opts.LSMchanIndex(i)}; end
					outst.imname{k}=opts.LSMchanName{i};
				end
            end
            outst.medfilt=omedfilt;
			%outst.imname=opts.LSMchanName;
			chanWells=opts.LSMchanWells;
			if isempty(chanWells), chanWells=1:outst.imnum; end
			outst.wellsim=lsm.data{chanWells(1)};
			for i=2:numel(chanWells),
				if chanWells(i)<=nim,
				outst.wellsim=outst.wellsim + lsm.data{chanWells(i)};
				end
				%uint16 overflow should truncate; OK as long as sum(means)<uint16max
			end
		end %multi-image
	end

	function AssignOMEChan()
		outst.imname=opts.OMEchanName;
		for i=1:numel(opts.OMEchanIndex)
		  outst.im{i}=imread([pname inst], 'Index', opts.OMEchanIndex(i), 'Info', imf);
		  outst.imname{i}='';
		  if ~isempty(ome), 
			outst.imname{i}=ome.Image.Pixels.Channel(opts.OMEchanIndex(i)).ATTRIBUTE.Name; %Channel names
		  end
		end
		imn1=left(outst.imname{1},4); %truncate
		imn2=left(outst.imname{end},4);
		if numel(opts.OMEchanIndex)>1 && strcmpi(imn1, imn2),
			for i=1:numel(opts.OMEchanIndex) %if first=last name, use predefined names
				outst.imname{i}=opts.OMEchanName{i}; end
		end
		chanWells=opts.OMEchanWells;
		if isempty(chanWells), chanWells=1:outst.imnum; end
		outst.wellsim=imread([pname inst], 'Index', chanWells(1), 'Info', imf);
		for i=2:numel(chanWells),
			outst.wellsim=outst.wellsim + imread([pname inst], 'Index', chanWells(i), 'Info', imf);
			%uint16 overflow should truncate; OK as long as sum(means)<uint16max
		end
	end

	function ost=left(ist,ln) %truncate string if too long
		ost='';
		if ischar(ist), ost=ist; end
		if numel(ost)>ln, ost=ost(1:ln); end
	end

end

