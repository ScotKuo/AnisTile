function outstring = format_datum(datum, sigma, oformat, precision, pmformat, tex)
%Create string showing uncertainty of a datum estimate
%FORMAT_DATA: converts data into string showing uncertainty, either in +-
% format or parenthetical; great for scietific/exponential notation
%
%   USAGE: outstring = format_data(datum, sigma, [output_format], [precision],
%		[pmformat], [tex])
%
%   datum        : measured value
%   sigma        : uncertainty in said value
%   precision    : number of digits of sigma shown
%   output_format: 'n'ormal, 's'cientific, 'e'ngineering, or 'm'etric
%         normal     : 12.35 +- .47 -> 12.4(5)     (precision = 1)
%         scientific : 12.23 +- .04 -> 1.223(4)E+1 (precision = 1)
%         engineering: 12234 +- 320 -> 12.23(32)E+3(precision = 2)
%         metric     : 1235.3 +- 2.8 -> 1.235(3) k (precision = 1)
%   tex          : flag for latex-style output
%   
%   DEFAULTS: output_format is normal (-3<log10()<3) or scientific
%             precision = 1 (auto-increment)
%			  pmformat on (plus-minus formatting)
%             tex formatting off
%
%   EXAMPLES: >> format_data(23.45E-9,.34E-9,2,'e')
%             ans = 23.45(34)E-9
%             >>format_data(23.45E-9,.34E-9,2,'e','tex')
%             ans = 23.45(34)\times10^{-9}
%             >> format_data(23.43E9,34.6E6,2,'s')
%             ans = 2.3430(35)E+10
%

% author: peter mao, 20 Feb 2006
%	>Problem: Does not handle sigma>>datum correctly {SK: too much to rewrite...}
% SCK 14_0112: >changed order of arguments and defaults
%	>added traditional +- pmformat capability, default=true (sigma_for_display2; outstring2)
%	>added auto-increment on precistion if uncertainty has leading digit '1'

  outstring = ''; %null output if something goes wrong
  outstring2='';

  %DEFAULTS
  autoInc=0; %increment precision
  if ~exist('precision','var'), precision = 1; autoInc=1; end
  if ~exist('pmformat','var'), pmformat=1; else pmformat=0; end
  if ~exist('tex','var'), tex=0; else tex=1; end
  if exist('oformat','var'), 
    if ( ~ischar(oformat) || isempty(regexp(oformat,'[nsem]','once')) )
      disp(['output format string must be ''n'' (default), ''s'', '...
	    '''e'', or ''m''']);
      return;
    end
  else
    oformat = 'n'; %default
	lim=1000;
	if datum>=lim | sigma>=lim | datum<=1/lim | sigma<=1/lim, 
		oformat='s'; end
  end

  % START REAL WORK HERE
  sign_datum = sign(datum);
  datum = abs(datum);
  % get the 10's place of each number, ie order of magnitude
  exp_datum = floor(log10(datum));
  exp_sigma = floor(log10(sigma));

  %increment precision if lead digit of sigma is '1'
  if autoInc, ss=num2str(sigma/10^exp_sigma); %lead digit
	  %ss=num2str(round(sigma/10^exp_sigma)); %consider rounded lead digit
	  if ss(1)=='1', precision=precision+1; end
%disp(['precision=' int2str(precision) '; sigma=' ss])
  end
  
  % use switch to determine the 10's exponent shift for each format
  if oformat == 'n'
    exp_shift = 0;
  elseif oformat == 's'
    exp_shift = exp_datum;
  elseif oformat == 'e' || oformat == 'm'
    exp_shift = exp_datum - mod(exp_datum,3);
  end
  
  % shift datum and sigma by exp_shift
  datum = datum / 10^exp_shift;
  sigma = sigma / 10^exp_shift;
  exp_datum = exp_datum - exp_shift;
  exp_sigma = exp_sigma - exp_shift;
  % calculate location of the least significant digit
  exp_LSD   = exp_sigma - precision + 1;

  datum_for_display = round( datum / 10^(exp_LSD) ) * 10^(exp_LSD);
  sigma_for_display = round( sigma / 10^(exp_LSD) );
  sigma_for_display2 = round( sigma / 10^(exp_LSD) ) * 10^(exp_LSD); %+-

  % does the datum or signal increment in its log interval? (.99 -> 1.00)
  exp_datum_for_display = floor(log10(datum_for_display));
  exp_sigma_for_display = floor(log10(sigma_for_display));

  fix_datum = (exp_datum_for_display > exp_datum);
  fix_sigma = (exp_sigma_for_display > exp_sigma - exp_LSD);
  
  if fix_datum
    if (oformat == 's')
      %disp('fixdat:s');
      exp_shift = exp_shift + 1;
      datum_for_display = datum_for_display / 10;
	  sigma_for_display2 = sigma_for_display2 /10;
	  exp_sigma = exp_sigma - 1;
      exp_sigma_for_display = exp_sigma_for_display - 1;
      exp_LSD   = exp_LSD - 1;
    elseif ( (oformat == 'e' || oformat == 'm') ...
	     && datum_for_display == 1000)
      %disp('fixdat:e');
      exp_shift = exp_shift + 3;
      datum_for_display = 1;
	  sigma_for_display2 = sigma_for_display2 / 1000;
      exp_sigma = exp_sigma - 3;
      exp_sigma_for_display = exp_sigma_for_display - 3;
      exp_LSD   = exp_LSD - 3;
    end
  end
  
  if fix_sigma
  %disp('fixsigma');
    sigma_for_display = sigma_for_display / 10;
    exp_sigma = exp_sigma + 1;
    exp_LSD   = exp_LSD + 1;
  end

  % set sigma back to original value if any digits are to the left of the 
  % decimal point.
  if (exp_sigma >= 0)
    sigma_for_display = sigma_for_display * 10^(exp_LSD);
  end

  % calculate the format codes and create the displayed values
  format_code = ['%.' num2str(max(0, -exp_LSD)) 'f'];
  disp_sigma2= sprintf(format_code, sigma_for_display2); %+-, no -sign
  if (sign_datum == -1)
    format_code = ['-' format_code];
  end
  disp_datum = sprintf(format_code, datum_for_display);

  if (exp_sigma >= 0 && exp_LSD < 0) % if it straddles the decimal pt.
    format_code = ['%.' num2str(-exp_LSD) 'f'];
  else
    format_code = '%.0f';
  end
  disp_sigma = sprintf(format_code, sigma_for_display );

  outstring = [disp_datum '(' disp_sigma ')'];
  outstring2 = [disp_datum '+-' disp_sigma2];
  if oformat~='n', outstring2=['(' outstring2 ')']; end
  if ( (exp_shift ~= 0) && ( oformat ~= 'm' ) )
    if tex, 
      exponent_string = '\times10^{';
      close_string = '}';
    else
      if (exp_shift > 0)
	exponent_string = 'E+';
      else
	exponent_string = 'E';
      end
      close_string = '';
    end
    outstring = [ outstring exponent_string num2str(exp_shift) close_string ];
    outstring2 = [ outstring2 exponent_string num2str(exp_shift) close_string ];
  end
  if ( oformat == 'm' )
    outstring = [ outstring ' ' metric_symbol(exp_shift) ];
    outstring2 = [ outstring2 ' ' metric_symbol(exp_shift) ];
  end
%disp(['output:' outstring '; ' outstring2])
if pmformat, outstring=outstring2; end
  
function msym = metric_symbol(exponent)
  
  switch exponent
   case 24, msym = 'Y';
   case 21, msym = 'Z';
   case 18, msym = 'E';
   case 15, msym = 'P';
   case 12, msym = 'T';
   case 9,  msym = 'G';
   case 6,  msym = 'M';
   case 3,  msym = 'k';
   case 0,  msym = '';
   case -3, msym = 'm';
   case -6, msym = '\mu';
   case -9, msym = 'n';
   case -12,msym = 'p';
   case -15,msym = 'f';
   case -18,msym = 'a';
   case -21,msym = 'z';
   case -24,msym = 'y';
   otherwise
    msym = ['e' num2str(exponent)];
  end
  
  %for debugging
  %disp(['exp_sigma: ' num2str(exp_sigma) ...
  %	   '  exp_LSD: ' num2str(exp_LSD) ...
  %	  '  exp_s_f_d:' num2str(exp_sigma_for_display) ]);
  %disp(num2str(  exp_sigma_for_display > exp_sigma - exp_LSD));