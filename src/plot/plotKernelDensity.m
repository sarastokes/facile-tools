function [out, h, bw] = plotKernelDensity(data, bw, opts)

    arguments
        data                        double
        bw                          double      {mustBeScalarOrEmpty} = []
        opts.?matlab.graphics.chart.primitive.Line
        opts.LineWidth                                                = 1
        opts.Parent                                                   = []
    end


    if isempty(bw)
        [yPDF, xPDF, bw] = kde(data);
    else
        [yPDF, xPDF, bw] = kde(data, "Bandwidth", bw);
    end

    out = [xPDF(:), yPDF(:)];

    if isempty(opts.Parent)
        opts.Parent = axes('Parent', figure());
    end
    optsCell = namedargs2cell(opts);

    hold(opts.Parent, 'on');
    h = plot(opts.Parent, xPDF, yPDF, optsCell{:});