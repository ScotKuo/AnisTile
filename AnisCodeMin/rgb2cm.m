function rgb2cm()
% rgb2cm - Clean up colour mapping in patches to allow Painter's mode
%
% Painter's mode rendering is required for copying a figure to the
% clipboard as an EMF (vector format) or printing to vector-format files
% such as PDF and EPS. However, if the colours of any patches in your 
% figure are represented using CData and an RGB colour code, these will not
% show in the copied figure. You may also get a warning like:
% Warning: RGB color data not yet supported in Painter's mode 
%
% One solution is to change these specific patches to use an index into the
% colormap. That's what this script does. For each patch using RGB, it adds
% those colours to the colormap and changes the patch to use a colormap
% index.
%
% Robbie Andrew, March 2012

% 18 Sep 2012 	Robbie Andrew 	
%   This function works with *patches*. If you have the same problem with
%   lines plotted with markers, simply edit the code and replace
%   'FaceColor' with 'MarkerFaceColor'. Thanks to Håkon for the tip.
% 15_0424 SK: modified to include surfaces and markers, as well as patches

cm0 = colormap ; cm=cm0;
j=size(cm,1)+1 ;
patches = findall(gcf,'Type','patch','-and','FaceColor','flat');
for i=1:numel(patches)
	if strcmpi('patch',get(patches(i),'Type')), %patch
		c = get(patches(i),'FaceColor') ;
		if strcmpi('flat',c)
			set(patches(i),'CDataMapping','direct')
			c = get(patches(i),'FaceVertexCData') ;
			if size(c,2)>1
				cm = [cm; c] ;
				n = size(c,1) ;
				set(patches(i),'FaceVertexCData',j+(0:n-1)')
				j=j+n ;
			end
		end
	end
end

patches = findall(gcf,'Type','surface'); %surface, SK addition
for i=1:numel(patches)
	rgb_colors=get(patches(i),'CData');
	if size(rgb_colors,3)>1, %triplet color? Convert to indexed
		ncol=prod(size(rgb_colors))/3;
		if ncol>256, ncol=256; end %clamp max col#
		[ind, map]=rgb2ind(rgb_colors, ncol);
		cm=[cm; map];
		n=size(map, 1);
		set(patches(i),'CData',double(ind+j-1));
		j=j+n;
	end
% 	set(patches(i),'CData',double(ind);
% 	colormap(map);
end

%do colored lines (contour), SK addition
patches = findall(gcf,'Type','patch','-and','FaceColor','none','-and','CDataMapping','scaled') ;
for i=1:numel(patches), c=get(patches(i),'CData'); %get color range used
	cmx(i)=max(c(:)); cmn(i)=min(c(:)); end
maxc=max(cmx); minc=min(cmn); nc=size(cm0,1); %use original colormap
for i=1:numel(patches)
	set(patches(i),'CDataMapping','direct')
	c = get(patches(i),'CData');
	c = round((c-minc)*nc/(maxc-minc)); %don't interpolate; use colors as defined
	set(patches(i),'CData',c);
end

colormap(cm)
end