# Calcium Imaging ROIs

Make sure to update facile-tools repository with `git pull`. The only other tool needed is ImageJ.

### Segmentation within an experiment
Segment ROIs with RoiManager in ImageJ using the Oval shape (2nd on the toolbar). Use the .tif stacks and make sure to scroll through the slices (each represents a single trial) because different ROIs will be more or less responsive to the various stimuli. This is useful for ensuring you find as many ROIs as possible and make sure each ROI is well-isolated.

If an ROI is suspicious but not obviously crosstalk, I err on the side of segmenting and then just make a note of the experiment and ID. Once we get into the physiology, there are lots of ways to verify the suspicious ones, but it is useful to have a list of which might require extra attention. 

The SUM stack is the best for clearly showing the distinct borders of each ROI, but the STD stack is useful for the ROIs on the inner left edge that are dimmer. 

**Beware of deleting ROIs in ImageJ!** The coregistration part below relies on consistent numbering of the ROI IDs in ImageJ so if you need to delete an ROI and have already co-registered ROIs with higher ID numbers, don't delete it, just move it over to mark a new cell. If it's deleted, all subsequent ROIs will decrease their ID by 1 and the co-registration will need to be restarted (not time-consuming but best to avoid). 

### Coregistration across experiments
Each ROI has an experiment-specific ID number (from ImageJ). The goal of coregistration is to assign each ROI a unique identifier across all experiments (a three letter name like "ABC"). This might make more sense if you open up two early experiments and check out the UI. 

Once you have a number of new ROIs, save the ROIs (overwrite the existing .zip file) and try coregistering them with prior experiments in MATLAB.

```matlab
% Make sure facile-tools is on the MATLAB path
addpath(genpath('yourfilepath\facile-tools'));

% Load the experiment you're segmenting (e.g. 20230314)
load('MC00851_ODR_20221201B.mat');
% Load in one of the earlier experiments as reference
load('MC00851_ODR_20221020A.mat');

% The homeDirectory property is set to my computer paths. 
% Update to the location of the experiment file:
MC00851_ODR_20221201B.setHomeDirectory('yourfilepath\MC00851_ODR_20221201\');
% You shouldn't need to set the home directory for the reference experiment

% Load in your newly segmented ROIs
MC00851_ODR_20221201B.loadROIs();

% Open up the co-registration UI. The reference experiment goes first
RoiCoregistrationApp(MC00851_ODR_20221020A, MC00851_ODR_20221201B);

% Once you have coregistered, click the "Export" button for the 
% experiment on the right and then save it in the command window
save('MC00851_ODR_20221201B.mat', 'MC00851_ODR_20221201B.mat');
```

There should be two panels, the reference experiment to the left and the new experiment to the right. Each has an image showing ROIs and a table with two columns: **ID** is the experiment-specific ROI number from ImageJ, **UID** is the unique identifier. You can edit UIDs manually by typing in the table, but the automated registration below should make that unnecessary. The table and image for an experiment are synced so that:
- Clicking on a row within the table will color the corresponding ROI red in the accompanying image. 
- Clicking on an ROI in the image will select the ROI's row within the table. 

I think there's some initial coregistration for all experiments (e.g., some ROIs have been manually assigned UIDs matching other experiments). If some ROIs have been co-registered, once you open up the app, use **`Ctrl+R`** to register the images (basically it's a point-based registration that derives a transform by matching up the coordinates of ROIs with the same UID in each experiment). A window should pop up confirming the registration. Then type **`Ctrl+A`** to automatically co-register any remaining blank ROIs. There will usually be some in each experiment that have no match, just leave them blank for now.

The coregistration UI can be useful for guiding segmentation and pointing out ROIs you might have missed. I usually segment a group in ImageJ, then go back to the coregistration UI to see where else I need to focus. There are a few tools that can be helpful when comparing your segmentation to a fully-segmented experiment:.
- Once you have registered the images with **`Ctrl+R`** clicking on a ROI in one experiment will cause a red X to show up in the same location on the other experiment's image. If there's an ROI at that location, the X will be green. To get the X to go away, type **`X`**
- **`Ctrl+X`** - colors coregistered ROIs purple.
- **`Ctrl+C`** - re-opens the registration figure that pops up at the end of registering with **`Ctrl+R`**
- **`Ctrl+O`** - plots coregistered ROIs from each experiment on the same graph with a line connecting them. There should be an overall pattern and any lines that diverge from that pattern are problematic and worth checking. The automated registration is good and shouldn't produce blatant errors such as these, but it's a good sanity check

I generally end up with ~300 ROIs when image quality is good. Image quality varies between sessions so it may be that some sessions have far fewer clear ROIs. Also some ROIs that are clear in one experiment might be defocused in another due to slight changes in focus between experiments, so make sure each ROI is worth segmenting in each experiment independently.  

Because the UIDs present vary across experiments, once an experiment is fully segmented, open RoiCoregistrationApp with each previous experiment in chronological order and auto-register with the fully segmented experiment. 