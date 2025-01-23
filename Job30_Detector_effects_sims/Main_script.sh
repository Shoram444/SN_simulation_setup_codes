#!/bin/bash
	
## ABSOLUTE LINKING:

	echo "Number of events to simulate?: "
	read NSIM
	

	FAL=/sps/nemo/sw/redhat-9-x86_64/snsw/opt/falaise-5.1.2/bin
	DATA_FOLDER=/sps/nemo/scratch/mpetro/Projects/PhD/Cluster_sim_data
	MAIN_FOLDER=/pbs/home/m/mpetro/Projects/PhD/Codes/Job30_Detector_effects_sims
	ROOT_FOLDER=/sps/nemo/sw/BxCppDev/opt/root-6.16.00/bin

## END LINKING
	
	echo "	"
	cd $DATA_FOLDER
	ls	
	echo "	"

	echo "Choose the name of simulation folder:"
	read USER_FOLDNAME
	echo "					   "

	echo "Choose number of files:"
	read FILES
	echo "	"		
		

	if [ ! -d "$DATA_FOLDER/$USER_FOLDNAME" ] 
	then
		mkdir -p $DATA_FOLDER/$USER_FOLDNAME
	else
		echo "Warning: Simulation name already exists. Using previously used configuration files."
		echo "											 "
	fi

	cd $DATA_FOLDER/$USER_FOLDNAME
	ls
	echo "	"
		
	echo 	"Sending request for Run $USER_FOLDNAME!"
	echo    "==========================="

	for (( f=0; f < $FILES; f++  )) # iterate over number of files 
	do
		if [ ! -d "$DATA_FOLDER/$USER_FOLDNAME/$f/" ]  # create unique folder 
		then

			mkdir 	$DATA_FOLDER/$USER_FOLDNAME/$f/	

			cp $MAIN_FOLDER/Job31.cpp $DATA_FOLDER/$USER_FOLDNAME/$f
			cp $MAIN_FOLDER/aegir_conf/variant.profile $DATA_FOLDER/$USER_FOLDNAME/$f/variant.profile

			sed -e "s|%NSIM|$NSIM|" \
				-e "s|%USER_FOLDNAME|$USER_FOLDNAME|g" \
			    -e "s|%DATA_FOLDER|$DATA_FOLDER|g" \
				-e "s|%f|$f|g" \
				$MAIN_FOLDER/aegir_conf/simu.conf > $DATA_FOLDER/$USER_FOLDNAME/$f/simu.conf

			sed -e "s|%f|$f|g" \
			    -e "s|%FAL|$FAL|g" \
			    -e "s|%ISO|$ISO|g" \
			    -e "s|%SOURCE|$SOURCE|g" \
			    -e "s|%USER_FOLDNAME|$USER_FOLDNAME|g" \
			    -e "s|%MAIN_FOLDER|$MAIN_FOLDER|g" \
			    -e "s|%DATA_FOLDER|$DATA_FOLDER|g" \
			    -e "s|%RESOURCES|$RESOURCES|g" \
			    -e "s|%ROOT_FOLDER|$ROOT_FOLDER|g" \
			    -e "s|%SENSITIVITY_MODULE|$SENSITIVITY_MODULE|g" \
				$MAIN_FOLDER/run_script.sh > $DATA_FOLDER/$USER_FOLDNAME/$f/run_script.sh 

			chmod 755 $DATA_FOLDER/$USER_FOLDNAME/$f/run_script.sh

			# sbatch $DATA_FOLDER/$USER_FOLDNAME/$f/run_script.sh  
			sbatch -o $DATA_FOLDER/$USER_FOLDNAME/$f/OUT_${f}.log -e $DATA_FOLDER/$USER_FOLDNAME/$f/ERR_${f}.log $DATA_FOLDER/$USER_FOLDNAME/$f/run_script.sh  

		fi
	done
		
###
