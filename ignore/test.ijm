
run("Bio-Formats Windowless Importer", "open=/home/analysis/Desktop/ptest/bv_out/190517_LPSIT_15_DRG_bv_class_1.tif color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");

raw = getTitle();

run("CLIJ2 Macro Extensions", "cl_device=[Quadro P5000]")
	Ext.CLIJ2_push(raw);


	//Threshold 
	Ext.CLIJ2_thresholdOtsu(raw, yapbv_bin);
	Ext.CLIJ2_pull(yapbv_bin);
