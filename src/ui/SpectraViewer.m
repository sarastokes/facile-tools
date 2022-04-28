classdef SpectraViewer < handle

    properties 
        spectra
        numSpectra

        currentSpectra

        lineHandle
        boundHandle1
        boundHandle2
        figureHandle
        axHandle
    end

    methods 
        function obj = SpectraViewer(spectra)
            obj.spectra = spectra;
            obj.numSpectra = numel(spectra);
            obj.currentSpectra = floor(obj.numSpectra/2);

            obj.createUi();
        end
    end

    methods (Access = private)
        function onKeyPress(obj, ~, evt)
            switch evt.Key
                case 'rightarrow'
                    obj.currentSpectra = obj.currentSpectra + 1;
                    obj.onChangeSpectra();
                case 'leftarrow'
                    obj.currentSpectra = obj.currentSpectra - 1;
                    obj.onChangeSpectra();
                case 'uparrow'
                    obj.showBounds();
            end
        end

        function showBounds(obj)
            toggleProperty(obj.boundHandle1, 'Visible');
            toggleProperty(obj.boundHandle2, 'Visible');
        end

        function onChangeSpectra(obj)

            iSpectra = obj.spectra{obj.currentSpectra};
            set(obj.lineHandle, 'XData', iSpectra(:, 1), ...
                'YData', iSpectra(:,2));

            h = findByTag(obj.figureHandle, 'InfoBox');
            set(h, 'String', sprintf('Spectra %u of %u', ...
                obj.currentSpectra, obj.numSpectra));
        end
    end

    methods (Access = private)
        function createUi(obj)
            obj.figureHandle = figure(...
                'Name', 'SpectraViewer',...
                'KeyPressFcn', @obj.onKeyPress);
            mainLayout = uix.VBox('Parent', obj.figureHandle,...
                'BackgroundColor', 'w');
            uicontrol(mainLayout, 'Style', 'text', ...
                'String', sprintf('Spectra %u of %u', obj.currentSpectra, obj.numSpectra),...
                'Tag', 'InfoBox');
            obj.axHandle = axes('Parent', uipanel(mainLayout));
            hold(obj.axHandle, 'on');
            grid(obj.axHandle, 'on');
            xlim(obj.axHandle, [330 820]);

            firstSpectra = obj.spectra{1};
            obj.boundHandle1 = line(obj.axHandle, ...
                firstSpectra(:, 1), firstSpectra(:,2),...
                'Color', [0.4 0.4 0.4], 'LineWidth', 1.5);
            lastSpectra = obj.spectra{end};
            obj.boundHandle2 = line(obj.axHandle, ...
                lastSpectra(:, 1), lastSpectra(:,2),...
                'Color', [0.4 0.4 0.4], 'LineWidth', 1.5);
            iSpectra = obj.spectra{obj.currentSpectra};
            obj.lineHandle = line(obj.axHandle, ...
                iSpectra(:, 1), iSpectra(:,2), ...
                'Color', [0.5 0.5 1], 'LineWidth', 2);

            set(mainLayout, 'Heights', [20 -1]);
        end
    end
end