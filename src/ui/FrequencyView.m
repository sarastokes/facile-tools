classdef FrequencyView < handle

    properties
        parentHandle
        axHandle
        freqLine
    end

    methods
        function obj = FrequencyView(parentHandle)
            obj.parentHandle = parentHandle;
            obj.createUi();
            addlistener(obj.parentHandle, 'RoiChanged', @obj.onRoiChanged);
        end

        function onRoiChanged(obj, ~, ~)
            warning('off', 'MATLAB:callback:error');
            avgSignal = getAvgSignal(obj.parentHandle);
            if isempty(avgSignal)
                return
            end
            [p, f] = signalPowerSpectrum(avgSignal, 25);
            f0 = p(1);
            idx = find(f > 0.27 & f < 0.3);
            [noisePeak, peakIdx] = max(p(idx));
            totalF = sum(p(f < 12.5));
            titleTxt = sprintf('F_0=%.2f,   Fn=%.2f at %.2f Hz (%.2f%%),   F=%.2f',...
                f0, noisePeak, f(idx(peakIdx)), 100*noisePeak/totalF, totalF);
            title(obj.axHandle, titleTxt, 'Interpreter', 'tex', 'FontSize', 10);
            set(obj.freqLine, 'XData', f, 'YData', p);
        end

        function createUi(obj)
            obj.axHandle = axes('Parent', figure());
            hold(obj.axHandle, 'on');
            grid(obj.axHandle, 'on');
            set(obj.axHandle, 'XScale', 'log');

            obj.freqLine = area([0 0], [0 0], 'LineWidth', 1,...
                'EdgeColor', mycolors('peacock'), 'FaceAlpha', 0.3,...
                'FaceColor', mycolors('peacock'));
            xlim(obj.axHandle, [0.01 12.5]);
            xlabel(obj.axHandle, 'Frequency (Hz)');
            obj.axHandle.Parent.Position(3:4) = obj.axHandle.Parent.Position(3:4)/1.5;
        end
    end
end