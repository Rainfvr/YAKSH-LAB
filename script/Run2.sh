echo "please enter full path to project folder" 
read varname

echo "OK i'll go do some work then..."


mkdir -p $varname/raw
mv $varname/*.lif $varname/raw/


mkdir -p $varname/neu
mkdir -p $varname/mac
mkdir -p $varname/bv

for filename in $varname/raw/*.lif; do
	newfile="$(basename $filename .lif)"
	#echo "$newfile"_mac.tif
	/home/analysis/Desktop/MH_pipeline/bftools/bfconvert -channel 0 $filename $varname/neu/"$newfile"_neu.tif
	/home/analysis/Desktop/MH_pipeline/bftools/bfconvert -channel 1 $filename $varname/mac/"$newfile"_mac.tif
	/home/analysis/Desktop/MH_pipeline/bftools/bfconvert -channel 2 $filename $varname/bv/"$newfile"_bv.tif

done

mkdir -p $varname/mac_out
mkdir -p $varname/bv_out

yapic predict /home/analysis/Desktop/MH_pipeline/models/mac2d.h5 "$varname/mac/*.tif" $varname/mac_out/
rm $varname/mac_out/*class_2*

yapic predict /home/analysis/Desktop/MH_pipeline/models/BV1.h5 "$varname/bv/*.tif" $varname/bv_out/
rm $varname/bv_out/*class_2*

/home/analysis/Fiji.app/ImageJ-linux64 -macro /home/analysis/Desktop/MH_pipeline/Macro/helpmeAlbert.p "$varname"


