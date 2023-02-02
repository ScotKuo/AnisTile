function [bb] = FindWells(im, levf, ws)
%FINDWELLS Find cell-PDMS-wells in images (threshold scaled as %(mean-mode))
% [bb] = FindWells(im, levf, ws)
% >im=uint16 image array
% >levf=threshold for segmenting image, is % of (Mean-Mode)
%	default=8% (least # objects; use iWellScan to search)
%	negative levf=fullimage
% >ws=structure that has mean,mode values (optional; from iWellScan)
% RETURNS: bb.s()=stuff from regionprops; only regions>1500pix
%		>includes bb.s(i).Shape for shape guess
%	bb.B()=boundary of each region
%
% SCK 13_1224; separated as function 14_0126
%	14_0312: removed imfnc conventions and threshold directly
%	15_0206: more robust handling of no-well situation (no longer an error; empty bb returned)

if nargin<2, levf=0.08; end
if nargin<3, im2=double(im); im2(im2==65535)=NaN; %mode acts weird sometimes!
	ws.mode=double(mode(im2(:))); ws.mean=mean(im(:)); end

bb.levf=levf; bb.edge=double(levf)*(ws.mean-ws.mode)+ws.mode;
if levf<0, %fullimage
	a=size(im); bb.cnt=1; bb.s.Area=prod(a); bb.maxsize=bb.s.Area;
	bb.s.Centroid=a./2; bb.s.BoundingBox=[1 1 a]; bb.s.Orientation=NaN;
	bb.s.MajorAxisLength=NaN; bb.s.MinorAxisLength=NaN; bb.s.Extent=NaN;
	bb.s.Shape='Full';
	return
end
%bb.lev=bb.edge/double(intmax(class(im)));
%bw=imfill(im2bw(im,bb.lev),'holes');
b =(im>=bb.edge); %skip all im() conventions/conversions
bw =imfill(b,'holes');

[B,L]=bwboundaries(bw,'noholes');
s =regionprops(L, 'Area', 'BoundingBox', 'Centroid', 'Extent', ...
	'Orientation', 'MajorAxisLength', 'MinorAxisLength');
bb.cnt=numel(s); bb.maxsize=0; [s.Shape]=deal('');
for i=1:bb.cnt;
	if s(i).Area>bb.maxsize, bb.maxsize=s(i).Area; end;
end

%sift & sort by size
ind=([s.Area]>1500); s2=s(ind); B2=B(ind); %keep big ones, then sort by size
if numel(s2)<1,
	bb.s=s2; bb.B=B2; %should be empty
	disp(['FindWells: Warning: no wells found! [mode=' num2str(ws.mode) ...
		'; mean=' num2str(ws.mean) '; maxArea=' int2str(bb.maxsize) ']']);
% 	imagesc(im); axis ij; axis equal; axis tight; hold on;
% 	for i=1:numel(B); eb=B{i}; plot(eb(:,2), eb(:,1), 'y'); end; hold off
%	error(['FindWells: Error: no wells found! [mode=' num2str(ws.mode) ...
%		'; mean=' num2str(ws.mean) '; maxArea=' int2str(bb.maxsize) ']']);
else,
%	[s2.Shape]=deal('');
	[~,ind]=sort([s2.Area],2,'descend'); %could transpose rather than dim=2
	bb.s=s2(ind); bb.B=B2(ind);

	%guess at shapes
	shi=([bb.s.Extent]<=(pi/4)*1.07); %Elliptical; 7% slop
	shi=shi*2 + (([bb.s.MajorAxisLength] ./ [bb.s.MinorAxisLength])<1.07);
	shlabel={'Rectangle','Square','Ellipse','Circle'};
	for i=1:numel(bb.s), bb.s(i).Shape=shlabel{shi(i)+1}; end
end
end

