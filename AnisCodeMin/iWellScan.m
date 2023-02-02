function [bb,ws]=iWellScan(fname,channel,bLev)
%IWELLSCAN Vary thresholds for detecting cell-PDMS-well boundaries in images; best if LSM image files
%	>Will try different thresholds to help define best level
%	>bLev=threshold level to display (% of (Mean-Mode))
%	>channel=which channel to use; 0=add all channels (note:NOT average);
%		default=0
%
% SCK 13_1224

if nargin<3, bLev=0.07; end
if nargin<2, channel=0; end
if nargin<1 || isempty(fname),
    [fname, pname] = uigetfile('*.tif;*.jpg;*.tiff;*.jpeg;*.lsm;', 'Image to Process');
	if isequal(fname,0) || isequal(pname,0) return; end %user cancelled
%     pname='C:\Users\Scot C. Kuo\Desktop\Collab\Romer\Janna Data\';
%     fname='D1 S1 10X rec 1 snap bottom.lsm';
end
[ps,fn,ex]=fileparts(fname);
imname=fname;
if strcmpi(ex,'.lsm'),
	im0=tiffread32([pname fname]); %lsm ONLY
	imlab={'(rgb)','(blu)','(grn)','(red)'};
	imname=[imname imlab{channel+1}];
	if channel==0,
		im=im0.data{1}+im0.data{2}+im0.data{3};
		%uint16 overflow should truncate; OK as long as sum(means)<uint16max
	else
		im=im0.data{channel};
	end
else
	im=imread([pname fname]);
	if ndims(im)>2, %RGB image
		im=im(:, :, 1); %red values only; rgb2gray attenuates signal
		imname=[imname '(red)'];
	end
end

ws=WellScan(im);
DoPlot(ws,im,imname,bLev);
n=min(find([ws.bb.levf]>=bLev));
bb=ws.bb(n).s(1).BoundingBox;
end

function ws=WellScan(im, nlev)
if nargin<2, nlev=25; end
ws.mode=double(mode(double(im(:)))); ws.mean=mean(double(im(:)));
ws.max=double(max(im(:))); ws.min=double(min(im(:)));
im2=medfilt2(im,[5 5]);
levf=(1:nlev) ./ nlev; levf=levf * 0.25; %max of 0.25
for i=1:nlev,
	bb(i)=FindWells(im2, levf(i), ws);
end
ws.bb=bb;
end

function DoPlot(ws,im,imname,bLev)
	bb=ws.bb; nObj=6; lins={'y-','r-','c-','g-','m-','c:'}; clf;
	n=min(find([bb.levf]>=bLev));
	subplot(2,2,1);
	imagesc(im); axis equal; axis tight;
	PlotBoxes(bb,bLev,nObj,lins);
	title([imname '; Boxes @' num2str(bLev*100) '%']);

	subplot(2,2,3);
	bw=imfill(im2bw(im,bb(n).lev),'holes');
	imagesc(bw); axis equal; axis 'tight'
	PlotBoxes(bb,bLev,nObj,lins,0);
	for i=1:nObj,
		leg{i}=['s' int2str(i) ':' num2str(bb(n).s(i).Orientation,2) 'deg (' ...
			bb(n).s(i).Shape ')'];
	end
	legend(leg,'Location','NorthEastOutside');
	
	pleft=0.55; pwidth=0.4;
	subplot('position',[pleft 0.7 pwidth 0.2]);
	multiPlot(bb,'BoundingBox',bLev,nObj,lins,1); ylabel('BoxArea');
% 	edges=[ws.mode,ws.bb.edge]; levEq=[0,ws.bb.levf];
% 	[hcnt]=histc(im(:),edges);
% 	bar(levEq,hcnt,1); ylabel('IntFreq'); %intensity histogram
	set(gca,'XTickLabel',[]); axis tight;
	
	subplot('position',[pleft 0.5 pwidth 0.2]);
	multiPlot(bb,'Area',bLev,nObj,lins,1); ylabel('Area');
	set(gca,'XTickLabel',[]); axis tight;
	
	subplot('position',[pleft 0.3 pwidth 0.2]);
	multiPlot(bb,'Extent',bLev,nObj,lins,1); ylabel('Extent');
	set(gca,'XTickLabel',[]); axis tight;
	
	subplot('position',[pleft 0.1 pwidth 0.2]);
	plot([bb.levf],[bb.cnt]); ylabel('nObjects');
	nc=find([bb.cnt]==min([bb.cnt]));
	legend(['min @[' num2str([bb(nc).levf]*100) ']%']);
	axis tight;
	xlabel('Thresh {%(mean-mode)}');

end

function multiPlot(bb,fld,bLev,nObj,lins,addlegend)
	if nargin<6,addlegend=0;end
	combmode=1; %if nargin<6,combmode=0;end
	n=min(find([bb.levf]>=bLev));
	hold on;
	for i=1:nObj,
		aa=bbdeal(bb,i,fld); a1=max(aa); a2=min(aa);
		leg{i}=['s' int2str(i) '(' num2str(bb(n).levf,2) '):' num2str(aa(n),2)];
		if i==1, cum=aa/a1; else cum = cum .* aa/a1; end
		%if combmode<1,
			aa=(aa-a2)/(a1-a2); %expand all scales
			plot([bb.levf],aa,lins{i});
		%end
	end
	if combmode>0, plot([bb.levf],cum,'k-','LineWidth',2); 
		leg{nObj+1}=['Combined:' num2str(cum(n),2)]; end
	if addlegend, legend(leg); end
	hold off;
end

function PlotBoxes(bb,bLev,nObj,lins,boundflag);
	if nargin<5, boundflag=1; end %draw boundary, too
	n=min(find([bb.levf]>=bLev));
	hold on;
	for i=1:nObj, bx=bb(n).s(i).BoundingBox;
		vx=[bx(1) bx(1) bx(1)+bx(3) bx(1)+bx(3) bx(1)];
		vy=[bx(2) bx(2)+bx(4) bx(2)+bx(4) bx(2) bx(2)];
		if boundflag,
			plot(vx, vy, 'w');
			bound=bb(n).B{i};
			plot(bound(:,2), bound(:,1), lins{i})
		else
			plot(vx, vy, lins{i});
		end
	end
	hold off;
end

function val=bbdeal(bb,si,fld)
val=zeros(numel(bb),1);
for i=1:numel(bb),
	if si>numel(bb(i).s), val(i)=NaN;
	else
		if strcmpi(fld,'BoundingBox'), aa=getfield(bb(i).s(si), fld);
			val(i)=aa(3)*aa(4); %bounding box area
		else val(i)=getfield(bb(i).s(si), fld); end
	end
end
end
