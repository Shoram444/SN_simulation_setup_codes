echo "Choose the name of out folder:"
read USER_FOLDNAME

echo "Choose kappa:"
read KAPPA

if [ ! -d "$USER_FOLDNAME" ] 
then
	mkdir -p $USER_FOLDNAME

	/home/shoram/Work/Julia/julia/usr/bin/julia --project=../ --threads=10 genbb_test.jl $KAPPA $USER_FOLDNAME
else
	echo "Warning: Simulation name already exists. Using previously used configuration files."
	echo "											 "
fi
