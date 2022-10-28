function S = kv2map(varargin)
    % KV2MAP
    %   
    % Description:
    %   Maps multiple keys and values to a containers.Map
    %
    % Syntax:
    %   S = kv2map(S, 'key', value, 'key', value);
    %   S = kv2map('key', value, 'key', value);
    %
    % Inputs:
    %   If first argument is a containers.Map, key/values will be added to
    %   it, otherwise a new containers.Map is created
    %
    % History:
    %   17Jan2022 - SSP
    % ---------------------------------------------------------------------

    if isa(varargin{1}, 'containers.Map')
        S = varargin{1};
        startIdx = 3;
    else
        S = containers.Map();
        startIdx = 2;
    end
    for i = startIdx:2:numel(varargin)
        S(varargin{i-1}) = varargin{i};
    end