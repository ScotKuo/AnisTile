function [parseResult,p] = xmlreadstring(stringToParse,varargin)
%XMLREADSTRING Modified XMLREAD function to read XML data from a string.
% >>SCK downloaded 15_0130 from (MathWorks Support Team:
%	http://www.mathworks.com/matlabcentral/answers/101632-how-can-i-use-a-function-such-as-xmlread-to-parse-xml-data-from-a-string-instead-of-from-a-file-i
% >>NOTE: returns a JAVA structure.  See xml_sread which calls this
%   function.  The rest of xml_sread converts the JAVA structure into MatLab.
% Author: Luis Cantero.
% The MathWorks.
%
% SCK 15_0130: added try/catch for empty string or other errors; force
%	empty return (means error)

p = locGetParser(varargin);
locSetEntityResolver(p,varargin);
locSetErrorHandler(p,varargin);

% Parse and return.
parseStringBuffer = java.io.StringBufferInputStream(stringToParse);
	try
		parseResult = p.parse(parseStringBuffer);
	catch MExc
		parseResult=[];
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = locGetParser(args)

p = [];
for i=1:length(args)
    if isa(args{i},'javax.xml.parsers.DocumentBuilderFactory')
        javaMethod('setValidating',args{i},locIsValidating(args));
        p = javaMethod('newDocumentBuilder',args{i});
        break;
    elseif isa(args{i},'javax.xml.parsers.DocumentBuilder')
        p = args{i};
        break;
    end
end

if isempty(p)
    parserFactory = javaMethod('newInstance',...
        'javax.xml.parsers.DocumentBuilderFactory');
        
    javaMethod('setValidating',parserFactory,locIsValidating(args));
    %javaMethod('setIgnoringElementContentWhitespace',parserFactory,1);
    %ignorable whitespace requires a validating parser and a content model
    p = javaMethod('newDocumentBuilder',parserFactory);
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf=locIsValidating(args)
tf=any(strcmp(args,'-validating'));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function locSetEntityResolver(p,args)
for i=1:length(args)
    if isa(args{i},'org.xml.sax.EntityResolver')
        p.setEntityResolver(args{i});
        break;
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function locSetErrorHandler(p,args)
for i=1:length(args)
    if isa(args{i},'org.xml.sax.ErrorHandler')
        p.setErrorHandler(args{i});
        break;
    end
end
end