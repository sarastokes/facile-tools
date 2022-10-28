function x = getUUID()
    % GETUUID
    %
    % Description:
    %   Return a unique identifier
    %
    % Syntax:
    %   x = getUUID()
    %
    % History:
    %   28Jan2022 - SSP
    % ---------------------------------------------------------------------
    
    x = char(java.util.UUID.randomUUID);