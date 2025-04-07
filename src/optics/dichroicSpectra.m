function [spectra, pctRemain, filt, light] = dichroicSpectra(dichroic, light, lightPath, verbose)
% DICHROICSPECTRA
%
% Description:
%   Approximate effect of filter on the spectra of a light source
%
% Syntax:
%   spectra = dichroicSpectra(dichroic, light, lightPath)
%
% Inputs:
%   dichroic            string or Nx2 or Nx3 double
%       Name of filter or Nx2 array with wavelength and attenuation. For
%       filters with separate reflectance and transmission spectra,
%       transmission should be the 2nd column and reflectance the 3rd.
%   light               string or Nx2 double
%       Name of light or Nx2 array with wavelength and power
%   lightPath           string ("transmit" or "reflect")
%       Whether light is transmitted through filter or reflected
%
% Notes:
%   If filter attenuation is in percent (values >1), they will be divided
%   by 100 and a warning will be printed to the command line
% -------------------------------------------------------------------------

%#ok<*DLMRD>

    arguments
        dichroic
        light
        lightPath        (1,1)   string  {mustBeMember(lightPath, ["reflect", "transmit"])} = "transmit"
        verbose          (1,1)   logical = true
    end

    if istext(dichroic)
        dichroic = dlmread(sara.resources.getResource(dichroic));
    elseif isnumeric(dichroic) && size(light, 1) == 2
        dichroic = dichroic';
    end

    if istext(light)
        light = dlmread(sara.resources.getResource(light));
    elseif isnumeric(light) && size(light, 1) == 2
        light = light';
    end

    % Ensure filter data is fraction, not percent
    if max(dichroic(:, 2)) > 1.01
        if verbose 
            warning('Dichroic data appears to be in percent. Dividing by 100.');
        end
        dichroic(:,2) = dichroic(:,2) / 100;
    elseif size(dichroic, 2) == 3 && max(dichroic(:,3)) > 1.00
        if verbose
            warning('Dichroic data appears to be in percent. Dividing by 100.');
        end
        dichroic(:,3) = dichroic(:,3) / 100;
    end

    % Interpolate filter to match wavelengths of light source
    if lightPath == "reflect"
        if size(dichroic, 2) == 3
            filt = interp1(dichroic(:,1), dichroic(:,3), light(:,1));
        else
            filt = interp1(dichroic(:,1), 1-dichroic(:, 2), light(:,1));
        end
    else
        filt = interp1(dichroic(:,1), dichroic(:,2), light(:,1));
    end

    % Attenuate light source spectra by the fitler
    spectra = light(:, 2) .* filt;

    % Calculate the percent remaining after attenuation across all wls
    orig = sum(light(~isnan(light(:,2)), 2));
    new = sum(spectra(~isnan(spectra)));
    pctRemain = 100*new/orig;

    if nnz(isnan(spectra)) > 0
        warning('Found %u NaNs in filtered spectra - replacing with 0', nnz(isnan(spectra)));
    end
    spectra(isnan(spectra)) = 0;

    if verbose
        fprintf("Percent area remaining post-filter: %.4f\n", pctRemain);
    end
