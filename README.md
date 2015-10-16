# iPhone-3D-scanner
Freehand Voxel Carving Scanning on a Mobile Device

The app requires a device and cannot run on simulator!

Installation instructions:
1. Put all the files in the same folder
2. Launch PointCloudSample\PointCloudSample.xcodeproj
3. Press the PLAY button and you are done :P

Usage instructions:
After application loads follow the on screen instruction i.e. touch the screen to begin slam process. After enough feature points found a blue cube and axes will appear on the screen. Fit your scene inside the cube. Cube dimensions and position can be controled by simple gestures:

1. Pinch for scaling
2. One finger pan to move the cube in XY plane
3. Two fingers pan to move the cube along Z axis

Once you've fit your object inside the cube you can take images using the "Capture" button (as many as you want).
BTW, you can reverse the actions i.e. take the images first, the last cube position is the one that counts.
As you are done with the image head to the Mesh screen by touching the "Mesh" button. In the Mesh screen you can:

1. View your snapshots by clicking them on the left sidebar
2. Check segmentation for the currently visible image with "Seg" button
3. Sculpting the voxel volume using the currently visible image with "Sculpt" button
4. Sculpting the voxel volume using all the images with "Sculpt All" button
5. Displaying the mesh representing the surface of the current volume

Mesh control:

1. Pinch for scaling
2. One finger pan for rotation
3. Two fingers pan for translation in the screen plane

Demo mode:

The demo mode uses rpedefined images and possibly segmentations. To enter demo mode touch the "Demo" button and choose between "Original images" for colored images and "Silhouettes" for using segmentation supplied beforehand. If you choose using demo mode you can skip SLAM process and taking snapshots and you get directly to the mesh screen at which you continue the same way as described above. 
Images, segmentations and projection matrices for the demo provided by Ben Tordoff on http://www.mathworks.com/matlabcentral/fileexchange/26160-carving-a-dinosaur/content/SpaceCarving/+spacecarving/carve.m

Resolution Specifications:

As configuration screen yet to be provided you can control the intial size of the voxel volume by redfining #define SCULPTURE_SIZE 128 to any othe size you want. That definitioin can be found in PointCloudSample/Sculptor/Sculpture.h

Youtube tutorial:

https://youtu.be/zy40dpsmprg

Have fun! :)

Alex Fish
