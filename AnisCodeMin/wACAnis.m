function wAC = wACAnis(AC,lev,flipy,mindist,suppressWarn_wACAnis)
%WACANIS Calculate intensity-weighted ('mountain' & 'ellipse') interpretation of autocorr;
%	also gives raw variances for combining multiple subregions later.
%
% wAC = wACAnis(AC,lev,flipy) Weight-AutoCorr-Anisotropy
% >flipy=for ij(images) vs xy(math) orientation of y-axis; default=true
%  {my original derivation rotated opposite direction from MatLab; weighted
%  code rewritten to follow MatLab conventions, which is xy, not ij}
% >mindist=required proximity to center for regions; default=5pix
%
% 13_1206 SCK, Note: ~2% difference in flat ellipse from regionprops.  Not
% clear why, but I haven't parsed their method (copied as comment below).
% 14_0424 SCK: Fixed 90-deg ambiguity (should have looked at 2nd deriv
% after minimizing crossVariance); also understand 2% difference (1/12 not
% added) and understand the eigenvalue approach of regionprops.
%	>Kept debugging code that will complain, just in case
% 15_0422, SCK: added meps test to eliminate negative variances (should
%	never happen; generates complex values for maj/min axes).

debug=0; %Scot debugging rotation ambiguity
if nargin<5, suppressWarn_wACAnis=0; end
if nargin<4, mindist=5; end
if nargin<3, flipy=1; end
% if class(AC)=='double', %if double, rescale both AC and lev to uint16
% 	dAC=AC; maxAC=max(max(dAC)); 
% 	rscale=double(intmax('uint16'))/maxAC;
% 	AC=uint16(rscale*dAC); lev=rscale*lev; end
% wAC.lev=double(round(lev));
% b =im2bw(AC,wAC.lev/double(intmax(class(AC)))); %assumes image uint (8 or 16)
%b =(AC>=lev); %skip all im() conventions/conversions
b =(AC>lev); %skip all im() conventions/conversions
s =regionprops(b, 'PixelIdxList', 'PixelList', 'Centroid');
k=0;
if numel(s)>1, %only use region within mindist of center
	cn=fliplr(size(AC)) ./ 2; %annoying that transposed...
	for j=1:numel(s),
		if sum((s(j).Centroid - cn).^2) < mindist^2, %within mindist of center
			k=j; break;
		end
	end
	if k>0, s(1)=s(k);
	else
		wAC=[];
		if ~suppressWarn_wACAnis,
		disp(['wACAnis: WARNING: No central region (within ' num2str(mindist) ...
			' pix) when threshold=' num2str(lev)]);
		end
		return
	end
end

if numel(s)>0 && numel(s(1).PixelIdxList)>1,
	idx =s(1).PixelIdxList;
	x =double(s(1).PixelList(:, 1)); %extract coordinates as vectors
	y =double(s(1).PixelList(:, 2));
	x2 =x .* x; y2 = y .* y; xy=x .* y;
	ACtop =double(AC(idx) - lev); %subtract threshold
if debug, AC1=ones(size(AC)); ACtop=double(AC1(idx)); end %regular ellipse, testing
	s=regionprops(b,'MajorAxisLength','MinorAxisLength','Centroid', ...
		'Orientation', 'Area');
	wAC.n =sum(ACtop); %total volume
	wAC.cnt=numel(idx);
	if k>0, wAC.regprops=s(k); else wAC.regprops=s(1); end
	if flipy, wAC.regprops.Orientation=-wAC.regprops.Orientation; end

	%raw stats; did NOT add unit pixel of 1/12 (see REGIONPROPS)
	ubn=1; %biased estimator (population average also estimated)
	if wAC.cnt>3, ubn = wAC.cnt/(wAC.cnt - 1); end %correction for unbiased sample variance
	wAC.varx =ubn*(sum(ACtop .* x2)/wAC.n - (sum(ACtop .* x))^2/(wAC.n)^2);
	wAC.vary =ubn*(sum(ACtop .* y2)/wAC.n - (sum(ACtop .* y))^2/(wAC.n)^2);
	wAC.varxy =ubn*(sum(ACtop .* xy)/wAC.n - (sum(ACtop .* x)*sum(ACtop .* y))/(wAC.n)^2);
		meps=0; %prevent imaginary numbers (varx, vary should never be negative)
		if wAC.varx<meps, wAC.varx=0; end
		if wAC.vary<meps, wAC.vary=0; end
	wAC.cen =[sum(x) sum(y)] / numel(x);
	wAC.wcen =[sum(ACtop .* x) sum(ACtop .* y)] / wAC.n;
	common=sqrt((wAC.varx - wAC.vary)^2 + 4*wAC.varxy^2);
	wAC.rot.majvar=(wAC.varx + wAC.vary + common)/2; %eigenvalues of Cov matrix
	wAC.rot.minvar=(wAC.varx + wAC.vary - common)/2;

% 	wAC.varx =minClip(wAC.varx,1e-4);
% 	wAC.vary =minClip(wAC.vary,1e-4);
% 	wAC.varxy =minClip(wAC.varxy,1e-4);
	num =2.0*wAC.varxy; denom=(wAC.vary - wAC.varx);
	if num==0 && denom==0,
		wAC.angle=NaN; %could use NaN instead here
	else
		wAC.angle =atan2(num, denom)/2; %radians, CCW
%		wAC.angle2 =atan(num/denom) / 2; %radians, CCW
		if wAC.varx < wAC.vary, wAC.angle=wAC.angle+pi/2; end %rot90 if 2nd deriv negative
		if wAC.angle > pi/2, wAC.angle=wAC.angle-pi; end %remove pi periodicity
		if wAC.angle < -pi/2, wAC.angle=wAC.angle+pi; end
	end
	if flipy, wAC.angle=-wAC.angle; end

		% %====CODE FROM REGIONPROPS====
		% % subtract centroid from positions (i.e. Central Moment)
		% xbar = stats(k).Centroid(1);
		% ybar = stats(k).Centroid(2);
		% x = list(:,1) - xbar;
		% y = -(list(:,2) - ybar); % This is negative for the
		% % orientation calculation (measured in the counter-clockwise direction).
		% 
		% N = length(x);
		% % Calculate normalized second central moments for the region. 1/12 is
		% % the normalized second central moment of a pixel with unit length.
		% uxx = sum(x.^2)/N + 1/12;
		% uyy = sum(y.^2)/N + 1/12;
		% uxy = sum(x.*y)/N;
		%
		% % Calculate major axis length, minor axis length, and eccentricity.
		% common = sqrt((uxx - uyy)^2 + 4*uxy^2);
		% stats(k).MajorAxisLength = 2*sqrt(2)*sqrt(uxx + uyy + common);
		% stats(k).MinorAxisLength = 2*sqrt(2)*sqrt(uxx + uyy - common);
		% stats(k).Eccentricity = 2*sqrt((stats(k).MajorAxisLength/2)^2 - ...
		% 	(stats(k).MinorAxisLength/2)^2) / stats(k).MajorAxisLength;
		% 
		% % Calculate orientation.
		% if (uyy > uxx)
		% 	num = uyy - uxx + sqrt((uyy - uxx)^2 + 4*uxy^2);
		% 	den = 2*uxy;
		% else
		% 	num = 2*uxy;
		% 	den = uxx - uyy + sqrt((uxx - uyy)^2 + 4*uxy^2);
		% end
		% if (num == 0) && (den == 0)
		% 	stats(k).Orientation = 0;
		% else
		% 	stats(k).Orientation = (180/pi) * atan(num/den);
		% end
else %no regions above threshold
	wAC.n =0; %total count
	wAC.regprops=s; %is empty
	wAC.varx =NaN;
	wAC.vary =NaN;
	wAC.varxy =NaN;
	wAC.cen =[NaN NaN];
	wAC.wcen =[NaN NaN];
	wAC.angle=NaN;
end
	%rotated ellipse using weighted stats
	rot90flag=0;
	if isnan(wAC.angle),
		wAC.rot.majvar=wAC.varx; wAC.rot.minvar=wAC.vary; %same as orient=0
	else %confirm that major axis properly identified via 2nd derivative
		ang=wAC.angle;
		wAC.rot.angle2=ang;
		if flipy, ang=-ang; end %unflip the prior flip
		wAC.rot.majvar2 =(cos(ang))^2 * wAC.varx + (sin(ang))^2 * wAC.vary - ...
			2*sin(ang)*cos(ang)*wAC.varxy;
		wAC.rot.minvar2 =(sin(ang))^2 * wAC.varx + (cos(ang))^2 * wAC.vary + ...
			2*sin(ang)*cos(ang)*wAC.varxy;
		if wAC.rot.minvar2 > wAC.rot.majvar2, %90-deg off
			rot90flag=1;
			wAC.angle=wAC.angle + pi/2;
			if wAC.angle > pi/2, wAC.angle=wAC.angle - pi; end
			temp=wAC.rot.majvar2; wAC.rot.majvar2=wAC.rot.minvar2; wAC.rot.minvar2=temp;
		end
	end
	wAC.rot.Orientation =wAC.angle*180/pi; %convert to degrees
	wAC.rot.majstd =sqrt(wAC.rot.majvar);
	wAC.rot.minstd =sqrt(wAC.rot.minvar);
	wAC.rot.MajorAxisLength =4*wAC.rot.majstd;
	wAC.rot.MinorAxisLength =4*wAC.rot.minstd;
	wAC.rot.Centroid =wAC.wcen;
if debug && rot90flag
	disp('WARNING: bad orientation; Entering debugging mode (type "return" or "dbquit" to exit).');
	rot90flag, wAC.regprops, wAC.rot, wAC
	keyboard;
elseif rot90flag && ~debug && ~suppressWarn_wACAnis,
	disp('WARNING: bad orientation: tell Scot.');
end
end

function cl=minClip(cl,lim)
if nargin<2, lim=1e-4; end
if cl>-lim & cl<lim, cl=0; end
end
