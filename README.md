# facile-tools

Analysis tools for Functional Adaptive-optics Calcium Imaging in the Living Eye (FACILE). Developed by Sara Patterson in the Williams lab at the University of Rochester.

## Dependencies
Tested on MATLAB 2018b and 2020a. Some of the newer UIs require 2022a. Some functions require the Signal Processing Toolbox, Image Processing Toolbox or Computer Vision Toolbox.


### Included 3rd party toolboxes
- [cachedcall](https://www.mathworks.com/matlabcentral/fileexchange/49949-cachedcall?s_tid=ta_fx_results)
- [GUI Layout Toolbox](https://www.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox)
- [ReadImageJROI](https://github.com/DylanMuir/ReadImageJROI)
- [TIFFStack](https://github.com/DylanMuir/TIFFStack)
- [JSONLab 2.0](https://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab-a-toolbox-to-encode-decode-json-files?s_tid=ta_fx_results)

Other misc 3rd party functions are found in `\lib`

### Optional dependencies, not included 
- The cone isolation code requires Psychtoolbox and the Silent Substitution Toolbox
- Generating a few of the spatial stimuli requires Stage-VSS