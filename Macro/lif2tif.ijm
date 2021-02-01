input = getArgument();
files = getFileList(input);
nf = lengthOf(files);

ch1

print(nf);

for (i = 0; i < lengthOf(files); i++) {
	x = i + 1;
  
  //print out current status of batch	
	print("running file " + x + " out of " + nf);
	run("Bio-Formats Windowless Importer", "open=" + input +"/" + files[i] + " color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	raw = getTitle();
	start_time_image = getTime();
	run("Split Channels");
	selectWindow("C1- " + raw);
	name = replace(raw,".lif", "");
	saveAs("Tif", name + "_" + ch1 ".tif");
	

