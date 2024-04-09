# ROI Functions

Work-in-progress documentation in effort to clean out old or unmaintained functions. All functions take a matrix of ROI responses where time is the 2nd dimension; unless otherwise specified, 3D matrices with repeats as the 3rd dimension

##### Preprocessing
- **`getRoiPixels`** - given a video, label mask and the roi ID, returns the timecourses for each pixel in the ROI, rather than the average across pixels
- **`roiResponses`** - single function providing consistent interface for the following, which are called per ROI via **`roiResponse`**:
    - **`roiDFF`** - calculates dF/F given a video, a single ROI label mask and a background window. This function is used with an empty background window (`[]`) to get the raw fluorescence averaged over all pixels in the ROI
    - **`roiZScore`** - same as above, but for z-scored responses in standard deviations.
- **`roiZScoresOtherBkgd`** - same as `roiZScore`, but use a separate background response rather than the beginning of the response to be z-scored.

##### Postprocessing
- **`roiDownsample`** - downsample ROI responses by taking the median, mean or sum of `N` frames.
- **`roiMotionDetect`** - detect ROIs that should be omitted due to registration artifact by looking for frequency of respiration (the largest source of eye motion in our experiments).
- **`roiNormAvg`** -  Normalize (0-1) followed by translation along y-axis to restore baseline, then takes the average (if multiple repeats were provided) *maybe move to "signal"*
- **`roiNormPercentile`** - Normalize by the responses by their magnitude where the magnitude is computed as the absolute value of the Xth or 100-Xth percentile of the signal.
- **`roiNormRescale`** - Normalize using `rescale`. This is useful when there are both positive and negative components to the response and you need to preserve their relative magnitude around the baseline.
- **`roiPrctFilt`** - detrend calcium traces with `prctfilt` from CaImAn. Defaults look good for classification stimuli from GCaMP6s on the 1P system.

##### Analysis
- **`roiAdaptIndex`** - determine the peak response and the median response at the end of the signal, compute adaptation index (final/peak)
- **`roiAreaUnderCurve`** - take the area under the curve for the entire response, or a specified region. Optional: rectify
- **`roiCorrCompare`** - get per-ROI correlation coefficients for two sets of responses. Optional: normalize, define a specific region of the response to use
- **`roiF1F2`** - calculate the F1 and F2 amplitude/phase and DC, given the cycle averaged response
- **`roiPrincipalComponents`** - runs PCA on the ROI responses
- **`roiRangePercentile`** - Determine the range, minimum and maximum values of the signal from the Xth or 100-Xth percentile of the signal (default X = 2, so min and max are the 2nd and 98th percentiles).