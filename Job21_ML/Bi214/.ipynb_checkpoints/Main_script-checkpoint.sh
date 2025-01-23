#!/bin/bash
	
## ABSOLUTE LINKING:

	FAL=/pbs/home/m/mpetro/PROGRAMS/Falaise/install/bin
	JULIA=/pbs/home/m/mpetro/PROGRAMS/Julia/julia-1.7.2/bin
	MAIN_FOLDER=/sps/nemo/scratch/mpetro/Projects/PhD/Cluster/DataWithoutBField
	CONF_FOLDER=/pbs/home/m/mpetro/Projects/PhD/Codes/Job21_ML/Bi214
	RESOURCES=/pbs/home/m/mpetro/PROGRAMS/Falaise/install/share/Falaise-4.0.3/resources/genbb
	ROOT_FOLDER=/sps/nemo/sw/BxCppDev/opt/root-6.16.00/bin
	SENSITIVITY_MODULE=/sps/nemo/scratch/vpalusov/sw/my_falaise/SensitivityModule2/SensitivityModule/build/SensitivityModuleExample.conf

## END LINKING
	
	echo "	"
	cd $MAIN_FOLDER
	ls	
	echo "	"

	echo "Choose the name of simulation folder:"
	read USER_FOLDNAME
	echo "					   "

	echo "Choose number of files:"
	read FILES
	echo "	"		
		

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
		
	echo 	"Sending request for Run $USER_FOLDNAME!"
	echo    "==========================="

	for (( f=0; f < $FILES; f++  )) # iterate over number of files 
	do
		if [ ! -d "$MAIN_FOLDER/$USER_FOLDNAME/$f/" ]  # create unique folder 
		then

			mkdir 	$MAIN_FOLDER/$USER_FOLDNAME/$f/	

    		cp $CONF_FOLDER/Job21.cpp $MAIN_FOLDER/$USER_FOLDNAME/$f/
    		cp $CONF_FOLDER/Bi214.conf $MAIN_FOLDER/$USER_FOLDNAME/$f/
			cp $CONF_FOLDER/Bi214.profile $MAIN_FOLDER/$USER_FOLDNAME/$f/

			sed -e "s|%f|$f|g" \
			    -e "s|%FAL|$FAL|g" \
			    -e "s|%USER_FOLDNAME|$USER_FOLDNAME|g" \
			    -e "s|%CONF_FOLDER|$CONF_FOLDER|g" \
			    -e "s|%MAIN_FOLDER|$MAIN_FOLDER|g" \
			    -e "s|%RESOURCES|$RESOURCES|g" \
			    -e "s|%ROOT_FOLDER|$ROOT_FOLDER|g" \
			    -e "s|%SENSITIVITY_MODULE|$SENSITIVITY_MODULE|g" \
				$CONF_FOLDER/run_script.sh > $MAIN_FOLDER/$USER_FOLDNAME/$f/run_script.sh 

			chmod 755 $MAIN_FOLDER/$USER_FOLDNAME/$f/run_script.sh

			sbatch -o $MAIN_FOLDER/$USER_FOLDNAME/$f/OUT_${f}.log -e $MAIN_FOLDER/$USER_FOLDNAME/$f/ERR_${f}.log $MAIN_FOLDER/$USER_FOLDNAME/$f/run_script.sh  

		fi
	done
		
###
