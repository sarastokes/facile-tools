function F2 = calcSpatialFilter(D1, D2, F1, wavelength)
% CALCSPATIALFILTER
%
% DESCRIPTION:
%   Calculate approximate focal length of 2nd lens in spatial filter
%   and ideal pinhole diameter.
%
% SYNTAX:
%   F2 = calcSpatialFilter(D1, D2, F1, wavelength)
%
% EXAMPLE:
%   Using the C560TME-B aspheric lens for the input which has a clear
%   clear aperture of 5.1 mm and a focal length of 13.9 mm. Assuming the
%   light source is 650 nm diode laser and beam diameter (1/e2) at the input
%   is 1.2 mm. This function should predict an optimal pinhole size of 19.5
%   microns based on a XX micron diffraction-limited spot size and an output
%   lens focal length of approximately 50 mm.
%
%   Based on this, the P20K pinhole and LA1131-B N-BK7 plano-convex lens
%   would be good choices.
%
% RESOURCES:
%   Based on the Thorlabs tutorial on spatial filters:
%   https://www.thorlabs.com/newgrouppage9.cfm?objectgroup_id=10768
%
% HISTORY:
%   07Jul2024 - SSP
% --------------------------------------------------------------------------

    arguments
        D1              (1,1)   double  {mustBePositive}
        D2              (1,1)   double  {mustBePositive}
        F1              (1,1)   double  {mustBePositive}
        wavelength      (1,1)   double  {mustBePositive}
    end

    inputRadius = D1 / 2;
    outputRadius = D2 / 2;

    % Diffraction limited spot size in microns
    D = (wavelength * 1e-9) * F1 / inputRadius;
    % Pinhole should be approximately 30% larger than D
    pinholeSize = 1.3 * D * 1e6;
    disp(pinholeSize)
    fprintf('Pinhole should be approximately %.2f microns\n', pinholeSize);

    %theta = rad2deg(inputRadius / F1);
    F2 = outputRadius / tan(inputRadius / F1);

    maxSize = max([D1, D2]);

    figure(); hold on;
    title(sprintf('Spatial filter calculation for %u nm', wavelength));
    plot([0 F1+F2], [0 0], 'k', 'LineWidth', 2);
    plot([0 0], [0 inputRadius], 'k', 'LineWidth', 2);
    plot([F1+F2 F1+F2], [0 outputRadius], 'k', 'LineWidth', 2);
    area([0 F1 F1+F2], [inputRadius 0 outputRadius], ...
        'EdgeColor', 'k', 'FaceColor', wavelength2color(wavelength), ...
        'LineWidth', 2, 'FaceAlpha', 0.3);

    text(F1/2, -0.01*maxSize, sprintf("f_1 = %.2f mm", F1));
    text(F1 + F2/2, -0.01*maxSize, sprintf("f_2 = %.2f mm", F2));
    text(F1, maxSize, sprintf("Pinhole \approx %.2f", pinholeSize))
    set(findall(gcf, 'Type', 'text'), "FontName", "Arial",...
        "HorizontalAlignment", "center", "VerticalAlignment", "top");

    maxX = max(xlim()); xT = xticks();
    xlim(maxX * [-0.1, 1.1]);
    xticks(xT(xT >= 0 & xT <= maxX));

    maxY = max(ylim()); yT = yticks();
    ylim(maxY * [-0.1, 1.1]);
    yticks(yT(yT >= 0 & yT <= maxY));

    set(gca, 'TickDir', 'out');
    figPos(gcf, 1.1, 0.75);


