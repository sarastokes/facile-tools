function S = calcRelay(opts)
% CALCRELAY
%
% Calculate the focal lengths and beam diameters of a relay made of two
% lenses or spherical mirrors. Provide 3 variables and the 4th is
% calculated. Intended for learning or back of the envelope calculations.
% The 4 variables and guiding formula are:
%
%        F2      D2
%       ----  = ----
%        F1      D1
%
% F1: Focal length of the first lens
% F2: Focal length of the second lens
% D1: Beam diameter at the input of the relay
% D2: Beam diameter at the output of the relay
%
% Output:
%   S       struct
%       Contains 4 variables plus the magnification, distance to retina
%       plane, distance to final pupil plane, etc.
%
% History:
%   08Jul2024 - SSP
% --------------------------------------------------------------------------

    arguments
        opts.F1          double  {mustBeNonnegative} = []
        opts.F2          double  {mustBeNonnegative} = []
        opts.D1          double  {mustBeNonnegative} = []
        opts.D2          double  {mustBeNonnegative} = []
    end


    if isempty(opts.D2)
        % Calculate the beam diameter at the output of the relay
        % given the beam diameter at the input of the relay and the focal lengths of the lenses
        opts.D2 = opts.D1 * (opts.F2 / opts.F1);
    elseif isempty(opts.D1)
        % Calculate the beam diameter at the input of the relay
        % given the beam diameter at the output of the relay and the focal lengths of the lenses
        opts.D1 = opts.D2 * (opts.F1 / opts.F2);
    elseif isempty(opts.F2)
        % Calculate the focal length of the second lens
        % given the focal length of the first lens and the beam diameters at the input and output of the relay
        opts.F2 = opts.F1 * (opts.D2 / opts.D1);
    elseif isempty(opts.F1)
        % Calculate the focal length of the first lens
        % given the focal length of the second lens and the beam diameters at the input and output of the relay
        opts.F1 = opts.F2 * (opts.D1 / opts.D2);
    end

    S = struct(...
        'FocalLength1', opts.F1,...
        'FocalLength2', opts.F2,...
        'BeamDiameterIn', opts.D1,...
        'BeamDiameterOut', opts.D2);

    % Calculate the magnification of the relay
    S.Magnification = S.FocalLength2 / S.FocalLength1;
    fprintf('Magnification = %.2f\n', S.Magnification);
    % Calculate the distance between the two lenses
    S.Distance = S.FocalLength1 + S.FocalLength2;
    % Retina plane
    S.RetinaPlane = 2*S.FocalLength1;

    maxSize = max([S.BeamDiameterIn S.BeamDiameterOut])/2;
    maxSize = maxSize * 1.25;
    offset = (1.1*maxSize)-maxSize;

    figure(); hold on;
    title(sprintf('Magnification = %.2f', S.Magnification));
    plot([0 0], S.BeamDiameterIn/2 * [-1 1], 'r', 'LineWidth', 2);
    text(0, offset+S.BeamDiameterIn/2, sprintf("D = %.2f", round(S.BeamDiameterIn,2)),...
        'HorizontalAlignment', 'center', 'FontName', 'Arial', 'Color', 'r');
    plot([S.FocalLength1 S.FocalLength1], maxSize*[-1 1],...
        'b', 'LineWidth', 2);
    text(S.FocalLength1, 1.1*maxSize, sprintf("f = %u", S.FocalLength1),...
        'HorizontalAlignment', 'center', 'FontName', 'Arial', 'Color', 'b');
    plot(S.FocalLength1+S.Distance*[1 1], [-maxSize maxSize],...
        'b', 'LineWidth', 2);
    text(S.FocalLength1+S.Distance, 1.1*maxSize, sprintf("f = %u", S.FocalLength2),...
        'HorizontalAlignment', 'center', 'FontName', 'Arial', 'Color', 'b');
    plot(2*S.Distance*[1 1], S.BeamDiameterOut/2*[-1 1],...
        'r', 'LineWidth', 2);
    text(2*S.Distance, offset + S.BeamDiameterOut/2, sprintf("D = %.2f", round(S.BeamDiameterOut,2)),...
        'HorizontalAlignment', 'center', 'FontName', 'Arial', 'Color', 'r');
    ylim(1.2*[-maxSize maxSize])
    xlim([-S.FocalLength1, 2*S.Distance+S.FocalLength1]);
    x = xticks();
    xticks(x(x >= 0 & x <= 2*S.Distance));

    % Rays
    plot([0 S.FocalLength1 S.FocalLength1+S.Distance 2*S.Distance],...
        [S.BeamDiameterIn/2 S.BeamDiameterIn/2 -S.BeamDiameterOut/2 -S.BeamDiameterOut/2], '--k', 'LineWidth', 2);
    plot([0 S.FocalLength1 S.FocalLength1+S.Distance 2*S.Distance],...
        [-S.BeamDiameterIn/2 -S.BeamDiameterIn/2 S.BeamDiameterOut/2 S.BeamDiameterOut/2], '--k', 'LineWidth', 2);

    zeroBar(gca, 'y');