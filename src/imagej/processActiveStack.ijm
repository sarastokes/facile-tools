#@ File (label = "Output directory", style = "directory") output

Dialog.create("Video Parameters");
	Dialog.addCheckbox("Imaging on right side?", false);
	Dialog.addCheckbox("Using LEDs?", false);
Dialog.show();

rightSide = Dialog.getCheckbox();
usingLEDs = Dialog.getCheckbox();

imageTitle = getTitle();
print("Processing: " + imageTitle);

// Determine abbreviated title
xStart = indexOf(imageTitle, "_vis_");
newTitle = substring(imageTitle, xStart+1, xStart+9);
	
if (usingLEDs) {
	xStart = indexOf(imageTitle, ".avi");
	newTitle = "vis" + substring(imageTitle, xStart-4, xStart-1);
	// xStart = indexOf(imageTitle, "_fs_");
	// newTitle = "vis" + substring(imageTitle, xStart+3, xStart+8);
}
	
print("Assigned title: ", newTitle);

// Crop the stack
cropVal = 0;  // GCaMP6 on left side
if (rightSide) {
	cropVal = 250;// GCaMP6 on right side
}
run("Specify...", "width=248 height=360 x=" + cropVal + " y=0 slice=1"); 

// Save the cropped stack
run("Duplicate...", "title=" + newTitle + " duplicate");
pathToOutputFile = output + File.separator + "Videos" + File.separator + newTitle + ".tif";
print("Saving processed stack to: " + pathToOutputFile);
saveAs("Tiff", pathToOutputFile);

// AVG Z-projection
selectWindow(newTitle + ".tif");
run("Z Project...", "projection=[Average Intensity]");
pathToOutputFile = output + File.separator + "AVG_" + newTitle + ".png";
print("Saving image to: " + pathToOutputFile);
saveAs("PNG", pathToOutputFile);
close();

// MAX Z-projection
selectWindow(newTitle + ".tif");
run("Z Project...", "projection=[Max Intensity]");
pathToOutputFile = output + File.separator + "MAX_" + newTitle + ".png";
print("Saving image to: " + pathToOutputFile);
saveAs("PNG", pathToOutputFile);
close();

// SUM Z-projection
selectWindow(newTitle + ".tif");
run("Z Project...", "projection=[Sum Slices]");
pathToOutputFile = output + File.separator + "SUM_" + newTitle + ".png";
print("Saving image to: " + pathToOutputFile);
saveAs("PNG", pathToOutputFile);
close();

// STD Z-projection
run("Z Project...", "projection=[Standard Deviation]");
pathToOutputFile = output + File.separator + "STD_" + newTitle + ".png";
print("Saving image to: " + pathToOutputFile);
saveAs("PNG", pathToOutputFile);
close();

// MED Z-projection
run("Z Project...", "projection=[Median]");
pathToOutputFile = output + File.separator + "MED_" + newTitle + ".png";
print("Saving image to: " + pathToOutputFile);
saveAs("PNG", pathToOutputFile);
close();

// Close out
selectWindow(newTitle + ".tif");
close();
selectWindow(imageTitle);
// close();
print("COMPLETED: " + newTitle + "!");
print("---");

