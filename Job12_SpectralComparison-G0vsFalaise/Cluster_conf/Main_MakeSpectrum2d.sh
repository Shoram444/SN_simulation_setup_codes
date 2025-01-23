#!/bin/bash
	
## ABSOLUTE LINKING:


	MAIN_FOLDER=/sps/nemo/scratch/mpetro/Projects/PhD/Cluster/Data
	CONF_FOLDER=/pbs/home/m/mpetro/Projects/PhD/Codes/Job11_SpectrumG0_1e7/Cluster_conf
	ROOT_FOLDER=/sps/nemo/sw/BxCppDev/opt/root-6.16.00/bin/
	RUN_SCRIPT=MakeSpectrum2d.sh

## END LINKING
	
	echo "	"
	cd $MAIN_FOLDER
	ls
	echo "	"

	echo "Choose the name of simulation folder:"
	read USER_FOLDNAME
	echo "					   "

	if [ ! -d "$MAIN_FOLDER/$USER_FOLDNAME" ] 
	then
		mkdir -p $MAIN_FOLDER/$USER_FOLDNAME
	else
		echo "Warning: Simulation name already exists. Using previously used configuration files."
		echo "											 "
	fi
		
	cd $MAIN_FOLDER/$USER_FOLDNAME
	ls
	echo "	"

	echo "Choose number of jobs (files):"
	read FILES
	echo "				    "
		
	for (( i=0 ; i<$FILES ; i++ ))
	do
		if [ ! -f "Spectrum.root" ] 
		then
		
			echo 	"Sending request for Run $i!"
			echo    "==========================="

			sed -e "s|%i|$i|g" \
			    -e "s|%USER_FOLDNAME|$USER_FOLDNAME|g" \
			    -e "s|%MAIN_FOLDER|$MAIN_FOLDER|g" \
			    -e "s|%ROOT_FOLDER|$ROOT_FOLDER|g" \
			    -e "s|%CONF_FOLDER|$CONF_FOLDER|g" \
				$CONF_FOLDER/$RUN_SCRIPT > $MAIN_FOLDER/$USER_FOLDNAME/$i/$RUN_SCRIPT 


			chmod 755 $MAIN_FOLDER/$USER_FOLDNAME/$i/$RUN_SCRIPT

			qsub -o $MAIN_FOLDER/$USER_FOLDNAME/$i/Job11_OUT_${i}.log -e $MAIN_FOLDER/$USER_FOLDNAME/$i/Job11_ERR_${i}.log $MAIN_FOLDER/$USER_FOLDNAME/$i/$RUN_SCRIPT  
		fi
	done	
	
		
		
		
###
