function mytitle(varargin)

    if ishandle(varargin{1})
        title(varargin{1}, varargin{2:end}, 'Interpreter', 'none');
    else
        title(varargin{:}, 'Interpreter', 'none');
    end