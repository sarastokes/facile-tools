classdef SpectraViewer < handle

    properties
        fluorophore
        laser
        filterName
        filterSpectra

        figureHandle
        axHandle
    end

    properties (Constant, Hidden)
        FILTER_DIR = [fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))),...
            filesep, 'data', filesep, 'filters'];
        FLUORO_DIR = [fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))),...
            filesep, 'data', filesep, 'fluorophores'];
    end

    methods
        function obj = SpectraViewer(laserWavelength)
            obj.laser = laserWavelength;
            obj.createUi();
        end
    end

    methods (Access = private)
        function onChangedLaser(obj, src, ~)
            obj.laser = str2double(src.String);

            set(findByTag(obj.axHandle, 'Laser'),...
                'XData', [obj.laser, obj.laser]);
            obj.update();
        end

        function onChangedFilter(obj, src, ~)
            obj.filterName = src.String{src.Value};
            if strcmp(obj.filterName, 'none')
                obj.filterSpectra = [];
            else
                obj.filterSpectra = dlmread([obj.FILTER_DIR, filesep, obj.filterName, '.txt']);
                obj.filterSpectra(:, 2) = 100 * obj.filterSpectra(:, 2);
            end
            obj.update();
        end

        function onChangedFluorophore(obj, src, ~)
            fluoroName = src.String{src.Value};
            if ~strcmp(fluoroName, 'none')
                obj.fluorophore = dlmread([obj.FLUORO_DIR, filesep, fluoroName, '.txt']);
            else
                obj.fluorophore = [];
            end
            obj.update();
        end
    end

    methods (Access = private)
        function update(obj)

            if ~isempty(obj.fluorophore)
                set(findByTag(obj.axHandle, 'Excitation'),...
                    'XData', obj.fluorophore(:, 1), 'YData', obj.fluorophore(:, 2));
                set(findByTag(obj.axHandle, 'Emission'),...
                    'XData', obj.fluorophore(:, 1), 'YData', obj.fluorophore(:, 3));
            end

            if ~isempty(obj.filterSpectra)
                set(findByTag(obj.axHandle, 'Filter'),...
                    'XData', obj.filterSpectra(:, 1), 'YData', obj.filterSpectra(:, 2));

                bound = round(obj.filterSpectra(find(obj.filterSpectra(:, 2) > 10, 1), 1), 1);
                bound = bound - obj.laser;
                set(findByTag(obj.figureHandle, 'LB'), 'String', num2str(bound));
            end

            if isempty(obj.filterSpectra) || isempty(obj.fluorophore)
                return
            end

            F = griddedInterpolant(obj.filterSpectra(:, 1), obj.filterSpectra(:, 2));
            percentAbs = sum(F(obj.fluorophore(:, 1)) .* obj.fluorophore(:, 3)) / sum(obj.fluorophore(:, 3));
            set(findByTag(obj.figureHandle, 'Emit'), 'String', num2str(round(percentAbs, 3)));

            ind = findclosest(obj.fluorophore(:, 1), obj.laser);
            percentExc = obj.fluorophore(ind, 2);
            set(findByTag(obj.figureHandle, 'Excite'), 'String', num2str(round(percentExc, 3)));
        end
    end

    methods (Access = private)
        function createUi(obj)
            obj.figureHandle = figure(...
                'Name', 'Spectra Viewer');
            LM = sbfsem.ui.LayoutManager();

            mainLayout = uix.HBox('Parent', obj.figureHandle);
            obj.axHandle = axes('Parent', uipanel('Parent', mainLayout));
            line(obj.axHandle, [obj.laser, obj.laser], [0 100],...
                'LineWidth', 1.5, 'Color', rgb('violet'));
            line(obj.axHandle, 0, 0,...
                'LineWidth', 1, 'Color', rgb('emerald'),...
                'Tag', 'Excitation');
            line(obj.axHandle, 0, 0,...
                'LineWidth', 1, 'Color', rgb('sky blue'),...
                'Tag', 'Emission');
            line(obj.axHandle, 0, 0,...
                'LineWidth', 1, 'Color', rgb('light red'),...
                'Tag', 'Filter');
            hold(obj.axHandle, 'on');
            xlim(obj.axHandle, [400 750]);
            ylim(obj.axHandle, [0 100]);
            grid(obj.axHandle, 'on');

            uiLayout = uix.VBox('Parent', mainLayout);
            LM.horizontalBoxWithLabel(uiLayout, 'Fluorophore',...
                'Style', 'popup', 'String', obj.populateFluorophores(),...
                'Callback', @obj.onChangedFluorophore);
            LM.horizontalBoxWithLabel(uiLayout, 'Filter',...
                'Style', 'popup', 'String', obj.populateFilters(),...
                'Callback', @obj.onChangedFilter);
            LM.horizontalBoxWithLabel(uiLayout, 'Laser',...
                'Style', 'edit', 'String', num2str(obj.laser),...
                'Callback', @obj.onChangedLaser);

            uix.Empty('Parent', uiLayout);

            LM.horizontalBoxWithLabel(uiLayout, 'Excitation',...
                'Style', 'text', 'FontWeight', 'bold', 'Tag', 'Excite');
            LM.horizontalBoxWithLabel(uiLayout, 'Emission',...
                'Style', 'text', 'FontWeight', 'bold', 'Tag', 'Emit');
            LM.horizontalBoxWithLabel(uiLayout, 'Laser Distance',...
                'Style', 'text', 'FontWeight', 'bold', 'Tag', 'LB');

            set(mainLayout, 'Widths', [-3, -1]);
            figPos(obj.figureHandle, 1.5, 0.5);

            obj.update();
        end

        function f = populateFilters(obj)
            f = getFolderFiles(obj.FILTER_DIR);
            f = ["none"; f(3:end)];
            f = arrayfun(@(x) erase(deblank(x), '.txt'), f);
        end

        function f = populateFluorophores(obj)
            f = getFolderFiles(obj.FLUORO_DIR);
            if ~ispc
                f = strsplit(f, ".txt")';
                for i = 1:numel(f)
                    txt = f(i);
                    f(i) = txt(isletter(txt));
                end
            else

            end
            f = ["none"; f(3:end)];
            f = arrayfun(@(x) erase(deblank(x), '.txt'), f);
        end
    end
end