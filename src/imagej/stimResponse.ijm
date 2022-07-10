// stimResponse.ijm
// 17Oct2021 - SSP

Dialog.create("Stimulus Response");
	Dialog.addMessage("Enter stimulus parameters here, in frames:");
	Dialog.addNumber("Stim Start:", 251);
	Dialog.addNumber("Stim End:", 750);
	Dialog.addCheckbox("Compute offset:", true);
	Dialog.addNumber("Offset end:", 1250);
	Dialog.addCheckbox("Magenta-green colors?", false);
Dialog.show();

stimStart = Dialog.getNumber();
stimEnd = Dialog.getNumber();
computeOffset = Dialog.getCheckbox();
stimOffset = Dialog.getNumber();
whichColors = Dialog.getCheckbox();

baselineEnd = stimStart - 1;

// Work from the active stack
stackTitle = getTitle();
print("Stim Response: " + stackTitle);

// Get the average response before the stimulus
run("Z Project...", "start=2 stop=" + baselineEnd + " projection=[Average Intensity]");
baselineImage = getTitle();

// Get the average response during the stimulus
selectWindow(stackTitle);
run("Z Project...", "start=251 stop=750 projection=[Average Intensity]");
stimImage = getTitle();

// Get the average response after the stimulus
selectWindow(stackTitle);
run("Z Project...", "start=751 stop=1250 projection=[Average Intensity]");
tailImage = getTitle();

// Subtract the baseline from the response during the stimulus
imageCalculator("Subtract create 32-bit", stimImage, baselineImage);
onsetImage = getTitle();
run("Enhance Contrast", "saturated=0.35");
getMinAndMax(min1, max1);

if (computeOffset) {
	// Subtract the baseline from the response after the stimulus
	imageCalculator("Subtract create 32-bit", tailImage, baselineImage);
	offsetImage = getTitle();
	run("Enhance Contrast", "saturated=0.35");
	getMinAndMax(min2, max2);

	// Match the pixel ranges
	finalMax = max2;
	if (max1 > max2) {
		finalMax = max1;
	}
	finalMin = min2;
	if (min1 < min2) {
		finalMin = min1;
	}
	finalBound = maxOf(Math.abs(finalMin), finalMax);
	finalMin = -1 * finalBound;
	
	selectWindow(onsetImage);
	setMinAndMax(finalMin, finalBound);
	selectWindow(offsetImage); 
	setMinAndMax(finalMin, finalBound);
	
	// Create a merged image
	if (whichColors) {
		run("Merge Channels...", "c2=[" + onsetImage + "] c6=[" + offsetImage + "] create keep");
	} else {
		run("Merge Channels...", "c1=[" + offsetImage + "] c5=[" + onsetImage + "] create keep");
	}
} else {
	finalBound = maxOf(Math.abs(min1), max1);
	finalMin = -1 * finalBound;
	setMinAndMax(finalMin, finalBound);
}

// Cleanup
selectWindow(tailImage);
close();
selectWindow(stimImage);
close();
selectWindow(baselineImage);
close();

