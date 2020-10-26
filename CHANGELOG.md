# CHANGELOG

### 2020-10-26
- Fixed warnings related to GUI Layout Toolbox, added to `lib`

### 2020-10-21
- Added user-defined stat option, labelmatrix input and background color control to `roiColorByStat.m` 

### 2020-10-20
- Lighter background for `roiLabel.m`

### 2020-10-16
- Shifted simulation code and made repo public

### 2020-10-15
- `roiRemove.m` - removes a single ROI from segmentation results

### 2020-10-11
- `rf2sf.m` - get spatial frequency tuning curve from a receptive field 
- `twoConeRF.m`, `runPlotTwoConeRF.m` - simulate DoG-like models with two center cones

### 2020-10-05
- `sfPlot.m` - options for plotting spatial frequency curves tailored to calcium imaging

### 2020-10-04
- Implementing new rule for backwards compatibility: all optional parameters go thru inputParser
- Modified `roiLabels.m` to work with label matrix from lab's calcium imaging datasets

### 2020-08-28
- `roiLabels.m` - label each roi

### 2020-08-26
- Included option to suppress plot in `runPlotMSER.m`

### 2020-08-24
- `roiFilter.m` - removes user-defined ROIs 
- `RoiSignalView.m` - viewer for parsing through ROIs and their signals

### 2020-08-23
- Added dependencies: my code in `util` folder, external code in `lib`
- `roiSignal.m` - average response over time for ROI pixels
- `signalPowerSpectrum.m` - calculates and displays power spectrum 
- `roiCleanup.m` - removes hidden overlapping ROIs
- Created `.gitignore`

### 2020-08-22
- `roiSignalPlot.m` - shows ROI signal with location overlaid on an image
- Added image statistics option to `roiColorByStat.m`

### 2020-08-17
- Initial commit
