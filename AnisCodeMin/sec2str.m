% Sec2Str(v,prec) converts value seconds to string representation with truncated precision (default=2 digits)
%
% SCK 2008_0724

function s=sec2str(v,prec)
if nargin<2, prec=2; end
if nargin<1, error('sec2str: needs argument.'); end
tags={' s',' m',' h',' d',' w'};

if v<=0, s=[num2str(v) tags{1}]; return; end
base=[1 60 60 24 7];
cbase=cumprod(base);
i=find(v>=cbase, 1, 'last');
if isempty(i), i=1; end
v2=v/cbase(i);
s=[num2str(round(v2*10^prec)/(10^prec)) tags{i}];
return
