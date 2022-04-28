%% Tyler Godat: 2-19-2019, updated 07-31-2020, 05-21-2021
% Sara Patterson: 1-20-2022 - changed how file names are read
 
%requires a '^parameters.txt' file to run properly, placed in the same
%folder as all the LED spectra. This must contain WITH NO BLANK LINES IN BETWEEN:
% beamsize = x; %where x is beam diameter in mm
% voltages = [x1 x2 x3 x4 x5 ....]; % where xn is the voltage setting for each capture
% LUTname = 'LUT_530nm_test.txt'; %name for the LUT file you want to output
% prefix = 'TEST_greenLED'; %prefix name for files to analyze

calibrationDate = '20220131';
LED = 796;

% LED specific parameters:
% output name is the name to use for saving normalized spectra file
% min wl is minimum wavelength to allow (sets noise below this to zero)
% max wl is maximum wavelength to allow (sets noise above this to zero)

switch LED
    case 420
        minwl = 375; maxwl = 475;
        output_name = ['420nm_', calibrationDate];
    case 530
        output_name = ['530nm_', calibrationDate];
        minwl = 475; maxwl = 575;
    case 660
        output_name = ['660nm_', calibrationDate];
        minwl = 600; maxwl = 750;
    case 796
        output_name = ['796nm_', calibrationDate];
        minwl = 725; maxwl = 830;
end

%% Select the folder for the LED you want to analyze

folder = uigetdir('','Select the folder for the LED you want to analyze');
disp(['Selected: ',folder])
files = dir(folder); cd(folder); 

%%
%opens the text file ^parameters.txt with voltage and beam information
fid = fopen('^parameters.txt');
fopen(fid);

for i = 1:4 %reads in the first four lines with needed parameters
    line = fgetl(fid);
    eval(line);
end
clear('line');
fclose(fid); clear('fid');

%% Read in the names of each spectral measurement
fileNames = cell(0,1);
spectraCount = 0; 
for i = 1:length(files)
    if contains(files(i).name, prefix)
        spectraCount = spectraCount+1;
        fileNames{spectraCount} = files(i).name;
    end
end
fprintf('Imported %u spectral measurements\n', spectraCount);

%% Sort them
shortNames = cellfun(@(x) x(end-7:end), fileNames, 'UniformOutput', false)';
[~, idx] = sort(shortNames);
fileNames = fileNames(idx);
%% Read in each file

spectra = cell(1, length(fileNames));
resolution = cell(1, length(fileNames));

% Teads in the spectral data from each file
for i = 1:length(fileNames)
    spectra{i} = dlmread(fileNames{i}); 
end

%% Calculate the wavelength resolution
for i = 1:length(spectra)
    wavelengths = spectra{i}(:,1);
    % For each file, calculates the wavelength resolution at each pixel
    res = zeros(length(wavelengths),1); 
    for j = 1:length(wavelengths)
        if j == 1
           res(j) = wavelengths(j+1) - wavelengths(j);
        elseif j == length(wavelengths)
           res(j) = wavelengths(j) - wavelengths(j-1);
        else
           res(j) = (wavelengths(j)-wavelengths(j-1))/2 + (wavelengths(j+1)-wavelengths(j))/2;
        end
    end
    resolution{i} = res;
end


%% Calculates optical power at each voltage

badwls = intersect(find(minwl<=wavelengths),find(wavelengths<=maxwl));
badwls = ~ismember(1:length(wavelengths),badwls); %finds wavelengths outside the desired range 

powers = zeros(1,length(voltages));
for i = 1:length(spectra)
   irradiances = spectra{i}(:,2); %for each irradiance measurement, multiplies by spectral resolution and integrates
   irradiances(badwls)=0; %sets wavelengths outside the expected range to zero (to cut down on integrating noise)
   res = resolution{i};
   pwr = 0;
   for j = 1:length(irradiances)
       pwr = pwr + res(j)*irradiances(j);
   end
   powers(i) = pwr;
end

beamarea = pi*(beamsize/2/10)^2; %calculates the beam area in cm^2

powers = powers.*beamarea; %calculates optical power in uW from irradiances

%% Outputs data to a LUT text file

[volt_sorted, I] = sort(voltages); %sorts the voltages in ascending order
pwr_sorted = powers(I); %matches the powers to the sorting of the voltages
if ismember(voltages, 0)
    pwr_sorted = pwr_sorted - min(pwr_sorted); %makes the minimum power zero (comment out if you don't want)
end

T = table(volt_sorted', pwr_sorted', 'VariableNames', {'VOLTAGE','POWER'});

writetable(T, LUTname, 'Delimiter', '\t')
disp(['Saved look up table: ',LUTname])

%% Saves the normalized curve (if the output_name is given)

if ~isempty(output_name)
    temp = spectra{1}(:,2); 
    temp = temp - spectra{end}(:,2); 
    temp(badwls) = 0; %subtracts noise for normalized spectra and sets powers
    %outside wavelength range to be zero
    T = table(spectra{1}(:,1),temp./max(temp), 'VariableNames', {'Lambda','Normalized'});
    writetable(T,output_name,'Delimiter','\t')
    disp(['Saved normalized spectrum: ',output_name])
else
    disp('Did not save any normalized spectra')
end
