function out = textcat(varargin)
% TEXTCAT
%
% Description:
%   Concatenate strings or chars or mixture without throwing an error. THe
%   class of the first input is the class of the output.
%
% Syntax:
%   out = textcat(varargin)
%
% History:
%   28Mar2024 - SSP
% -------------------------------------------------------------------------
    argin = varargin;
    if ischar(varargin{1})
        for i = 2:numel(varargin)
            argin{i} = convertCharsToStrings(argin{i});
        end
    elseif isstring(varargin{1})
        for i = 2:numel(varargin)
            argin{i} = convertStringsToChars(argin{i});
        end
    end

