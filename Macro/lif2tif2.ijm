input = getArgument();
imp = input + "/raw/"

files = getFileList(imp);
nf = lengthOf(files);
close("*");


for (i = 0; i < lengthOf(files); i++) {
	x = i + 1;
  
  //print out current status of batch	
	print("running file " + x + " out of " + nf);
	open(imp + files[i]);
	name = getTitle();
	img = replace(name , ".lif" , "" ); 
	run("Split Channels");
	selectWindow("C1-" + name);
	saveAs("Tiff", input + "/neu/" + img + "_neu.tif");
	selectWindow("C2-" + name);
	saveAs("Tiff", input + "/mac/" + img + "_mac.tif");
	selectWindow("C3-" + name);
	saveAs("Tiff", input + "/bv/" + img + "_bv.tif");
	close("*");
	
}
wait(1000);
run("Quit");