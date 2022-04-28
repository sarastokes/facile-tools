function showGrid(axHandle, whichDim)
    % SHOWGRID
    % ---------------------------------------------------------------------

    grid(axHandle, 'on');
    switch whichDim
        case 'x'
            set(axHandle, 'YTick', []);
            xTick = get(axHandle, 'XTick');
            if xTick(end) == axHandle.XLim(2)
                set(axHandle, 'XTick', xTick(1:end-1));
            end
        case 'y'
            set(axHandle, 'XTick', []);
            % yTick = get(axHandle, 'YTick');
            % if yTick(end) == axHandle.YLim(2)
            %     set(axHandle, 'YTick', yTick(1:end-1));
            % end
    end
            