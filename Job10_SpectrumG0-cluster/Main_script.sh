#!/bin/bash
	
## ABSOLUTE LINKING:

	FAL=/pbs/home/m/mpetro/PROGRAMS/Falaise/install/bin
	JULIA=/pbs/home/m/mpetro/PROGRAMS/Julia/julia-1.7.2/bin
	MAIN_FOLDER=/sps/nemo/scratch/mpetro/Projects/PhD/Cluster/Data
	CONF_FOLDER=/pbs/home/m/mpetro/Projects/PhD/Codes/Job10_SpectrumG0-cluster

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
		if [ ! -d "$MAIN_FOLDER/$USER_FOLDNAME/$i/" ] 
		then
			mkdir 	$MAIN_FOLDER/$USER_FOLDNAME/$i/	
    		cd 		$MAIN_FOLDER/$USER_FOLDNAME/$i/	

    		echo 	"Sending request for Run $i!"
    		echo    "==========================="

    		cp $CONF_FOLDER/genbbGenerator.jl $MAIN_FOLDER/$USER_FOLDNAME/$i/

    		sed -e "s|%i|$i|g" \
			    -e "s|%FAL|$FAL|g" \
			    -e "s|%JULIA|$JULIA|g" \
			    -e "s|%USER_FOLDNAME|$USER_FOLDNAME|g" \
			    -e "s|%CONF_FOLDER|$CONF_FOLDER|g" \
			    -e "s|%MAIN_FOLDER|$MAIN_FOLDER|g" \
				$CONF_FOLDER/script.sh > $MAIN_FOLDER/$USER_FOLDNAME/$i/script.sh 

			chmod 755 $MAIN_FOLDER/$USER_FOLDNAME/$i/script.sh

    		qsub -o $MAIN_FOLDER/$USER_FOLDNAME/$i/OUT_${i}.log -e $MAIN_FOLDER/$USER_FOLDNAME/$i/ERR_${i}.log $MAIN_FOLDER/$USER_FOLDNAME/$i/script.sh  
		fi
	done
	
		
		
		
###
