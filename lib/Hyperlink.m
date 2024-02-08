function [varargout] = Hyperlink(target, textToDisplay, rowNum)
%HYPERLINK hyperlink
%   HYPERLINK(TARGET, TEXTTODISPLAY) displays a hyperlink pointing to
%   TARGET, displaying the text TEXTTODISPLAY.
%
%   HYPERLINK determines whether TARGET is a URL. If it is, then the
%   hyperlink displayed points to that address. Otherwise, TARGET is
%   interpreted as either a MATLAB command or a link to some MATLAB code
%   in the editor.
%
%	HYPERLINK(TARGET, TEXTTODISPLAY, ROWNUM) displays a hyperlink
%   pointing to some MATLAB code in the editor. The target m-file is
%   specified by TARGET, the row to select is ROWNUM and the text to
%   display is TEXTTODISPLAY.
%
%	STR = HYPERLINK(TARGET, ...) does not display the hyperlink, but it
%	returns it in the string STR.
%
%	%Example %Compute a robust estimation of the standard deviation
%   x = [rand(99,1); 70];  %An outlier is added
%   sigma = 1.4826 * mad(x, 1); %robust estimation of the std deviation
%
%   disp('The motivation for this calculation is explained here');
%   Hyperlink('https://en.wikipedia.org/wiki/Median_absolute_deviation', 'Wiki');
%
%   disp([sprintf('\n') 'Another common measure of statistical dispersion ' ...
%   'is the interquartile range']);
%   str = Hyperlink('iqr.m', 'iqr', 2);
%   disp(['See the MATLAB function ' str sprintf('\n')]);
%
%   f = @(x) 1.4826 * mad(x, 1);  %the MATLAB code that will be executed
%   str1 = Hyperlink('f(x)', 'here'); %shortcut to execute some MATLAB code
%   str2 = Hyperlink('std(x)', 'here');
%   disp([sprintf('\n') 'Compute the robust standard deviation clicking ' ...
%   str1]);
%   disp(['Compute the classic standard deviation clicking ' str2]);
%
%	See also DISP
%	Author: Scalseggi Michele
%	email: michele.scalseggi@gmail.com
%	Creation: 22/07/2016; Last revision: 23/07/2016
%
% References:
%
% [1] http://blogs.mathworks.com/community//2007/07/09/printing-hyperlinks-to-the-command-window/
%List of the most common URL protocols
protocolList = {...
    'file';...
    'http';...
    'https';...
    'ftp';...
    'ftps';...
    };
%Argument checks 1
narginchk(2, 3);
nargoutchk(0, 1);
%Argument checks 2
assert(isa(target, 'char'), 'target is type %s, not char.',class(target));
assert(isa(textToDisplay, 'char'), 'textToDisplay is type %s, not char.',class(textToDisplay));
if nargin==3
    assert(isnumeric(rowNum), 'rowNum is not numeric.');
end

%Regular expression
expr = ['^(' strjoin(protocolList, '|') ')://|^www.'];
if nargin==3 %Point to some MATLAB code, in the editor
    fullTarget = which(target);
    if verLessThan('matlab', 'R2009b')
        str = ['<a href="matlab:opentoline(''' fullTarget ''', ' num2str(rowNum) ');">' textToDisplay '</a>'];
    else
        str = ['<a href="matlab:matlab.desktop.editor.openAndGoToLine(''' fullTarget ''', ' num2str(rowNum) ');">' textToDisplay '</a>'];
    end
else  %Shortcut to a web page or shortcut to execute MATLAB commands
    %Create the link to either a URL or a m-code
    if isempty(regexp(target, expr, 'once'))
        prefix = 'matlab:';
    else
        prefix = '';
    end
    str = ['<a href="' prefix target '">' textToDisplay '</a>'];
end
if nargout==1
    varargout{1} = str;
else
    disp(str);
end
end