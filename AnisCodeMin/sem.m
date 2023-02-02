%c=sem(x,p95) -- Computes the SEM *OR* the 95% confidence interval
%  default (p95 empty or =0): return std(x)/sqrt(length(x))
%  else correct for the finite length of data with the Student's t distribution
%Corrected by SCK, 2002_0614; Originally by JLM

%Performs explicit linear interpolation to t-distribution.  Could be redone using interp1().
function ansr = sem(x,p95)
if nargin>1 & isempty(p95), p95=0; end
if nargin<2, p95=0; end

vec=find(~isnan(x)); %strip NaNs
x=x(vec);

s = std(x);
num = length(x);
nu = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21   30 40 50 60 10e4];
t95 = [6.314 2.92 2.353 2.132 2.015 1.943 1.895 1.860 1.833 1.813 1.796 1.782 1.771 1.761 1.753 1.746 1.740 1.734 1.729 1.725 1.721 1.697 1.684 1.676 1.671 1.645];
t90 = [3.078 1.886 1.638 1.533 1.476 1.440 1.415 1.397 1.383 1.372 1.363 1.356 1.35 1.345 1.341 1.337 1.333 1.330 1.328 1.325 1.323 1.310 1.303 1.299 1.296 1.282];
t975 = [12.706 4.303 3.183 2.776 2.571 2.447 2.365 2.306 2.262 2.228 2.201 2.179 2.160 2.145 2.131 2.120 2.110 2.101 2.093 2.086 2.080 2.042 2.021 2.009 2.0 1.96];
% Jim's original t95 is WRONG-- these are t975! == 1.96 stdev; but it is correct for calc 95% conf interval
% Jim: t95 = [12.706 4.303 3.183 2.776 2.571 2.447 2.365 2.306 2.262 2.228 2.201 2.179 2.160 2.145 2.131 2.120 2.110 2.101 2.093 2.086 2.080 2.042 2.021 2.010 2.0 1.96];

if ~p95,
	ansr = s/sqrt(num);
	return;
end

match = 'n';
for j = 1:length(nu)
	if num == nu(j)
		match = 'y';
		%ansr = t95(j)*s/sqrt(num);
		ansr = t975(j)*s/sqrt(num); %correct way to calculate 95% conf interval if two-tailed
	end
end

if match == 'n'
	index = 1;
	while nu(index) < num
		index = index+1;
	end;
	x = [nu(index-1) nu(index)];
	%y = [t95(index-1) t95(index)];
	y = [t975(index-1) t975(index)]; %correct way to calculate 95% conf interval if two-tailed
	p = polyfit(x,y,1);
	ansr = polyval(p,num)*s/sqrt(num);
end


