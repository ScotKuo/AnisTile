xv=-50:50; yv=-50:50; [x,y]=meshgrid(xv,yv);
y0=2:.25:15;
x0=5:.25:35;
xp=zeros(numel(y0),numel(x0)); yp=xp;
zp=ones(numel(y0),numel(x0)) * NaN;
for i=1:numel(x0), 
	for j=1:numel(y0),
		if x0(i)>=y0(j),
		a1=exp(-sqrt(x.*x/(x0(i).*x0(i)) + y.*y/(y0(j)*y0(j))));
		wAC=wACAnis(a1,0.5,1,5,1);
	% disp([num2str(i) ':' num2str(wAC.regprops.MajorAxisLength,2) '/' ...
	% 	num2str(wAC.rot.MajorAxisLength,2) '=' ...
	% 	num2str(wAC.regprops.MajorAxisLength/wAC.rot.MajorAxisLength,3)]);
		xp(j,i)=x0(i); yp(j,i)=y0(j);
		zp(j,i)=wAC.regprops.MajorAxisLength/wAC.rot.MajorAxisLength;
		end
	end
end

surf(xp,yp,zp);
set(gca,'dataaspectratio',[1 1 0.1],'dataaspectratiomode','manual');
w=zp(~isnan(zp));
mean(w(:))
