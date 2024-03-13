function [x, v] = generatePalmerBarStimulus(Tmax, dt)
% GENERATEPALMERBARSTIMULUS
%
% Syntax:
%   [x, v] = generatePalmerBarStimulus(Tmax, dt)
%
% Inputs:
%   Tmax        double scalar
%       Total stimulus time
%   dt          double scalar
%       Increment between time steps
%
% Outputs:
%   x           double, vector
%       Position of the bar at each time step
%   v           double, vector
%       Velocity of the bar at each time step
%
% References:
%   Palmer (2015) PNAS
% --------------------------------------------------------------------------

    % Constants
    omega = 2*pi*1.5;
    gamma = 20;
    D = 2.7e6;
    %xi = gamma / (2*omega);

    % Time vector
    t = 0:dt:Tmax;
    v = zeros(size(t));
    x = zeros(size(t));


    for i = 2:length(t)
        xi = randn();  % Gaussian random
        v(i) = (1 - gamma*dt)*v(i-1) - omega^2*x(i-1)*dt + xi*sqrt(D*dt);
        x(i) = x(i-1) + v(i-1)*dt;
    end
