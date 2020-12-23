# CHANGELOG

### 2020-12-23
- Moving essentials to ao-tools repository

## 2020-12-20
- Removed blank first frame from `roiSignal.m` 

### 2020-12-15
- `roiQuality`, `roiQualityBatch` - exploring ways of determining good and bad pixels within a ROI
- `qualityIndex` - replaces `responseQuality`
- `gaussfilt` - time series Gaussian filter from File Exchange
- `rmse` - root mean squared error utility function

### 2020-12-03
- `fillToZero` - plot signal and color area under the curve

### 2020-12-02
- Added dF/F from mean and median to `roiSignal.m`, `roiSignals.m`

### 2020-11-14
- Added option to specify color for shaded ROIs in `roiLabel.m`

### 2020-11-11
- `mysmooth.m` - pads vector, then removes after running MATLAB's `smooth.m` to avoid edge effects
- `signalOnsetOffset.m`, `onsetOffsetMap.m` - analyse and display stim onset/offset responses

### 2020-11-08
- `responseQuality.m` - metric for response quality from Baden (2016)
- New utilities: `highPassFilter.m`, `lowPassFilter.m`

### 2020-11-06
- `roiSignals.m` - wrapper batch running `roiSignal.m` for many ROIs
- `roiImportImageJ.m` - wrapper for 3rd party ImageJ ROI functions in `lib`
- Added 3rd party functions for using `.tif`

### 2020-11-03
- `video2stack.m` - convert `.avi` video to `.mat` stack

### 2020-10-26
- `SegmentationDemo.m` - walks through segmentation code
- Added wait message to plot from `runPlotMSER.m`
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
