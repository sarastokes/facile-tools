#@ File (label = "Output directory", style = "directory") output

createStackSnapshots();

function createStackSnapshots() {
	// Get image name and remove file extension
    imageTitle = getTitle();
    print("Processing: " + imageTitle);
	newTitle = substring(imageTitle, 0, 8);
    
    // AVG Z-projection
    selectWindow(newTitle + ".tif");
    run("Z Project...", "projection=[Average Intensity]");
    pathToOutputFile = output + File.separator + "AVG_" + newTitle + ".png";
    saveAs("PNG", pathToOutputFile);
    close();

    // MAX Z-projection
    selectWindow(newTitle + ".tif");
    run("Z Project...", "projection=[Max Intensity]");
    pathToOutputFile = output + File.separator + "MAX_" + newTitle + ".png";
    saveAs("PNG", pathToOutputFile);
    close();
    
    // STD Z-projection
    run("Z Project...", "projection=[Standard Deviation]");
    pathToOutputFile = output + File.separator + "STD_" + newTitle + ".png";
    saveAs("PNG", pathToOutputFile);
    close();

    // SUM Z-projection
    selectWindow(newTitle + ".tif");
    run("Z Project...", "projection=[Sum Slices]");
    pathToOutputFile = output + File.separator + "SUM_" + newTitle + ".png";
    saveAs("PNG", pathToOutputFile);
    close();

	// Save, open next image if needed, then close out
    selectWindow(newTitle + ".tif");
    pathToOutputFile = output + File.separator + "Videos" + File.separator + newTitle + ".tif";
    saveAs("Tiff", pathToOutputFile);
    print("Saved stack to: " + pathToOutputFile);

    //if (openNextImage == true) {
    //	run("Open Next");
    //}
    print("---");
}
