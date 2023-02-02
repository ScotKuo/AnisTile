% Do nonlinear least-squares fitting of arbitrary functions (needs Optimization Toolbox)
%	-- groups and hides the ugliness of using MatLab optimization toolbox while
%	providing error bounds around fitted parameters
% Full usage: ef=lsqfit(x, y, fh, pguess)
%	x,y= data to be fitted
%	fh=function handle to MatLab function to use for fitting (example,
%		fh=@cfz_exponential).  The MatLab function is of the form y=fnc(p,x)
%		where p=vector of parameters, x=vector of independent data, y=resulting
%		function.
%	pguess=initial guess for parameter vector p (see fh above) to start for
%		fitting
% Returns:
%	ef.p=fitted parameters
%	ef.p_err=1 stdev of confidence around parameters (only 68.3% confidence
%		interval if a Gaussian distribution); same as Kaleidagraph
%	ef.chi2=chi-squared of fit
%	ef.pval=probability of random fit (lower better)
%
% SCK 2006_0324l 14_0303 modified for trap/catch

function ef=lsqfit(x, y, fh, guess_p, lb, ub, opt)
% For MatLab2007b:
% opt=optimset('LargeScale','off','LevenbergMarquardt','on','Display','off', ...
% 	'MaxFunEvals',10^7,'MaxIter',10^6,'TolFun',10^(-6));
% opt=optimset('MaxFunEvals',10^7,'MaxIter',10^6,'TolFun',10^(-6));
% [ef.p,resnorm,resid,eflag,outp,lambda,jacob]=lsqcurvefit(fh, guess_p, x, y, [],[],opt);
if nargin<7, opt=[]; end
if nargin<6, ub=[]; end
if nargin<5, lb=[]; end

ef.error=0; ef.MExc=[]; ef.p=[]; ef.p_err=[];
try
	[ef.p,resnorm,~,~,~,~,jacob]=lsqcurvefit(fh, guess_p, x, y, lb, ub, opt);
	npar=length(guess_p); ndat=length(y);
	hess=zeros(npar,npar);
	for i=1:npar, for j=1:npar, %inefficient because this code ignores symmetry of Hessian matrix
			for k=1:ndat, hess(i,j)=hess(i,j)+jacob(k,i)*jacob(k,j); end
		end
	end
	%turn off annoying message for inverting poorly formed matrix
	w_id='MATLAB:nearlySingularMatrix'; warning('off', w_id);
	covar=abs(hess^(-1));
	%warning('on', w_id);
	%DCS=[6.63;9.21;11.34;13.28;15.09;16.81;18.47;20.09;21.67;23.21;24.72;26.22;27.69;29.14;30.58;32;33.41;34.8;36.19;37.57];
	for i=1:npar, ef.p_err(i)=sqrt((resnorm*covar(i,i)/(ndat-npar))); end %1 stdev; matches Kaleidagraph

% 	fit=feval(fh,ef.p,x);
% 	chi=fit - y;
% 	ef.chi2=sum((chi .* chi) ./ fit);
% 	ndeg = ndat - npar - 1; %degrees of freedom
% 	if ndeg>=0,
% 		ef.pval=chi_gamm(ndeg,ef.chi2); %lower pval means less likely that model is due to chance fluctuations.
% 	else
% 		ef.pval=[];
% 	end
catch ME
	ef.error=1; ef.MExc=ME;
end
return

function Q=chi_gamm(ndeg, chi2) %must ndeg>=0
Q=1 - gammainc(chi2/2,ndeg/2);
return
