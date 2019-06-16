**IMPORTANT:** You are encouraged to read this entire file and make necessary modifications to your code before program execution.

MATLAB code for [description of paper]

by Hykoush Asaturyan, E. Louise Thomas, Jimmy. D. Bell and Barbara Villarini.

Please see [link to pdf file] for online access to PDF file.

This program was built using MATLAB R2017b and MATLAB R2018a, and employs the Image Processing Toolbox and Computer Vision Toolbox.

**Purpose of project task:** 

Morphological feature extraction of segmented or annotated organs in radiological volumes (scans).

**Purpose of program code for project task:** 

(1) Compute organ volume (volume);

(2) Compute organ global curvature (meanCurv); 

(3) save to a MAT file: 3D rendered organ volume data (dataInterp), smoothed rendered 3D organ data (dataFilt), principal curvatures and directions (curvData), and values of volume (volume) and global curvature (meanCurv);

(4) save to a NIFTY file: 3D rendered organ volume data (dataFiltBin); 

(5) save volume (volume) and curvature (meanCurv) results of each 3D rendered organ to a .xlsx file.

**To execute the program, modify and run "VolumeCurvatureReconstruction.m".**

**IMPORTANT TO NOTE:** Please modify the following variables below:

1) resultsFolder = 'path-to-folder-that-stores-results';

2) inputFolder = 'path-to-folder-that-contains-input-files-of-organ-segmentations-or-annotations';

3) totalData = 'struct-listing-all-files-that-contain-3D-arrays-of-binary-organ-annotations';

4) volSize = ['width','height','depth'] where 'width' is the number of columns in the binary organ-annotation array; 'height' is the number of rows in the binary organ-annotation array; and 'depth' is the number of slices (2D) in the binary organ-annotation array.

5) interpVoxSize = ['x','y',z'] where 'x' is pixel interval in axial direction; 'y' is pixel interval in sagittal direction; 'z' is the spacing between each slice (2D) in the binary organ-annotation array..
