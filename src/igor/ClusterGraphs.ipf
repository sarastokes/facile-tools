#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// ClusterGraph - multicolored cluster trace display
function ClusterGraph(clusterData, [stimTrace])
	wave clusterData; wave stimTrace
	
	Duplicate/O clusterData inputData
	variable nClusters = DimSize(inputData, 0)
	variable nFrames = DimSize(inputData, 1)
	
	variable hasStim
	if (ParamIsDefault(stimTrace))
		hasStim = 0
	else
		hasStim = 1
	endif
	
	// Smooth the data
	variable smoothFac = 50
	Smooth/E=3/B/DIM=1 smoothFac, inputData
	
	// Determine bounds for y-axes
	variable maxVal, minVal
	WaveStats/Q inputData
	maxVal = ceil(V_max * 10) / 10
	minVal = ceil(abs(V_min) * 10) / -10
	
	// Plotting preparation
	Make/O/N=(8) M_Colors
	ColorTab2Wave Pastels
	variable ii, color_position
	string axisName, traceName
	
	// Iterate through cluster traces and plot with different colors
	Display/K=1 as "clusters"
	for (ii=0; ii<nClusters; ii+=1)
		traceName = "inputData" + Num2Str(ii)
		axisName = "L"+Num2Str(ii)
		
		AppendToGraph/L=$axisName inputData[ii][]/TN=$traceName
		ModifyGraph axisEnab($axisName)={(ii+hasStim)/(nClusters+hasStim),(ii+hasStim+1)/(nClusters+hasStim)}
		ModifyGraph nticks($axisName)=0, axThick($axisName)=0
		SetAxis $axisName minVal, maxVal
		
		color_position = floor(255 * (ii/nClusters))
		ModifyGraph plusRGB($traceName)=(M_colors[color_position][0], M_colors[color_position][1], M_Colors[color_position][2])
		ModifyGraph negRGB($traceName)=(M_colors[color_position][0], M_colors[color_position][1], M_Colors[color_position][2])
	endfor
	
	ModifyGraph rgb=(0,0,0), lsize=1.2, mode=7, useNegRGB=1, usePlusRGB=1, hbFill=3
	
	if (hasStim == 1)
		AppendToGraph/L=stim stimTrace/TN=stimulus
		ModifyGraph axisEnab(stim)={0, 1/(nClusters+hasStim)}
		ModifyGraph rgb(stimulus)=(0,0,0), nticks(stim)=0, axThick(stim)=0
	endif
	
	ModifyGraph freePos=0, margin(left)=10, margin(right)=10, margin(bottom)=32, margin(top)=2
	ModifyGraph height=nClusters*65, width=120
	Label bottom "Time (s)"
end


// ClusterGraphWithStim - multicolored cluster trace display, plus stimulus
function ClusterGraphWithStim(clusterData, stimTrace)
	wave clusterData; wave stimTrace
	
	Duplicate/O clusterData inputData
	variable nClusters = DimSize(inputData, 0)
	variable nFrames = DimSize(inputData, 1)
	
	// Smooth the data
	variable smoothFac = 50
	Smooth/E=3/B/DIM=1 smoothFac, inputData
	
	// Determine bounds for y-axes
	variable maxVal, minVal
	WaveStats/Q inputData
	maxVal = ceil(V_max * 10) / 10
	minVal = ceil(abs(V_min) * 10) / -10
	
	// Plotting preparation
	Make/O/N=(8) M_Colors
	ColorTab2Wave Pastels
	variable ii, color_position
	string axisName, traceName
	
	// Iterate through cluster traces and plot with different colors
	Display/K=1 as "clusters"
	for (ii=0; ii<nClusters; ii+=1)
		traceName = "inputData" + Num2Str(ii)
		axisName = "L"+Num2Str(ii)
		
		AppendToGraph/L=$axisName inputData[ii][]/TN=$traceName
		ModifyGraph axisEnab($axisName)={0.95 * ii/nClusters + 0.05, 0.95 * (ii+1)/nClusters + 0.05}
		ModifyGraph nticks($axisName)=0, axThick($axisName)=0
		SetAxis $axisName minVal, maxVal
		
		color_position = floor(255 * (ii/nClusters))
		ModifyGraph plusRGB($traceName)=(M_colors[color_position][0], M_colors[color_position][1], M_Colors[color_position][2])
		ModifyGraph negRGB($traceName)=(M_colors[color_position][0], M_colors[color_position][1], M_Colors[color_position][2])
	endfor
	
	ModifyGraph rgb=(0,0,0), lsize=1.2, mode=7, useNegRGB=1, usePlusRGB=1, hbFill=3
	
	AppendToGraph/L=stim stimTrace/TN=stimulus
	ModifyGraph axisEnab(stim)={0, 0.05}
	ModifyGraph rgb(stimulus)=(0,0,0), nticks(stim)=0, axThick(stim)=0
	
	ModifyGraph freePos=0, margin(left)=10, margin(right)=10, margin(bottom)=32, margin(top)=2
	ModifyGraph height=nClusters*65, width=120
	Label bottom "Time (s)"
end