% CONNECTTOIMAGEJ
%
% Description:
%   Check whether ImageJ is running and if not connect
%
% Requires:
%   - User preferences file with 'FijiScripts' set
%   - FIJI with ImageJ-MATLAB plugin 
%
% History:
%   24Oct2021 - SSP
%   29Oct2021 - SSP - Removed hard-coded directories, macro installs
%   03Nov2021 - SSP - Coverage for situations where ImageJ was open before
%   27Jun2023 - SSP - Changed preference name to match new AOData name
% -------------------------------------------------------------------------

try 
    % Previous ImageJ connection
    if isempty(ij.IJ.getInstance())
        fijiDir = getpref('AOData', 'FijiScripts'); 
        addpath(fijiDir);
        ImageJ;
    end
catch
    % No previous ImageJ connection
    try 
        fijiDir = getpref('AOData', 'FijiScripts'); 
    catch
        error('No FijiScripts preference found! See README');
    end
    addpath(fijiDir);
    ImageJ;
end
