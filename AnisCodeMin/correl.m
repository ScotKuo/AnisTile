%corr=Correl(u,v) returns correlation (Pearson r and Fisher z) and probablity of
%	significance of correlation (vs random as null hypothesis); excludes
%	any NaN in pairings of u,v.
%Returns: corr.r (Pearson's r, not R^2), corr.z (Fisher's z transform)
%	corr.n (number of valid pairs), corr.prob (t-distrib, 2-tailed; see NumerC)
%	corr.prob2 (alternative calculation of corr.prob without using beta-inc
%	function, but erfcc approx)
%
% SK 15_0430, based on Numerical Recipes in C, section 14.5

function corr=correl(u, v)
	u=u(:); v=v(:); %reshape as single column
	idx= (~isnan(u)) & (~isnan(v)); %remove any pairs that have NaNs
	u=u(idx); v=v(idx); n=numel(u); corr.n=n;
	if n<2,
		corr.r=NaN; corr.z=NaN;
		corr.prob=NaN; corr.prob2=NaN;
	else
		du=(u-mean(u)); dv=(v-mean(v));
		sxx=sum(du.*du); syy=sum(dv.*dv); sxy=sum(du.*dv);
		corr.r=sxy/sqrt(sxx*syy); %Pearson's r; see NumerC section 14.5
		tiny=1.0e-20;
		corr.z=0.5*log((1.0+corr.r+tiny)/(1.0-corr.r+tiny)); %Fisher's z transform
		df=n-2;
		t=corr.r*sqrt(df/((1.0-corr.r+tiny)*(1.0+corr.r+tiny)));
		xb=real(df/(df+t*t));
		if xb<=0 || isnan(xb) || xb>=1,
			corr.prob=NaN; corr.prob2=NaN;
		else
			corr.prob=betainc(xb, 0.5*df, 0.5);
			corr.prob2=erfcc(abs(corr.z*sqrt(n-1))/1.4142136);
		end
	end
end

function val=erfcc(x)
	z=abs(x); t=1.0/(1.0+0.5*z);
	val=t*exp(-z*z-1.26551223+t*(1.00002368+t*(0.37409196+t*(0.09678418+t*(-0.18628806+ ...
		t*(0.27886807+t*(-1.13520398+t*(1.48851587+t*(-0.82215223+t*0.17087277)))))))));
	if x<0, val=2.0-val; end
end