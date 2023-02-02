function ostr=left(str,len)
% left(str,len) does the standard string truncation, if str too long
%	> str can also be an array of strings
% RETURN: ALWAYS returns strings (empty, if necessary).
%
% SK 15_0211

if iscell(str),
	for i=1:numel(str), ostr{i}=myleft(str{i},len); end
elseif ischar(str),
	ostr=myleft(str,len);
else ostr='';
end

function ost=myleft(ist,ln)
	ost='';
	if ischar(ist), ost=ist; end
	if numel(ost)>ln, ost=ost(1:ln); end
end

end
