# TNM034-OMR
**Authors: Elias Elmquist, Denny Lindberg, Thobias Joelsson**

Optical Music Recognition project for the course TNM034 where black quarter and quaver notes are detected. Supply an image in double format to the tnm034 function and a text string will be returned for the detected notes.

## Features
 - Supports both photographs and scans.
<p align="center"><img src="Results/repodemo_01.jpg" width="512"></p>

 - Perspective/Rotation detection and inverse transformation.
 - Background removal / print extraction.
 - Clutter removal.
<p align="center"><img src="Results/repodemo_02.jpg" width="512"></p>

 - Segmentation of staffs.
 - Detection of symbol regions.
<p align="center"><img src="Results/repodemo_03.jpg" width="512"></p>

 - Coordinate system detection for curved staff lines.
<p align="center"><img src="Results/repodemo_04.jpg" width="512"></p>

 - Pitch detection for filled notes using a combination of template matching and shape detection based on symbol regions.
<p align="center"><img src="Results/repodemo_05.jpg" width="512"></p>