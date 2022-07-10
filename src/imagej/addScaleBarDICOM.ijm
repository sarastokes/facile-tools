#@ File (label = "Output directory", style = "directory") output

addScaleBarDICOM()

function addScaleBarDICOM() {
	imageTitle = getTitle();
	xStart = indexOf(imageTitle, ".dcm");
	newTitle = substring(imageTitle, 0, xStart);
    run("Duplicate...", "title=" + newTitle + " duplicate");

	// Adjust the contrast
	run("Enhance Contrast", "saturated=0.35");

	// Add scale bar
	run("Scale Bar...", "width=25 height=3 font=14 color=White background=None location=[Lower Right] bold overlay");

	// Save as 8-bit PNG and return to original image
	setOption("ScaleConversions", true);
	run("8-bit");
    pathToOutputFile = output + File.separator + newTitle + ".png";
    saveAs("PNG", pathToOutputFile);	
    close();
    selectWindow(imageTitle)
}

