#@ Float (label = "X", persist=false) xShift
#@ Float (label = "Y", persist=false) yShift

translateImage()

function translateImage() {
	print("Translating: " + getTitle() + ", x = " + toString(xShift, 4) + ", y = " + toString(yShift, 4));
	run("Translate...", "x=" + toString(xShift) + " y=" + toString(yShift) + " interpolation=Bilinear stack");
	print("---")
}
