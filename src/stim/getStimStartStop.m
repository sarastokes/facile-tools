function out = getStimStartStop(dataset, stimName, units, opts)

    arguments
        dataset     (1,1)   ao.core.Dataset
        stimName    (1,:)   char
        units       (1,1)   string {mustBeMember(units, ["frames", "time"])}
        opts.LED    (1,1)   {mustBeInteger, mustBeInRange(opts.LED, 1, 4)} = 4
    end


    [ups, downs] = dataset.getModWindows(stimName, opts.LED, units=="frames");
    [ups, downs] = bounds([ups(:); downs(:)]);
    out = [ups, downs];
