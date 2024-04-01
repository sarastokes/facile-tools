function checkLookupTable(lookupTable, halfWeights)

    figure(); hold on;
    plot(lookupTable.Voltage, lookupTable.R, '-o', "Color", rgb('red'));
    plot(lookupTable.Voltage, lookupTable.G, "-o", "Color", rgb("green"));
    plot(lookupTable.Voltage, lookupTable.B, "-o", "Color", rgb("blue"));

    ylim([0 ceil(max(ylim()))]); xlim([0 5]);

    plot([0 5], halfWeights(1)*lookupTable.R(end)+[0 0], "--", "Color", lighten(rgb("red"),0.5));
    plot([0 5], halfWeights(2)*lookupTable.G(end)+[0 0], "--", "Color", lighten(rgb("green"),0.5));
    plot([0 5], halfWeights(3)*lookupTable.B(end)+[0 0], "--", "Color", lighten(rgb("blue"),0.5));

    xlabel("Voltage (V)");
    ylabel("Power (uW)");

    title("LED Output Functions");