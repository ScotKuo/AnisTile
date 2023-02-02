% Make a big figure window; updated by SCK, same as Scot's bigfigure()
%   bigfigure(ii, letterSize)
%	ii: empty or no arguments: use current figure; else use specified
%		figure
%	letterSize: resize frame so letterSize ratio (for exporting to Adobe
%		Illustrator later).
%
% 15_0428 SK: modified with letterSize flag
function [h]=bigfigure(ii, letterSize)
if nargin<2, letterSize=0; end
if nargin<1 || isempty(ii),
    h=figure;
else
    h=figure(ii);
end
orient landscape;
system_dependent(14,'on'); %for Windows cut & paste
set(gcf,'Renderer', 'Painters');

v=get(0,'screensize'); %typ[1 1 1024 768]
%vnum=str2num(version('-release')); %not for v5.3 (r11)
%if vnum >=12.1,
%
%vs=version;
%vnum=str2num(vs(1:3));
%if vnum>=6.5,
%v2=[1 29 v(3), v(4)-96]; %built-in zoom does this
if v(3)>1024 || v(4)>768, v=[v(1:2) 1024 768]; end
v2=[1 30 v(3)-1 v(4)-97];
if letterSize,
	dx=0; dy=0; border=0.5;
	pageRatio=(11-2*border)/(8.5-2*border); %from Adobe Illustrator for 11x8.5
	if v2(4)*pageRatio>v2(3), t=(v2(3)/pageRatio); dy=v2(4)-t; v2(4)=t;
		else t=(v2(4)*pageRatio); dx=v2(3)-t; v2(3)=t; end
	v2(1)=v2(1)+dx/2; v2(2)=v2(2)+dy/2;
end
%else
%v2=[1 29 v(3) v(4)-64];	
%end
set(gcf,'position',v2); %[x0,y0, dx,dy], lower left is origin
if nargout<1, clear h; end
return
