function reportSignificance(p, h, txt)
% REPORTSIGNIFICANCE
%
% Description:
%   Convenience function for printing result to the command line
%
% Syntax:
%   reportSignificance(p, h)
%
% Inputs:
%   p               (1,1) double
%       The p-value of the test
%   h               (1,1)   logical
%       Whether the null hypothesis can be rejected
%   txt             (1,1)   string
%       Optional description of statistical test
%
% History:
%   05Mar2024 - SSP
% -------------------------------------------------------------------------
    
    arguments
        p       (1,1)       
        h       (1,1)       
        txt     (1,1)       string      = ""
    end

    if ismember(p, [0 1]) && ~ismember(h, [0 1])
        rejectNull = p;
        p = h;
    else
        rejectNull = h;
    end

    if txt ~= ""
        txt = txt + ": ";
    end

    if rejectNull
        fprintf('\t%s Significant (p = %s)\n', txt, num2str(p));
    else
        fprintf('\t NOT significant (p = %s)\n', txt, num2str(p));
    end
