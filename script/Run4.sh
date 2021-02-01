echo "please enter full path to project folder" 
read varname

echo "OK i'll go do some work then..."


/home/analysis/Fiji.app/ImageJ-linux64 -macro /home/analysis/Desktop/MH_pipeline/Macro/lif2tif.ijm "$varname"

done


