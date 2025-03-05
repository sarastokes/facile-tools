# Calcium Imaging ROIs

Requirements: MATLAB (with Image Processing Toolbox) and [ImageJ](https://imagej.net/software/fiji/).

Add the facile-tools folder and all subfolders to MATLAB's search path:
```matlab
addpath(genpath('...\yourfilepath\facile-tools'));
```

### Experiment names
Each experiment follows a standard naming convention (`AnimalID_EyeRegion_YYYYMMDD`). So MC00851_OSR_20220308 was an experiment on March 8th, 2022 from animal MC00851 and the right side (R) of the fovea in the left eye (OS) was imaged. Matlab Dataset objects corresponding to experiments using spatial stimuli presented through the AOSLO end with "A", those using LED stimuli end with "B", so MC00851_OSR_20220308B contains the data for LED stimuli.

Each experiment folder has a subfolder called "Analysis" with the following standard files:
- A file ending in _RoiSet.zip containing segmented ROIs from ImageJ
- A .tif file ending in _SUM containing one image per trial representing the summed activity across the trial
- A .tif file ending in _STD containing one image per trial representing the standard deviation of activity across the trial
- A .png file ending in _SUM_SUM that represents the summed activity over all trials in the experiment
- A .png file ending in _STD_AVG that represents the average standard deviation over all trials in the experiment


Some files also contain a "_DUP" in the file name (e.g., _SUM_DUP_SUM.png) - these were run through the bleach correction ImageJ plug-in to match the histograms of each image.

### Segmentation within an experiment
Segment ROIs with RoiManager in ImageJ using the Oval shape (2nd on the toolbar). Use the SUM and STD .tif stacks and make sure to scroll through the slices (each represents a single trial) because different ROIs will be more or less responsive to the various stimuli. This is useful for ensuring you find as many ROIs as possible and make sure each ROI is well-isolated.
I primarily use the SUM .tif stack for segmentation as the borders of ROIs are clearer. For ROIs near the center of the fovea that are dim or for ROIs throughout the field of view that simply weren't very bright, I will use the STD stack or one of the .png images.

You may need to adjust the contrast of the image to see the borders of weaker ROIs. You can do this by typing "Ctrl+Shift+C" to open up the B&C window (or "Image > Adjust > Brightness and Contrast" from ImageJ's toolbar). Press "Auto" to improve the contrast and brightness. Pressing "Auto" more times will continue to bring out details in the weaker ROIs (and saturate the brighter ones). Pressing "Reset" restores the orignal contrast and brightness settings.


If an ROI is suspicious but not obviously crosstalk, I err on the side of segmenting and then just make a note of the experiment and ID. Once we get into the physiology, there are lots of ways to verify the suspicious ones, but it is useful to have a list of which might require extra attention.

The SUM stack is the best for clearly showing the distinct borders of each ROI, but the STD stack is useful for the ROIs on the inner left edge that are dimmer.

**Beware of deleting ROIs in ImageJ!** The coregistration part below relies on consistent numbering of the ROI IDs in ImageJ so if you need to delete an ROI and have already co-registered ROIs with higher ID numbers, don't delete it, just move it over to mark a new cell. If it's deleted, all subsequent ROIs will decrease their ID by 1 and the co-registration process will need to be restarted (not time-consuming but best to avoid).

### Coregistration across experiments
Each ROI has an experiment-specific ID number determined by the order that each ROI is segmented in ImageJ. The goal of coregistration is to assign each ROI a unique identifier across all experiments (a three letter name like "ABC"). Each experiment gets a letter (e.g., "A") and all new UIDs created will begin with that letter (e.g., "AAA", "AAB", "AAC", and so on).

Once you have a number of new ROIs, save the ROIs (overwrite the existing .zip file) and try coregistering them with prior experiments in MATLAB.

```matlab
% Make sure facile-tools is on the MATLAB path
addpath(genpath('yourfilepath\facile-tools'));

% Load the experiment you're segmenting (e.g. 20230314)
load('MC00851_ODR_20221201B.mat');
% Load in one of the earlier experiments as reference
load('MC00851_ODR_20221020A.mat');

% The homeDirectory property is set to my computer paths.
% Update to the location of the experiment folder:
MC00851_ODR_20221201B.setHomeDirectory('yourfilepath\MC00851_ODR_20221201\');
% This is only necessary if you're loading videos to look at the ROI responses,
% you won't need to do this if only looking at segmentation and registration.

% Load in your newly segmented ROIs
MC00851_ODR_20221201B.loadROIs('yourfilepath\MC00851_ODR_20221201\Analysis\851_ODR_20221201_RoiSet.zip');

% Open up the co-registration UI. The reference experiment goes first
RoiCoregistrationApp(MC00851_ODR_20221020A, MC00851_ODR_20221201B);

% Once you have coregistered, click the "Export" button for the
% experiment on the right and then save it in the command window
save('MC00851_ODR_20221201B.mat', 'MC00851_ODR_20221201B.mat');

% To update the ROIs when adding new ones or adjusting existing ones
% This will reload the file you used for the "loadROIs" function above
MC00851_ODR_20221201B.reloadROIs()
```

There should be two panels, the reference experiment to the left and the new experiment to the right. Each has an image showing ROIs and a table with two columns: **ID** is the experiment-specific ROI number from ImageJ, **UID** is the unique identifier. You can edit UIDs manually by typing in the table, but the automated registration below should make that unnecessary. The table and image for an experiment are synced so that:
- Clicking on a row within the table will color the corresponding ROI red in the accompanying image.
- Clicking on an ROI in the image will select the ROI's row within the table.

The coregistration process is semi-automated. Basically it's a point-based registration that derives a transform by matching up the coordinates of ROIs with the same UID in each experiment. The transform can then be used to align the new experiment to the reference experiment. Once you manually type in the correct UIDs for 5-10 ROIs, it will take care of the rest. I find it helpful to toggle the ROI circles off on the reference image, then find some that match up with segmented ROIs in the newer experiment.
- Once you see a match, click on the ROI in the reference image. The table should scroll to that ROI and show you the UID.
- Then click on the ROI in the new image and the table will scroll to that ROI's row. Type in the UID from the reference table in all caps.
- Repeat this process for several more ROIs. Aim to get ROIs near each of the four corners of the new image so that the automated registration has information from as much of the image as possible.
- Use **`Ctrl+R`** to register based on your manual ROIs and check the registration. You want to see the red Xs within the blue circles - any that are significantly misaligned might be worth looking into to see if they are actually 2 cells begin assigned the same UID. You will also see the transformed version of the new image overlaid on the reference image. If areas look off, go manually add ROIs there and repeat the registration.
- To check the registration, click on a few more ROIs in the new image. A red X will show up on the reference image where the transform predicts that ROI will be located. If those locations check out, go ahead an autoregister with **`Ctrl+A`**

The coregistration UI can be useful for guiding segmentation and pointing out ROIs you might have missed. I usually segment a group in ImageJ, then go back to the coregistration UI to see where else I need to focus. There are a few tools that can be helpful when comparing your segmentation to a fully-segmented experiment:.
- Once you have registered the images with **`Ctrl+R`** clicking on a ROI in one experiment will cause a red X to show up in the same location on the other experiment's image. If there's an ROI at that location, the X will be green. To get the X to go away, type **`X`**
- **`Ctrl+X`** - colors coregistered ROIs purple.
- **`Ctrl+C`** - re-opens the registration figure that pops up at the end of registering with **`Ctrl+R`**
- **`Ctrl+O`** - plots coregistered ROIs from each experiment on the same graph with a line connecting them. There should be an overall pattern and any lines that diverge from that pattern are problematic and worth checking. The automated registration is good and shouldn't produce blatant errors such as these, but it's a good sanity check.


If some ROIs have already been assigned UIDs, once you open up the app you can jump straight to using **`Ctrl+R`** to register the images. A window should pop up confirming the registration. Then type **`Ctrl+A`** to automatically co-register any remaining blank ROIs. There will usually be some in each experiment that have no match, just leave them blank initially. Because the UIDs present vary across experiments, once an experiment is fully segmented, open RoiCoregisterApp with each previous experiment in chronological order and auto-register with the fully segmented experiment. If any blank ROIs remain, you can automatically assign them UIDs that begin with the experiment-specific start letter (the first experiment in a region gets UIDs beginning with "A", the second experiment with "B", and so on...)

```matlab
% First argument is the dataset object, second is the experiment's start letter
MC00851_ODR_20221201B = assignUIDsToROIs(MC00851_ODR_20221201B, 'A');
```


I generally end up with ~300 ROIs when image quality is good. Image quality varies between sessions so it may be that some sessions have far fewer clear ROIs. Also some ROIs that are clear in one experiment might be defocused in another due to slight changes in focus between experiments, so make sure each ROI is worth segmenting in each experiment independently - make a note of UIDs that are clear in one experiment but are potentially overlapping with another cell in other experiments. These should be checked for crosstalk.

### Tracking ROIs across experiments
The ``RoiRegistry`` class helps track UIDs across experiments. For each region, I keep a script called createRoiRegistry followed by the animal ID, eye and region (e.g., `createRoiRegistry_851OSR.m`) and re-run it when I make changes.
```matlab
% Set the folder containing your dataset objects to the working directory
cd('..\yourpathtodatasetobjects\');

% Create the ROI registry object
MC00851_OSR = RoiRegistry();

% Add your datasets in order of start letter (e.g., "A", "B", "C"). This isn't
% strictly necessary, but it does make the spreadsheets created more intuitive.
MC00851_OSR.addDataset(MC00851_OSR_20220222B);
MC00851_OSR.addDataset(MC00851_OSR_20220308B);
% And so on...

save('MC00851_OSR', 'MC00851_OSR');
```


```matlab
% This will save an Excel spreadsheet to working directory
writetable(MC00851_OSR.uidTable, 'MC00851_OSR_UIDs.xlsx');
```
