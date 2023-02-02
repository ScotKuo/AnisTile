% Commands for analyzing Anisotropy of Images
% Version 1.0 28-Jan-2014, SCK
% Version 1.5 22-May-2015, SCK, Tiled analysis; manuscript figures
%
% ==================================
% Automated Analysis Tool
%   ChooseWells          - User interface for DoAnis to choose wells in image
%   DoAnis               - Perform semi-automated anisotropy analysis of fluorescence image
%   DoAnisOpts_ChanRGB   - DOANISOPTS Options for DoAnis
%   DoAnisOpts_ChanRGM,Spill6 - DOANISOPTS Options for DoAnis, for higher well thresholds
%   DoAnisOpts           - Options for DoAnis
%
% Developmental Tools
%   iWellScan            - Vary thresholds for detecting cell-PDMS-well boundaries in images; best if LSM image files
%   iAnisotropy          - Use ACAnisScan() and imAutoCorr() to compare bw threshold on anis estimates
%   ACRidge              - Ski down AutoCorr to get distance constants lambda for models (exp2 or explin)
%   lsmCrop              - Open an lsm/jpg/tif file and send to imtool() for cropping.
%
% Core Support Functions
%   AnisTable            - AnisTable Generate a table of anis values from DoAnis to save as table (Excel)
%   ImReadS              - Read image from file or from structure (stdardize DoAnis modules)
%   ACAnisScan           - Try multiple thresholds to analyze autocorr (scaled as %(max-min))
%   ACAnisSingle         - Do 50% thresholds of AutoCorr anisotropy (ImageJ and variations)
%   imAutoCorr           - Calculate an image's autocorrelation function (various normalizations)
%   wACAnis              - Calculate intensity-weighted ('mountain' & 'ellipse') interpretation of autocorr;
%   FindWells            - Find cell-PDMS-wells in images (threshold scaled as %(mean-mode))
%
% Other support functions
%
% Core Utilities
%   bigfigure            - Make a big figure window; updated by SCK, same as Scot's bigfigure()
%   format_datum         - Create string showing uncertainty of a datum estimate
%   lsqfit               - Do nonlinear least-squares fitting of arbitrary functions (needs Optimization Toolbox)
%   MedFilt              - One dimensional median filter.
%   smooth_boxcar        - Apply boxcar filter, but pad with end values (not zeros)
%   tiffread32           - read tiff image files (including lsm)
%   xml_sread            - xml_sread reads an xmlstring and converts it into Matlab's struct tree.
%   xmlreadstring        - Modified XMLREAD function to read XML data from a string.
%
% ==================================
% Tiled Analysis (multiple files)
%   DoTileMany           - DoTileMany automates processing the multiple files sent by Janna (in many
%   ShowTileDistrMany    - Using ShowTileDistr, show the results of DoTile/ACTile (same driver list
%   DoTileCAList         - make Fig summarizing cs vs squares using DoTileCList (pairwise correlation
%
% Tile: Core support functions
%   DoTile               - Analyze an image in ACTile/'tiles' for anisotropy (pre-set list of tile sizes)
%   ACTile               - Do Tiled analysis (size/overlap): apply imAutocorr/ACAnisSinge/wACAnis
%   DoAnisOpts_4ChanTile - Options for Tile analysis by DoTile (names channels)
%   ShowTile             - display (Fig3) data from DoTile and ACTile, saved as imgs
%   ShowTileDistr        - do box-whisker distrib of select metrics as a function of tilesize.
%   DoTile2              - analyze the acGrid data for correlations between stains.
%   DoTileCAve           - show averaged stain-correlation of multiple files calculated by DoTileMany
%
% Tile: Other support functions
%   DrawArrows           - Analogous to Quiver, but center arrows at x,y (quiver arrows originate
%   DrawEllipses         - Analogous to Quiver, but draw ellipses (maj,min,ang) at x,y centers
%   DrawEllipse          - Draw an ellipse in the current axes
%   boxplot2             - Display box-whisker plots of cell array data (not matrix).
%   boxutil              - Produces a single box plot.
%   correl               - corr=Correl(u,v) returns correlation (Pearson r and Fisher z) and probablity of
%   flipCorners          - [x,y]=flipCorners(x,y,dist) for correlation plots of angles, will flip
%   sanePColor           - simple wrapper for pcolor
%   rose2                - Angle histogram plot, but filled patches.
%   sem                  - c=sem(x,p95) -- Computes the SEM *OR* the 95% confidence interval
%   suptitle             - Centers a title over a group of subplots.
%   left0                - left(str,len) does the standard string truncation, if str too long
%
% Manuscript prep:
%   DoFig1               - Do Fig1 (peak-ellipse) for methods manuscript
%
% Manuscript prep, hacks to get hires Illustrator files
%   cbfit                - Changes COLORMAP and CAXIS to fit between colorbar's ticks.
%   cbfreeze             - Freezes the colormap of a colorbar.
%   cbhandle             - Gets the handle of current colorbar or its peer axes.
%   cblabel              - Adds a label to the colorbar.
%   cbunits              - Adds units (and ISU prefixes) to the colorbar ticklabels.
%   freezeColors         - freezeColors  Lock colors of plot, enabling multiple colormaps per figure. (v2.3)
%   rgb2cm               - rgb2cm - Clean up colour mapping in patches to allow Painter's mode
%
% =====NOT USED, DELETED========
% Utilities for automation
%   Do_All               - Do_All: performs a function, fncname(), iteratively on a list of files
%   Do_AllSubD           - Do_AllSubD: eval 'fnc()' recursively on currDir and then subDirs that match 'patt'
%   getfnames            - getfnames: Search a directory using wildcards; match string is 'patt'
%   getdnames            - getdnames: Search for sudirectories using wildcards; match string is patt
%   tiffread33           - tiffread, version 3.31 - September 20, 2014
%
% Useful Utilities (not used)
%
% Retired from usage (not used)
%   ACAnisScan_old       - Function [anis]=ACAnis(AC,nLev,plotflag) Extract ellipses from 2D contours of 2D
%   fit_exp2decay        - fit_exp2decay -- for fitting an two-exp decay to fit autoCorr
%   fit_expdecay         - fit_expdecay -- for fitting an expdecay to fit autoCorr
%   fit_exp2decay2       - exp2 -- for fitting an two-exp decay to fit autoCorr; separate
%   fit_expdecayslope    - explin -- for fitting an exp decay+slope to fit autoCorr
%
% Under development
%   imBkg                - 
