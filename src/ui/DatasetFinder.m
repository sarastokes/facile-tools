classdef DatasetFinder < handle

    properties (SetAccess = private)
        searchDirectory
        files

        Figure
        ListBox
    end

    methods
        function obj = DatasetFinder(searchDirectory)
            obj.searchDirectory = searchDirectory;

            obj.createUi();
        end
    end

    methods (Access = private)
        function findDatasets(obj)
            files = deblank(string(ls(obj.searchDirectory)));
            %files = files(multicontains(files, {'MC0', '.mat'}));
            obj.files = files(startsWith(files, 'MC0') & endsWith(files, '.mat'));
        end

        function createUi(obj)

            obj.Figure = uifigure();
            obj.ListBox = uilistbox(obj.Figure);
        end

    end
end