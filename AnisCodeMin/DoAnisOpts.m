function opts = DoAnisOpts()
%DOANISOPTS Options for DoAnis
%
% SK 17_1114 single-channel TIF (Qianru)
% SK 15_0422 added wellslimitmax so only one version of Choosewells;
%	> disabled autoassign 3chan (won't auto discard DAPI)
% SK 15_0130 added multi-image-TIFF (OME) parameters
% SK 14_0603 added LSM parameters
% SK 14_0125, 14_0326 extra parameters

%=====Input parameters: which channels to analyze============
%LSM image channel assignments
opts.LSMchanIndex=[4 3 1 2]; %Indices of imageChannels to analyze for Anis, in order of analysis
opts.LSMchanName={'Actin', 'Fn', 'Tub', 'DAPI'}; %Name for imageChannel positions, in order of analysis
	%Note: only first 4 char of each chanName are kept in Table
opts.LSMchanWells=[]; %Indices of images to combine to find Well boundaries
	%empty list means all channels; else list indices of channels explicitly

%One-Channel LSM Image (supercedes multichannel above); comment out if not used
if 0,
	opts.LSMchanIndex=[1];
	opts.LSMchanName={'Ch1'};
	opts.LSMchanWells=[];
end

opts.OMEchanIndex=[1 2 3 4]; %Indices of imageChannels to analyze for Anis, in order of analysis
opts.OMEchanName={'Ch1', 'Ch2', 'Ch3', 'Ch4'}; %Name for imageChannel positions, in order of analysis
	%Note: only first 4 char of each chanName are kept in Table
opts.OMEchanWells=[]; %Indices of images to combine to find Well boundaries
	%empty list means all channels; else list indices of channels explicitly

%RGB (JPEG,TIF) image channel assignments; 1=R,2=G,3=B
%	Janna's original images were exports of individual colors
opts.RGBchanIndex=[1]; %Indices of imageChannels to analyze for Anis, in order of analysis
	%empty list means all channels; else list indices of channels explicitly
opts.RGBchanWells=[]; %Indices of images to combine to find Well boundaries
	%empty list means all channels; else list indices of channels explicitly

%=======processing parameters==========
%  Note: first two parameters can control with GUI ChooseWells()
opts.fullimage=0; %flag to do full image and not individual wells
opts.wellslimit=0.08; %threshold for IDing wells: %(mean-mode)
opts.scramble=0; %scramble pixels to get baseline statistics
opts.acnorm=1; %how to normalize AutoCorr: 0=nothing (physics textbook)
	%1=subtract mean prior to AC calculation and max=1.0 (stats textbook)
opts.model='explin'; %else 'exp2'; model to fit autocorr 'ski path'
opts.rplane=10; %pixel distance to ID planar 'ski path'

%======user interface & conveniences========
opts.wellslimitmax=0.2; %for ChooseWells slider, default min,max=0.02,0.2
opts.wellslimitmin=0.02; %  if cells cross well boundaries, min,max=0.1,0.6
opts.verbose=1; %if off, will suppress figures/tables; overrides separatePlots and savePlots
opts.separatePlots=0; %plot in separate windows
opts.savePlots=1; %save plots (PDF)

opts.valTableOnly=1; %only display data as summary table (suppress verbose, easy-read tables)
opts.saveOutFile=1; %save valTable as text (fname=outfile) for Excel
opts.eraseOutFile=0; %erase outfile if already exists (default is append)
opts.outfile='DoAnis.txt';

opts.suppressWarn=1; %suppress warnings for wACAnis (low thresh where no central ellipse)

%SCK test overrides; set 'if 0,' to turn off overrides
if 0,
	opts.verbose=1; %if off, will suppress figures/tables; overrides separatePlots and savePlots
	opts.separatePlots=0; %plot in separate windows
	opts.savePlots=1; %save plots (PDF)
	opts.eraseOutFile=0; %erase outfile if already exists (default is append)
	opts.wellslimit=0.1; %threshold for wells: %(mean-mode)
end
end

