// Matt's Magic Macrophage Making Marvelous Machine Macro

xb = getArgument();
testfolder = xb + "/";

mac_file_path = testfolder + "mac/"
bv_file_path = testfolder + "bv/"
neun_file_path = testfolder + "neu/"
yapic = testfolder + "mac_out/"
yapic_bv = testfolder + "bv_out/"
lifs = testfolder + "raw/"

ns = "_neu.tif"
ms = "_mac.tif"
bs = "_bv.tif"
yms = "_mac_class_1.tif"
ybs = "_bv_class_1.tif"


close("*");


results_p = testfolder

//Create folders to hold label maps and data tables 
File.makeDirectory(results_p + "/PV_maps");
File.makeDirectory(results_p + "/NPV_maps");
File.makeDirectory(results_p + "/data_tables");


pvmaps_save = results_p + "/PV_maps/";
npvmaps_save = results_p + "/NPV_maps/";
results_save = results_p + "/data_tables/";




//get the time at the beggining
start_time = getTime();

//get files from lifs folder
files = getFileList(yapic_bv);
nf = lengthOf(files);

print(nf);

for (i = 0; i < lengthOf(files); i++) {
	x = i + 1;
  
  //print out current status of batch	
	print("running file " + x + " out of " + nf);
	run("Bio-Formats Windowless Importer", "open=" + yapic_bv + files[i] + " color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	raw = getTitle();
	start_time_image = getTime();

	

	
  //create variable for identifying which yapic out file to open as well 	
	name = replace(raw , "_bv_class_1.tif" , "" ); 

	
	//start CLIJ and push bv image	
	run("CLIJ2 Macro Extensions", "cl_device=[Quadro P5000]");
	Ext.CLIJ2_clear();
	Ext.CLIJ2_push(raw);
	
	//Threshold 
	Ext.CLIJ2_thresholdOtsu(raw, yapbv_bin);
	Ext.CLIJ2_pull(yapbv_bin);
	print("Blood Vessels Found for " + name);


	print("Identifying macrophages for " + name);

//OPEN UP YAPIC OUTPUT AND SPLIT INTO PERIVASCULAR AND NON PERIVASCULAR MAPS	
	run("Bio-Formats Windowless Importer", "open=" + yapic + name + yms + " color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	
	yap = getTitle();
	
  // push mac_output images to GPU
	Ext.CLIJ2_push(yap);
	
  //threshold macrophages from yapic out	
  	Ext.CLIJ2_minimum3DSphere(yap, yapmin, 1.1,1.1,1.1);
	Ext.CLIJ2_thresholdOtsu(yapmin, yap_bin);
	Ext.CLIJ2_connectedComponentsLabelingDiamond(yap_bin, labelmap);

 	print("Macrophages Segmented for " + raw);
	run("Clear Results");
	

	Ext.CLIJ2_statisticsOfBackgroundAndLabelledPixels(yap_bin, labelmap);

	print("Identifying perivascular macrophages " + raw);
  // push pixel count for size filter to GPU
	Ext.CLIJ2_pushResultsTableColumn(PIXEL_COUNT, "PIXEL_COUNT");
	Ext.CLIJ2_excludeLabelsWithValuesWithinRange(PIXEL_COUNT, labelmap, filtered_labelmap, 0, 1500);
	run("Clear Results");
	

	
	Ext.CLIJ2_statisticsOfBackgroundAndLabelledPixels(yapbv_bin, filtered_labelmap);

	Ext.CLIJ2_pushResultsTableColumn(bvsum, "SUM_INTENSITY");
	
 //extract and save labelmap of perivascular macrophages
	Ext.CLIJ2_excludeLabelsWithValuesWithinRange(bvsum, filtered_labelmap, PeriVascular, 0, 100);
	Ext.CLIJ2_saveAsTIF(PeriVascular, pvmaps_save + name);
	Ext.CLIJ2_pull(PeriVascular);
	rename("PV_" + name);
	pvmap = getTitle();
	
print("Identifying non-perivascular macrophages for image " + raw);
// extract and save labelmap of non-perivascular macrophages 
	Ext.CLIJ2_excludeLabelsWithValuesOutOfRange(bvsum, filtered_labelmap, NonPeriVascular, 0, 100);
	Ext.CLIJ2_saveAsTIF(NonPeriVascular, npvmaps_save + name);
	Ext.CLIJ2_pull(NonPeriVascular);
	rename("NPV_" + name);
	npvmap = getTitle();

print("Saving Data for " + name);	


//GET RAW IMAGE DATA OF PV AND NONPV CELLS	
	run("CLIJ2 Macro Extensions", "cl_device=[Quadro P5000]");
	Ext.CLIJ2_clear();
	
	run("Clear Results");


//open raw mac image

	open(mac_file_path + name + ms);
	mac = getTitle();
  //get Perivascular data
	Ext.CLIJ2_push(pvmap);
	Ext.CLIJ2_push(mac)
	Ext.CLIJ2_statisticsOfBackgroundAndLabelledPixels(mac, pvmap);
	
  
	

  //Rename Table columns	
	Table.renameColumn("MINIMUM_INTENSITY", "mac_Min_Int");
	Table.renameColumn("SUM_INTENSITY", "mac_Sum_Int");
	Table.renameColumn("MEAN_INTENSITY", "mac_Mean_Int");
	Table.renameColumn("MAXIMUM_INTENSITY", "mac_MAX_INT");
	Table.renameColumn("PIXEL_COUNT", "mac_PIXEL_COUNT");
  //update table	
	Table.update();

	saveAs("results", results_save + "PV_mac_" + name+ ".csv");
	run("Clear Results");
	
	  
  //get Perivascular data
	Ext.CLIJ2_push(npvmap);
	Ext.CLIJ2_statisticsOfBackgroundAndLabelledPixels(mac, npvmap);

 
	
	

  //Rename Table columns	
	Table.renameColumn("MINIMUM_INTENSITY", "mac_Min_Int");
	Table.renameColumn("SUM_INTENSITY", "mac_Sum_Int");
	Table.renameColumn("MEAN_INTENSITY", "mac_Mean_Int");
	Table.renameColumn("MAXIMUM_INTENSITY", "mac_MAX_INT");
	Table.renameColumn("PIXEL_COUNT", "mac_PIXEL_COUNT");
  //update table	
	Table.update();

	saveAs("results", results_save + "NPV_mac_" + name+ ".csv");
	run("Clear Results");


//open raw BV image again
	open(bv_file_path + name + bs);
	BV = getTitle();
//GET DATA FROM RAW BLOOD VESSEL IMAGE
	Ext.CLIJ2_push(BV)

Ext.CLIJ2_statisticsOfBackgroundAndLabelledPixels(BV, pvmap);
	
  //Delete columns and relable data tables
	Table.deleteColumn('BOUNDING_BOX_X');
	Table.deleteColumn('BOUNDING_BOX_Y');
	Table.deleteColumn('BOUNDING_BOX_Z');
	Table.deleteColumn('BOUNDING_BOX_END_X');
	Table.deleteColumn('BOUNDING_BOX_END_Y');
	Table.deleteColumn('BOUNDING_BOX_END_Z');
	Table.deleteColumn('BOUNDING_BOX_WIDTH');
	Table.deleteColumn('BOUNDING_BOX_HEIGHT');
	Table.deleteColumn('BOUNDING_BOX_DEPTH');
	Table.deleteColumn('STANDARD_DEVIATION_INTENSITY');
	Table.deleteColumn('SUM_INTENSITY_TIMES_X');
	Table.deleteColumn('SUM_INTENSITY_TIMES_Y');
	Table.deleteColumn('SUM_INTENSITY_TIMES_Z');
	Table.deleteColumn('MASS_CENTER_X');
	Table.deleteColumn('MASS_CENTER_Y');
	Table.deleteColumn('MASS_CENTER_Z');
	Table.deleteColumn('SUM_X');
	Table.deleteColumn('SUM_Y');
	Table.deleteColumn('SUM_Z');
	Table.deleteColumn('CENTROID_X');
	Table.deleteColumn('CENTROID_Y');
	Table.deleteColumn('CENTROID_Z');
	Table.deleteColumn('SUM_DISTANCE_TO_MASS_CENTER');
	Table.deleteColumn('MEAN_DISTANCE_TO_MASS_CENTER');
	Table.deleteColumn('MAX_DISTANCE_TO_MASS_CENTER');
	Table.deleteColumn('MAX_MEAN_DISTANCE_TO_MASS_CENTER_RATIO');
	Table.deleteColumn('SUM_DISTANCE_TO_CENTROID');
	Table.deleteColumn('MEAN_DISTANCE_TO_CENTROID');
	Table.deleteColumn('MAX_DISTANCE_TO_CENTROID');
	Table.deleteColumn('MAX_MEAN_DISTANCE_TO_CENTROID_RATIO');
	

  //Rename Table columns	
	Table.renameColumn("MINIMUM_INTENSITY", "BV_MINIMUM_INTENSITY");
	Table.renameColumn("SUM_INTENSITY", "BV_SUM_INTENSITY");
	Table.renameColumn("MEAN_INTENSITY", "BV_MEAN_INTENSITY");
	Table.renameColumn("MAXIMUM_INTENSITY", "BV_MAXIMUM_INTENSITY");
	Table.renameColumn("PIXEL_COUNT", "BV_PIXEL_COUNT");
  //update table	
	Table.update();

	saveAs("results", results_save + "PV_BloodVessels_" + name+ ".csv");
	run("Clear Results");
	
	  
  //get Perivascular data
	Ext.CLIJ2_statisticsOfBackgroundAndLabelledPixels(BV, npvmap);

  //Delete columns and relable data tables
	Table.deleteColumn('BOUNDING_BOX_X');
	Table.deleteColumn('BOUNDING_BOX_Y');
	Table.deleteColumn('BOUNDING_BOX_Z');
	Table.deleteColumn('BOUNDING_BOX_END_X');
	Table.deleteColumn('BOUNDING_BOX_END_Y');
	Table.deleteColumn('BOUNDING_BOX_END_Z');
	Table.deleteColumn('BOUNDING_BOX_WIDTH');
	Table.deleteColumn('BOUNDING_BOX_HEIGHT');
	Table.deleteColumn('BOUNDING_BOX_DEPTH');
	Table.deleteColumn('STANDARD_DEVIATION_INTENSITY');
	Table.deleteColumn('SUM_INTENSITY_TIMES_X');
	Table.deleteColumn('SUM_INTENSITY_TIMES_Y');
	Table.deleteColumn('SUM_INTENSITY_TIMES_Z');
	Table.deleteColumn('MASS_CENTER_X');
	Table.deleteColumn('MASS_CENTER_Y');
	Table.deleteColumn('MASS_CENTER_Z');
	Table.deleteColumn('SUM_X');
	Table.deleteColumn('SUM_Y');
	Table.deleteColumn('SUM_Z');
	Table.deleteColumn('CENTROID_X');
	Table.deleteColumn('CENTROID_Y');
	Table.deleteColumn('CENTROID_Z');
	Table.deleteColumn('SUM_DISTANCE_TO_MASS_CENTER');
	Table.deleteColumn('MEAN_DISTANCE_TO_MASS_CENTER');
	Table.deleteColumn('MAX_DISTANCE_TO_MASS_CENTER');
	Table.deleteColumn('MAX_MEAN_DISTANCE_TO_MASS_CENTER_RATIO');
	Table.deleteColumn('SUM_DISTANCE_TO_CENTROID');
	Table.deleteColumn('MEAN_DISTANCE_TO_CENTROID');
	Table.deleteColumn('MAX_DISTANCE_TO_CENTROID');
	Table.deleteColumn('MAX_MEAN_DISTANCE_TO_CENTROID_RATIO');
	

  //Rename Table columns	
	Table.renameColumn("MINIMUM_INTENSITY", "BV_MINIMUM_INTENSITY");
	Table.renameColumn("SUM_INTENSITY", "BV_SUM_INTENSITY");
	Table.renameColumn("MEAN_INTENSITY", "BV_MEAN_INTENSITY");
	Table.renameColumn("MAXIMUM_INTENSITY", "BV_MAXIMUM_INTENSITY");
	Table.renameColumn("PIXEL_COUNT", "BV_PIXEL_COUNT");
	
  //update table	
	Table.update();

	saveAs("results", results_save + "NPV_BloodVessels_" + name + ".csv");
	run("Clear Results");

//open NEUN image

 	open(neun_file_path + name + ns);
 	neu = getTitle();
 	
//GET DATA FROM RAW NeuN IMAGE
	Ext.CLIJ2_push(neu);

Ext.CLIJ2_statisticsOfBackgroundAndLabelledPixels(neu, pvmap);
	
  //Delete columns and relable data tables
	Table.deleteColumn('BOUNDING_BOX_X');
	Table.deleteColumn('BOUNDING_BOX_Y');
	Table.deleteColumn('BOUNDING_BOX_Z');
	Table.deleteColumn('BOUNDING_BOX_END_X');
	Table.deleteColumn('BOUNDING_BOX_END_Y');
	Table.deleteColumn('BOUNDING_BOX_END_Z');
	Table.deleteColumn('BOUNDING_BOX_WIDTH');
	Table.deleteColumn('BOUNDING_BOX_HEIGHT');
	Table.deleteColumn('BOUNDING_BOX_DEPTH');
	Table.deleteColumn('STANDARD_DEVIATION_INTENSITY');
	Table.deleteColumn('SUM_INTENSITY_TIMES_X');
	Table.deleteColumn('SUM_INTENSITY_TIMES_Y');
	Table.deleteColumn('SUM_INTENSITY_TIMES_Z');
	Table.deleteColumn('MASS_CENTER_X');
	Table.deleteColumn('MASS_CENTER_Y');
	Table.deleteColumn('MASS_CENTER_Z');
	Table.deleteColumn('SUM_X');
	Table.deleteColumn('SUM_Y');
	Table.deleteColumn('SUM_Z');
	Table.deleteColumn('CENTROID_X');
	Table.deleteColumn('CENTROID_Y');
	Table.deleteColumn('CENTROID_Z');
	Table.deleteColumn('SUM_DISTANCE_TO_MASS_CENTER');
	Table.deleteColumn('MEAN_DISTANCE_TO_MASS_CENTER');
	Table.deleteColumn('MAX_DISTANCE_TO_MASS_CENTER');
	Table.deleteColumn('MAX_MEAN_DISTANCE_TO_MASS_CENTER_RATIO');
	Table.deleteColumn('SUM_DISTANCE_TO_CENTROID');
	Table.deleteColumn('MEAN_DISTANCE_TO_CENTROID');
	Table.deleteColumn('MAX_DISTANCE_TO_CENTROID');
	Table.deleteColumn('MAX_MEAN_DISTANCE_TO_CENTROID_RATIO');
	

  //Rename Table columns	
	Table.renameColumn("MINIMUM_INTENSITY", "NeuN_MINIMUM_INTENSITY");
	Table.renameColumn("SUM_INTENSITY", "NeuN_SUM_INTENSITY");
	Table.renameColumn("MEAN_INTENSITY", "NeuN_MEAN_INTENSITY");
	Table.renameColumn("MAXIMUM_INTENSITY", "NeuN_MAXIMUM_INTENSITY");
	Table.renameColumn("PIXEL_COUNT", "NeuN_PIXEL_COUNT");
  //update table	
	Table.update();

	saveAs("results", results_save + "PV_NeuN_" + name + ".csv");
	run("Clear Results");
	
	  
  //get Perivascular data
	Ext.CLIJ2_statisticsOfBackgroundAndLabelledPixels(neu, npvmap);

  //Delete columns and relable data tables
	Table.deleteColumn('BOUNDING_BOX_X');
	Table.deleteColumn('BOUNDING_BOX_Y');
	Table.deleteColumn('BOUNDING_BOX_Z');
	Table.deleteColumn('BOUNDING_BOX_END_X');
	Table.deleteColumn('BOUNDING_BOX_END_Y');
	Table.deleteColumn('BOUNDING_BOX_END_Z');
	Table.deleteColumn('BOUNDING_BOX_WIDTH');
	Table.deleteColumn('BOUNDING_BOX_HEIGHT');
	Table.deleteColumn('BOUNDING_BOX_DEPTH');
	Table.deleteColumn('STANDARD_DEVIATION_INTENSITY');
	Table.deleteColumn('SUM_INTENSITY_TIMES_X');
	Table.deleteColumn('SUM_INTENSITY_TIMES_Y');
	Table.deleteColumn('SUM_INTENSITY_TIMES_Z');
	Table.deleteColumn('MASS_CENTER_X');
	Table.deleteColumn('MASS_CENTER_Y');
	Table.deleteColumn('MASS_CENTER_Z');
	Table.deleteColumn('SUM_X');
	Table.deleteColumn('SUM_Y');
	Table.deleteColumn('SUM_Z');
	Table.deleteColumn('CENTROID_X');
	Table.deleteColumn('CENTROID_Y');
	Table.deleteColumn('CENTROID_Z');
	Table.deleteColumn('SUM_DISTANCE_TO_MASS_CENTER');
	Table.deleteColumn('MEAN_DISTANCE_TO_MASS_CENTER');
	Table.deleteColumn('MAX_DISTANCE_TO_MASS_CENTER');
	Table.deleteColumn('MAX_MEAN_DISTANCE_TO_MASS_CENTER_RATIO');
	Table.deleteColumn('SUM_DISTANCE_TO_CENTROID');
	Table.deleteColumn('MEAN_DISTANCE_TO_CENTROID');
	Table.deleteColumn('MAX_DISTANCE_TO_CENTROID');
	Table.deleteColumn('MAX_MEAN_DISTANCE_TO_CENTROID_RATIO');
	

  //Rename Table columns	
	Table.renameColumn("MINIMUM_INTENSITY", "NeuN_MINIMUM_INTENSITY");
	Table.renameColumn("SUM_INTENSITY", "NeuN_SUM_INTENSITY");
	Table.renameColumn("MEAN_INTENSITY", "NeuN_MEAN_INTENSITY");
	Table.renameColumn("MAXIMUM_INTENSITY", "NeuN_MAXIMUM_INTENSITY");
	Table.renameColumn("PIXEL_COUNT", "NeuN_PIXEL_COUNT");
	
  //update table	
	Table.update();

	saveAs("results", results_save + "NPV_NeuN_" + name+ ".csv");
	
	run("Clear Results");
	
	print("Done! Image " + raw + " took: " + ((getTime() - start_time_image)/1000) + " sec to complete");	
	
	close("*");

	
	
}
print("Total macro time took: " + ((getTime()-start_time)/1000) + " seconds")
	
