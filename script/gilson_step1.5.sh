echo "please enter full path to project folder" 
read varname

echo "OK i'll go do some work then..."


mkdir -p $varname/mac_out
mkdir -p $varname/bv_out

yapic predict /home/analysis/Desktop/MH_pipeline/models/mac20.h5 "$varname/mac/*.tif" $varname/mac_out/
rm $varname/mac_out/*class_2*

yapic predict /home/analysis/Desktop/MH_pipeline/models/BV1.h5 "$varname/bv/*.tif" $varname/bv_out/
rm $varname/bv_out/*class_2*

