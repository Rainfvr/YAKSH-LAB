
echo "please enter full path to project folder" 
read varname

echo "OK i'll go do some work then..."

xvfb-run -a /home/analysis/Fiji.app/ImageJ-linux64 --ij2 --headless -macro /home/analysis/Desktop/MH_pipeline/test.ijm "$varname"


