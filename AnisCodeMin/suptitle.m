function [ax,h] = suptitle(text)
%Centers a title over a group of subplots.
%Returns a handle to the title and the handle to an axis.
% [ax,h]=subtitle(text)
%           returns handles to both the axis and the title.
% ax=subtitle(text)
%           returns a handle to the axis only.

minh=20;
v=get(gcf,'position'); y0=0.025; dh=0.92;
if (1-dh-y0)*v(4) < minh,
	dh=1-minh/v(4)-y0; end
ax=axes('Units','Normal','Position',[.025 y0 .95 dh],'Visible','off');
%ax=axes('Units','Normal','Position',[.075 .075 .85 .85],'Visible','off');
set(get(ax,'Title'),'Visible','on')
title(text);
if (nargout < 2)
    return
end
h=get(ax,'Title');
end

